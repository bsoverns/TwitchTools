import os
import xml.etree.ElementTree as ET
from collections import namedtuple, defaultdict
from datetime import datetime
import re
import pyodbc
import sys
from contextlib import contextmanager
sys.path.append(r"C:\Sandbox\TwitchTools\TwitchData")
import SECRETS as secrets

# === Global Configurations ===
debug = False
firstLineErrorLog = True
databases = ["TwitchBot3"]
log_output_dir = r"C:\Sandbox\TwitchTools\TwitchData\Logs"
os.makedirs(log_output_dir, exist_ok=True)

@contextmanager
def ConnectToDatabase(server, database, user, password):
    conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};UID={user};PWD={password}"
    conn = pyodbc.connect(conn_str)
    try:
        yield conn
    finally:
        conn.close()

# === Logging ===
def GetLogFilePath(log_dir):
    today = datetime.now().strftime("%Y-%m-%d")
    return os.path.join(log_dir, f"deployment_log_{today}.txt")

def WriteLog(log_dir, messages):
    log_path = GetLogFilePath(log_dir)
    timestamped_messages = [f"[{datetime.now().strftime('%H:%M:%S')}] {msg}" for msg in messages]         
    with open(log_path, "a", encoding="utf-8") as f:
        for line in timestamped_messages:
            f.write(line + "\n\n")
    return log_path

# === SQLProj Parser ===
def ParseProjectFile(project_path):
    tree = ET.parse(project_path)
    root = tree.getroot()
    ns = {'ns': 'http://schemas.microsoft.com/developer/msbuild/2003'}
    build_items = root.findall(".//ns:Build", namespaces=ns)
    return [os.path.join(project_dir, item.attrib['Include']) for item in build_items if item.attrib['Include'].endswith('.sql')]

TableColumn = namedtuple("TableColumn", ["schema", "table", "column", "datatype", "nullable"])

def ParseCreateTable(sql_text):
    tables = defaultdict(list)
    constraints = defaultdict(list)
    
    # Split on "CREATE TABLE" to find definitions
    create_table_blocks = re.split(r'\bCREATE\s+TABLE\b', sql_text, flags=re.IGNORECASE)
    
    for block in create_table_blocks[1:]:  # Skip the first split (anything before first CREATE TABLE)
        header_and_body = block.strip().split('(', 1)
        if len(header_and_body) != 2:
            continue

        header, body_plus = header_and_body
        table_match = re.match(r'\s*\[?(\w+)\]?\.\[?(\w+)\]?', header.strip())
        if not table_match:
            continue

        schema, table = table_match.groups()

        # Match body until the closing parenthesis that ends the table declaration
        body = ''
        open_parens = 1
        for i, char in enumerate(body_plus):
            body += char
            if char == '(':
                open_parens += 1
            elif char == ')':
                open_parens -= 1
                if open_parens == 0:
                    break

        parts = re.split(r',(?![^()]*\))', body)
        for part in parts:
            line = part.strip()
            if line.upper().startswith("CONSTRAINT") or any(kw in line.upper() for kw in ["PRIMARY KEY", "FOREIGN KEY", "UNIQUE", "CHECK"]):
                constraints[(schema, table)].append(line)
            else:
                match = re.match(r'\[?(\w+)\]?\s+([^\s,\[]+(?:\([^\)]*\))?)(?:\s+(NOT\s+NULL|NULL))?', line, re.IGNORECASE)
                if match:
                    col = match.group(1)
                    datatype = match.group(2)
                    nullable = (match.group(3) or '').strip().upper() == 'NULL'
                    inline_default = ''
                    default_match = re.search(r'(CONSTRAINT\s+\[\w+\]\s+DEFAULT\s+.+)', line, re.IGNORECASE)
                    if default_match:
                        inline_def = default_match.group(1).strip()
                        inline_default = ' ' + inline_def
                        constraint_name_match = re.search(r'CONSTRAINT\s+\[([^\]]+)\]\s+DEFAULT\s+(.+)', inline_def, re.IGNORECASE)
                        if constraint_name_match:
                            constraint_name = constraint_name_match.group(1)
                            default_expr = constraint_name_match.group(2).strip()
                            constraints[(schema, table)].append(
                                f"CONSTRAINT [{constraint_name}] DEFAULT {default_expr} FOR [{col}]"
                            )
                    full_datatype = f"{datatype}{inline_default}"
                    tables[(schema, table)].append(TableColumn(schema, table, col, full_datatype, nullable))

    return tables, constraints

def ParseIndexes(sql_text):
    return re.findall(r'(CREATE\s+NONCLUSTERED\s+INDEX\s+\[\w+\][^;]+);', sql_text, re.IGNORECASE | re.DOTALL)

def GetDbColumns(connection):
    cursor = connection.cursor()
    cursor.execute("""
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;
""")
    db_schema = defaultdict(list)
    for row in cursor.fetchall():
        db_schema[(row.TABLE_SCHEMA, row.TABLE_NAME)].append(
            TableColumn(row.TABLE_SCHEMA, row.TABLE_NAME, row.COLUMN_NAME, row.DATA_TYPE, row.IS_NULLABLE == 'YES')
        )
    return db_schema

def GetExistingConstraints(connection):
    cursor = connection.cursor()
    cursor.execute("""
SELECT 
    PARSENAME(table_view, 2) AS [SchemaName],
    PARSENAME(table_view, 1) AS [TableName],
    constraint_type AS [ConstraintType],
    constraint_name AS [ConstraintName],
    details AS Details
FROM (
    SELECT 
        SCHEMA_NAME(t.schema_id) + '.' + t.name AS table_view,
        CASE 
            WHEN c.type = 'PK' THEN 'Primary key'
            WHEN c.type = 'UQ' THEN 'Unique constraint'
            WHEN i.type = 1 THEN 'Unique clustered index'
            WHEN i.type = 2 THEN 'Unique index'
        END AS constraint_type,
        ISNULL(c.name, i.name) AS constraint_name,
        SUBSTRING(column_names, 1, LEN(column_names) - 1) AS details
    FROM sys.objects t
    LEFT JOIN sys.indexes i ON t.object_id = i.object_id
    LEFT JOIN sys.key_constraints c ON i.object_id = c.parent_object_id AND i.index_id = c.unique_index_id
    CROSS APPLY (
        SELECT col.name + ', '
        FROM sys.index_columns ic
        JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
        WHERE ic.object_id = t.object_id AND ic.index_id = i.index_id
        ORDER BY col.column_id
        FOR XML PATH('')
    ) D (column_names)
    WHERE i.is_unique = 1 AND t.is_ms_shipped = 0
    UNION ALL
    SELECT 
        SCHEMA_NAME(fk_tab.schema_id) + '.' + fk_tab.name,
        'Foreign key',
        fk.name,
        SCHEMA_NAME(pk_tab.schema_id) + '.' + pk_tab.name
    FROM sys.foreign_keys fk
    JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
    JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
    UNION ALL
    SELECT 
        SCHEMA_NAME(t.schema_id) + '.' + t.name,
        'Check constraint',
        con.name,
        con.definition
    FROM sys.check_constraints con
    JOIN sys.objects t ON con.parent_object_id = t.object_id
    UNION ALL
    SELECT 
        SCHEMA_NAME(t.schema_id) + '.' + t.name,
        'Default constraint',
        con.name,
        col.name + ' = ' + con.definition
    FROM sys.default_constraints con
    JOIN sys.objects t ON con.parent_object_id = t.object_id
    JOIN sys.all_columns col ON con.parent_column_id = col.column_id AND con.parent_object_id = col.object_id
) AS a
ORDER BY SchemaName, TableName, ConstraintType, ConstraintName;
""")
    
    db_constraints = defaultdict(list)
    for row in cursor.fetchall():
        if row.ConstraintType == 'Foreign key':
            db_constraints[(row.SchemaName, row.TableName)].append(f"FOREIGN KEY REFERENCES {row.ConstraintName}")
        elif row.ConstraintType == 'Check constraint':
            db_constraints[(row.SchemaName, row.TableName)].append(f"CHECK ({row.ConstraintName})")
        elif row.ConstraintType == 'Default constraint':
            db_constraints[(row.SchemaName, row.TableName)].append(f"DEFAULT {row.Details}")
        else:
            db_constraints[(row.SchemaName, row.TableName)].append(f"{row.ConstraintType} [{row.ConstraintName}]")
    return db_constraints    

def GetExistingIndexes(connection):
    cursor = connection.cursor()
    cursor.execute("""
SELECT s.name AS SchemaName, t.name AS TableName, i.name AS IndexName
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.is_primary_key = 0 AND i.is_unique_constraint = 0
""")
    return set(f"[{row.SchemaName}].[{row.TableName}].[{row.IndexName}]" for row in cursor.fetchall())

def GenerateCreateTableStatement(schema, table, columns, constraints):
    col_defs = [f"[{col.column}] {col.datatype} {'NULL' if col.nullable else 'NOT NULL'}" for col in columns]

    # Only include constraints that are not 'FOR' style (those are ALTER-only)
    filtered_constraints = [
        c for c in constraints
        if not re.search(r'\bFOR\s+\[', c, re.IGNORECASE)
    ]

    col_block = ",\n    ".join(col_defs)
    constr_block = ",\n    ".join(filtered_constraints)
    full = f"{col_block},\n    {constr_block}" if filtered_constraints else col_block

    return f"\nCREATE TABLE [{schema}].[{table}] (\n    {full};"

def GenerateAlterStatement(db_cols, project_cols, project_constraints):
    alter_statements = []
    removed_columns_log = []

    Normalized_db_cols = {
        (Normalize(schema), Normalize(table)): cols
        for (schema, table), cols in db_cols.items()
    }

    for (schema, table), cols in project_cols.items():
        norm_key = (Normalize(schema), Normalize(table))
        if norm_key not in Normalized_db_cols:
            alter_statements.append(
                GenerateCreateTableStatement(schema, table, cols, project_constraints.get((schema, table), []))
            )
            continue

        existing_cols = {
            Normalize(col.column): col for col in Normalized_db_cols[norm_key]
        }
        project_col_map = {
            Normalize(col.column): col for col in cols
        }

        for col_name, col in project_col_map.items():
            if col_name not in existing_cols:
                alter_statements.append(
                    f"ALTER TABLE [{schema}].[{table}] ADD [{col.column}] {col.datatype} {'NULL' if col.nullable else 'NOT NULL'};"
                )

        for col_name in existing_cols:
            if col_name not in project_col_map:
                removed_columns_log.append(
                    f"-- Column exists in DB but not in project: [{schema}].[{table}].[{col_name}]"
                )

    return alter_statements, removed_columns_log

def VerifyColumns(sql_files, expected_columns):
    found = set()
    for path in sql_files:        
        if not os.path.exists(path):
            continue
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read().lower()  # normalize content
            for schema, table, column in expected_columns:
                if f"[{column.lower()}]" in content:
                    found.add((schema, table, column))
    return sorted(expected_columns - found)


def CheckDefaultConstraint(conn, schema, table, column):
    cursor = conn.cursor()
    cursor.execute("""
SELECT 1
FROM sys.default_constraints dc
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = ? AND t.name = ? AND c.name = ?
    """, (schema, table, column))
    return cursor.fetchone() is not None

def CheckUniqueConstraint(conn, schema, table, constraint_name):
    cursor = conn.cursor()
    cursor.execute("""
SELECT 1
FROM sys.objects o
JOIN sys.tables t ON o.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE o.type = 'UQ'
AND o.name = ? AND t.name = ? AND s.name = ?
    """, (constraint_name, table, schema))
    return cursor.fetchone() is not None

def GetSchemaBoundViewsAndChildren(conn):
    cursor = conn.cursor()
    cursor.execute("""
SELECT distinct
    sv.name AS SchemaBoundView,
    sv_schema.name AS ViewSchema,
    ro.name AS ReferencedObject,
    ro_schema.name AS ReferencedSchema,
    ro.type_desc AS ReferencedType
FROM sys.sql_expression_dependencies dep
JOIN sys.views sv ON dep.referencing_id = sv.object_id
JOIN sys.schemas sv_schema ON sv.schema_id = sv_schema.schema_id
JOIN sys.objects ro ON dep.referenced_id = ro.object_id
JOIN sys.schemas ro_schema ON ro.schema_id = ro_schema.schema_id
WHERE EXISTS (SELECT 1 FROM sys.sql_modules m WHERE m.object_id = sv.object_id AND m.definition LIKE '%SCHEMABINDING%')
ORDER BY sv_schema.name, sv.name, ro_schema.name, ro.name;
""")
    
    return cursor.fetchall()

def GetNonSchemaBoundViewsAndChildren(conn):    
    cursor = conn.cursor()
    cursor.execute("""
SELECT DISTINCT
    v_schema.name AS ViewSchema,
    v.name AS ViewName,
    ref_schema.name AS ReferencedSchema,
    ref.name AS ReferencedObject,
    ref.type_desc AS ReferencedType
FROM sys.views v
JOIN sys.schemas v_schema ON v.schema_id = v_schema.schema_id
JOIN sys.sql_expression_dependencies dep ON v.object_id = dep.referencing_id
LEFT JOIN sys.objects ref ON dep.referenced_id = ref.object_id
LEFT JOIN sys.schemas ref_schema ON ref.schema_id = ref_schema.schema_id
WHERE NOT EXISTS (
SELECT 1 FROM sys.sql_modules m WHERE m.object_id = v.object_id AND m.definition LIKE '%SCHEMABINDING%')
ORDER BY v_schema.name, v.name, ref_schema.name, ref.name;
""")
    
    return cursor.fetchall()     

def ParseCreateView(sql_text):
    views = {}
    match = re.search(r'CREATE\s+VIEW\s+\[?(\w+)\]?\.\[?(\w+)\]?', sql_text, re.IGNORECASE)
    if match:
        schema, name = match.groups()
        cleaned_sql = sql_text.replace('\ufeff', '').replace('GO', '').strip()
        views[(schema, name)] = cleaned_sql
    return views

def ParseForeignKeys(content):
    fk_refs = defaultdict(set)
    table_match = re.search(r'CREATE\s+TABLE\s+\[(\w+)\]\s*\.\s*\[(\w+)\]', content, re.IGNORECASE)
    if not table_match:
        return fk_refs
    schema, table = table_match.group(1), table_match.group(2)
    for match in re.finditer(r'FOREIGN\s+KEY\s*\(.*?\)\s*REFERENCES\s+\[(\w+)\]\s*\.\s*\[(\w+)\]', content, re.IGNORECASE):
        ref_schema, ref_table = match.group(1), match.group(2)
        fk_refs[(schema, table)].add((ref_schema, ref_table))
    return fk_refs

def ResolveForeignKeyOrder(project_schema, fk_dependencies):
    visited = set()
    result = []

    def visit(table):
        if table in visited:
            return
        visited.add(table)
        for dep in fk_dependencies.get(table, []):
            visit(dep)
        result.append(table)

    for table in project_schema:
        visit(table)
    return result

def Normalize(name):
    return name.lower().strip("[] ") if name else name

def ExecuteStatements(conn, statements, log):
    cursor = conn.cursor()
    for stmt in statements:
        log.append(stmt)
        print(stmt)
        try:
            cursor.execute(stmt)
            conn.commit()
        except Exception as e:
            log.append(f"\n-- ERROR executing: \n{stmt}\n-- {e}")
            print(f"ERROR: {e}")
    cursor.close()

def Step1CreateTablesIfMissing(conn, creation_order, db_schema, project_schema, project_constraints):
    create_statements = []
    for (schema, table) in creation_order:
        if debug:
            print(f"Checking for missing table - [{schema}].[{table}]")
        if (schema, table) not in db_schema:
            stmt = GenerateCreateTableStatement(schema, table, project_schema[(schema, table)], project_constraints.get((schema, table), []))
            create_statements.append(stmt)
    return create_statements

def Step2AddColumnsIfMissing(conn, db_schema, project_schema):
    alter_statements = []
    for (schema, table), cols in project_schema.items():
        if debug:
            print(f"Checking for missing column - [{schema}].[{table}]")
        existing_cols = {Normalize(c.column): c for c in db_schema.get((schema, table), [])}
        for col in cols:
            if Normalize(col.column) not in existing_cols:
                default_match = re.search(r'CONSTRAINT\s+\[(\w+)\]\s+DEFAULT\s+(.+)', col.datatype, re.IGNORECASE)
                if default_match:
                    constraint_name = default_match.group(1)
                    default_value = default_match.group(2).strip()
                    stmt = (
                        f"\nALTER TABLE [{schema}].[{table}] "
                        f"ADD [{col.column}] {col.datatype.split('CONSTRAINT')[0].strip()} "
                        f"CONSTRAINT [{constraint_name}] DEFAULT {default_value}"
                    )
                else:
                    stmt = f"\nALTER TABLE [{schema}].[{table}] ADD [{col.column}] {col.datatype}"
                alter_statements.append(stmt)       
    return alter_statements

def Step3AddConstraintsIfMissing(conn, project_constraints):
    alter_statements = []
    for (schema, table), constraints in project_constraints.items():
        for constraint in constraints:
            is_default = "DEFAULT" in constraint.upper()
            is_unique = "UNIQUE" in constraint.upper()
            if debug:
                print(f"[{schema}].[{table}].{constraint} is default: {is_default}, Is unique: {is_unique}")

            if is_default:
                inline_default_match = re.search(
                    r'\[([^\]]+)\]\s+[^\s]+\s+(?:NOT\s+NULL|NULL)?\s+CONSTRAINT\s+\[([^\]]+)\]\s+DEFAULT',
                    constraint,
                    re.IGNORECASE
                )                
                if inline_default_match:
                    if debug:
                        print(f"Inline default constraint found: {constraint}")
                    col_name, constraint_name = inline_default_match.groups()
                    if not CheckDefaultConstraint(conn, schema, table, col_name):
                        alter_statements.append(f"ALTER TABLE [{schema}].[{table}] ADD CONSTRAINT [{constraint_name}] DEFAULT GETUTCDATE() FOR [{col_name}]")
                else:
                    if debug:
                        print(f"ALTER-style default constraint found: {constraint}")
                    for_clause_match = re.search(r'CONSTRAINT\s+\[([^\]]+)\].+?FOR\s+\[([^\]]+)\]', constraint, re.IGNORECASE)
                    if for_clause_match:
                        constraint_name, col_name = for_clause_match.groups()
                        if not CheckDefaultConstraint(conn, schema, table, col_name):
                            alter_statements.append(f"ALTER TABLE [{schema}].[{table}] ADD {constraint}")

            elif is_unique:
                if debug:
                    print(f"Unique constraint found: {constraint}")
                name_match = re.search(r'CONSTRAINT\s+\[(\w+)\]', constraint, re.IGNORECASE)
                if name_match:
                    constraint_name = name_match.group(1)
                    if not CheckUniqueConstraint(conn, schema, table, constraint_name):
                        alter_statements.append(f"ALTER TABLE [{schema}].[{table}] ADD {constraint}")
    return alter_statements

def Step4AddIndexesIfMissing(conn, raw_index_statements, existing_indexes):
    alter_statements = []
    for raw_index in raw_index_statements:
        index_match = re.search(r'CREATE\s+NONCLUSTERED\s+INDEX\s+\[(\w+)\]\s+ON\s+\[(\w+)\]\s*\.\s*\[(\w+)\]', raw_index, re.IGNORECASE)
        if index_match:
            index_name = index_match.group(1)
            schema = index_match.group(2)
            table = index_match.group(3)
            full_name = f"[{schema}].[{table}].[{index_name}]"
            if full_name in existing_indexes:
                continue
        alter_statements.append(raw_index)
    return alter_statements

def Step5LogMissingProjectColumns(sql_files, db_schema, all_project_columns):
    expected_columns = set()
    for (schema, table), cols in db_schema.items():        
        for col in cols:
            if debug:
                print(f"Checking [{schema}].[{table}].{col.column}")
            col_key = (Normalize(schema), Normalize(table), Normalize(col.column))
            if col_key not in all_project_columns:
                expected_columns.add(col_key)

    return VerifyColumns(sql_files, expected_columns)

def Step6LogMissingProjectConstraints(db_constraints, all_project_constraints):
    def extract_constraint_names(constraint_list):
        names = set()
        for raw in constraint_list:
            matches = re.findall(r'\bCONSTRAINT\s+\[([^\]]+)\]', raw, re.IGNORECASE)
            if not matches:
                # Fallbacks
                matches = re.findall(r'\[([^\]]+)\]', raw)
            for name in matches:
                names.add(Normalize(name))
        return names

    # Flatten project constraints
    project_constraint_keys = set()
    for (schema, table), constraints in all_project_constraints.items():
        names = extract_constraint_names(constraints)
        for name in names:
            project_constraint_keys.add((Normalize(schema), Normalize(table), name))

    # Check DB constraints against project ones
    missing_constraints = set()
    for (schema, table), constraints in db_constraints.items():
        names = extract_constraint_names(constraints)
        for name in names:
            key = (Normalize(schema), Normalize(table), name)
            if key not in project_constraint_keys:
                missing_constraints.add(key)

    if debug:
        print("Extracted DB Constraints:", sorted(list(missing_constraints)))
        print("All Project Constraints:", sorted(list(project_constraint_keys)))

    return sorted(missing_constraints)

def Step9AddViewsIfMissing(conn, project_views, project_schema):
    alter_statements = []
    schema_bound_views = GetSchemaBoundViewsAndChildren(conn)
    non_schema_bound_views = GetNonSchemaBoundViewsAndChildren(conn)

    for (schema, table), sql_text in project_views.items():
        if debug:
            print(f"Checking for missing view - [{schema}].[{table}]")
        if (schema, table) not in schema_bound_views and (schema, table) not in non_schema_bound_views:
            alter_statements.append(sql_text)
        else:
            for row in schema_bound_views:
                if row.SchemaBoundView == f"{schema}.{table}":
                    alter_statements.append(f"DROP VIEW [{schema}].[{table}];\n{sql_text}")
                    break
            for row in non_schema_bound_views:
                if row.ViewName == f"{schema}.{table}":
                    alter_statements.append(f"DROP VIEW [{schema}].[{table}];\n{sql_text}")
                    break
                
    return alter_statements

# ------------------- MAIN -----------------------

def main():
    log = []
    global project_dir, sqlproj_file, server, user, password

    configurationItems = secrets.GetSecrets()
    project_dir = configurationItems.get("ProjectDir", "")
    sqlproj_file = configurationItems.get("SQLProjFile", "")
    server = configurationItems.get("Server", "")
    user = configurationItems.get("User", "")
    password = configurationItems.get("Password", "")    

    sqlproj_path = os.path.join(project_dir, sqlproj_file)
    sql_files = ParseProjectFile(sqlproj_path)

    project_schema = defaultdict(list)
    project_constraints = defaultdict(list)
    raw_index_statements = []
    all_project_columns = set()
    fk_dependencies = defaultdict(set)
    project_views = {}

    for file_path in sql_files:
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                table_data, constraint_data = ParseCreateTable(content)
                index_data = ParseIndexes(content)
                fk_refs = ParseForeignKeys(content)
                views = ParseCreateView(content)  # returns dict {(schema, name): sql_text}
                if views:
                    for (schema, name) in views.items():
                        if debug:
                            print(f"View found: [{schema}].[{name}]")
                    project_views.update(views)

                for k, v in table_data.items():
                    project_schema[k].extend(v)
                    for col in v:
                        col_key = (Normalize(col.schema), Normalize(col.table), Normalize(col.column))
                        all_project_columns.add(col_key)
                for k, v in constraint_data.items():
                    project_constraints[k].extend(v)
                raw_index_statements.extend(index_data)
                for k, v in fk_refs.items():
                    fk_dependencies[k].update(v)

    creation_order = ResolveForeignKeyOrder(project_schema, fk_dependencies)

    for database in databases:
    # === STEP 1: Create tables if missing ===        
        if debug:
            log.append(f"\n-- STEP 1: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            db_schema = GetDbColumns(conn)
            statements = Step1CreateTablesIfMissing(conn, creation_order, db_schema, project_schema, project_constraints)
            ExecuteStatements(conn, statements, log)

    # === STEP 2: Add columns if missing ===
        if debug:
            log.append(f"\n-- STEP 2: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            db_schema = GetDbColumns(conn)
            statements = Step2AddColumnsIfMissing(conn, db_schema, project_schema)
            ExecuteStatements(conn, statements, log)

    # === STEP 3: Add constraints if missing ===
        if debug:
            log.append(f"\n-- STEP 3: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            statements = Step3AddConstraintsIfMissing(conn, project_constraints)
            cleaned_statements = [stmt.replace(" NOT ", " ").replace(" NULL ", " ") for stmt in statements]
            ExecuteStatements(conn, cleaned_statements, log)
            # ExecuteStatements(conn, statements, log)

    # === STEP 4: Add indexes if missing ===
        if debug:
            log.append(f"\n-- STEP 4: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            existing_indexes = GetExistingIndexes(conn)
            statements = Step4AddIndexesIfMissing(conn, raw_index_statements, existing_indexes)
            ExecuteStatements(conn, statements, log)

    # === STEP 5: Log columns that exist in DB but not project ===
        if debug:
            log.append(f"\n-- STEP 5: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            db_schema = GetDbColumns(conn)
            missing = Step5LogMissingProjectColumns(sql_files, db_schema, all_project_columns)
            for schema, table, column in missing:
                log.append(f"\n-- CONFIRMED MISSING: [{schema}].[{table}].[{column}] not found in any project file")

    # === STEP 6: Log constraints that exist in DB but not project ===
        if debug:
            log.append(f"\n-- STEP 6: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            db_constraints = GetExistingConstraints(conn)
            missing = Step6LogMissingProjectConstraints(db_constraints, project_constraints)
            for schema, table, constraint in missing:
                log.append(f"\n-- CONFIRMED MISSING: [{schema}].[{table}].{constraint} not found in any project file")

    # === STEP 7: Add/Alter functions if they are missing or different ===
        if debug:
            log.append(f"\n-- STEP 7: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            # Placeholder for function handling
            pass

    # === STEP 8: Add/Alter stored procedures if they are missing or different ===
        if debug:
            log.append(f"\n-- STEP 8: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            # Placeholder for stored procedure handling
            pass

    # === Step 9: Add/Alter Views if they are missing or different. If schema bound items may need to be removed and re-added ===
        if debug:
            log.append(f"\n-- STEP 9: {database}")
        with ConnectToDatabase(server, database, user, password) as conn:
            db_views = Step9AddViewsIfMissing(conn, project_views, project_schema)
            
            if debug:
                print("Generated View Statements:")
                for stmt in db_views:
                    print(stmt)

            for view_stmt in db_views:
                log.append(f"\n-- VIEW: {view_stmt}")
                try:
                    conn.execute(view_stmt)
                    conn.commit()
                except Exception as e:
                    log.append(f"\n-- ERROR executing: \n{view_stmt}\n-- {e}")
                    print(f"ERROR executing view statement:\n{view_stmt}\nException: {e}")

    # === Write log ===
    log_path = WriteLog(log_output_dir, log)
    print(f"Log written to: {log_path}")

if __name__ == "__main__":
    main()