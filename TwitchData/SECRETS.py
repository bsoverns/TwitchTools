project_dir = r"C:\Sandbox\TwitchTools\TwitchData"
sqlproj_file = "TwitchData.sqlproj"
server = "BRADHP"
user = "sa"
password = "Tenet007"

def GetSecrets():
    return {
        "ProjectDir": project_dir,
        "SQLProjFile": sqlproj_file,
        "Server": server,
        "User": user,
        "Password": password
    }