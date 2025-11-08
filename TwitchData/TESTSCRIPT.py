import re

# Sample constraint lines from a CREATE TABLE statement
create_table_sql = """
CREATE TABLE [dbo].[Users]
(
  [UserId] INT IDENTITY(1, 1) NOT NULL,
  [TwitchUserId] VARCHAR(50) NULL,
  [UserName] VARCHAR(50) NOT NULL,
  [FirstInteractionDateTimeUtc] DATETIME NOT NULL CONSTRAINT [DF_Users_FirstInteractionDateTimeUtc] DEFAULT GETUTCDATE(),
  [LastInteractionDateTimeUtc] DATETIME,
  CONSTRAINT [PK_Users_UserId] PRIMARY KEY CLUSTERED ([UserId] ASC),
  CONSTRAINT [UQ_Users_UserName] UNIQUE ([UserName] ASC)
);
"""

# Extract constraints and lines
lines = re.split(r',(?![^()]*\))', create_table_sql)
inline_defaults = []
alter_defaults = []
unique_constraints = []

for line in lines:
    line = line.strip()

    # Pattern 1: Inline default constraint
    inline_default_match = re.search(
        r'\[([^\]]+)\]\s+[^\s]+\s+(?:NOT\s+NULL|NULL)?\s+CONSTRAINT\s+\[([^\]]+)\]\s+DEFAULT\s+(.+)',
        line, re.IGNORECASE
    )
    if inline_default_match:
        col_name, constraint_name, default_expr = inline_default_match.groups()
        inline_defaults.append((col_name, constraint_name, default_expr.strip()))
        continue

    # Pattern 2: ALTER-style default constraint with FOR
    for_clause_match = re.search(
        r'CONSTRAINT\s+\[([^\]]+)\]\s+DEFAULT\s+(.+?)\s+FOR\s+\[([^\]]+)\]',
        line, re.IGNORECASE
    )
    if for_clause_match:
        constraint_name, default_expr, col_name = for_clause_match.groups()
        alter_defaults.append((col_name, constraint_name, default_expr.strip()))
        continue

    # Unique constraint
    if "UNIQUE" in line.upper():
        name_match = re.search(r'CONSTRAINT\s+\[(\w+)\]', line, re.IGNORECASE)
        if name_match:
            constraint_name = name_match.group(1)
            unique_constraints.append((constraint_name, line))

inline_defaults, alter_defaults, unique_constraints
print ("Inline Defaults:", inline_defaults)
print ("Alter Defaults:", alter_defaults)
print ("Unique Constraints:", unique_constraints)