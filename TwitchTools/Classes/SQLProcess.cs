using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Net;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Xml;

namespace TwitchTools
{
    class SQLProcess
    {
        #region SQLCode

        #region SQLQueries

        string _GetUser = @"SELECT * 
FROM [dbo].[vGetUser]";

        string _GetUserChat = @"SELECT * 
FROM [dbo].[vGetUserChat]";

        string _GetUnModeratedChat = @"SELECT TOP 100 ChatId, ChatMessage FROM [dbo].[vGetUncheckedChatsForModeration] ORDER BY TimeStampUtc"
;
        #endregion SQLQueries

        #region SQLInsert 
        string _InsertApiCount = @"dbo.InsertApiCallCount";

        #endregion SQLInsert

        #region SQLUpdates

        string _UpdateAccessAuthorizations = @"UPDATE dbo.Authorizations
SET AccessToken = @AccessToken,
	AccessTokenExpiresIn = @AccessExpire,
    AccessTokenExpireTimeUtc = DATEADD(SECOND, @AccessExpire, GETUTCDATE()),
	RedirectUrl = 'http://localhost'
WHERE AuthorizationId = 2";      

        #endregion SQLUpdates

        #region SQLUpsert

        string _UpsertAccounts = @"dbo.UpsertAccounts";

        #endregion SQLUpsert      

        #region SQLDelete

        string _DeleteOldApiCallLogs = @"[dbo].[DeleteOldApiCount]";

        #endregion SQLDelete

        #endregion SQLCode

        public DataTable GetUserChat(string UserName, string QueryType, SQLConnectionClass SQLConnect)
        {
            DataTable returnTable = new DataTable();
            returnTable.Clear();
            string _UserChatquery = _GetUserChat;
            string? _WhereClause = "";

            switch (QueryType)
            {
                case "EQUAL":
                    _WhereClause = "\r\nWHERE UserName = @UserName";
                    break;
                case "LIKE":
                    _WhereClause = "\r\nWHERE UserName LIKE @UserName";
                    break;
                case "NONE":
                    _WhereClause = null;
                    break;
                default:
                    _WhereClause = null;
                    break;
            }

            if (_WhereClause != null)
            {
                _UserChatquery = _GetUserChat + _WhereClause + "\r\nORDER BY UserName, TimeStampUtc DESC";
            }
            else
            {
                _UserChatquery = _GetUserChat + "\r\nORDER BY TimeStampUtc DESC";
            }

            try
            {
                using (SqlConnection con = new SqlConnection("Data Source=" + SQLConnect.DataSource + ";Initial Catalog=" + SQLConnect.InitialCatalog + ";User ID=" + SQLConnect.UserID + ";Password=" + SQLConnect.Password + ";Connect Timeout = 60;"))
                {
                    using (SqlCommand cmd = new SqlCommand(_UserChatquery, con))
                    {
                        cmd.CommandType = CommandType.Text;
                        if (QueryType == "EQUAL")
                        {
                            cmd.Parameters.AddWithValue("@UserName", UserName);
                        }
                        else if (QueryType == "LIKE")
                        {
                            cmd.Parameters.AddWithValue("@UserName", UserName + "%");
                        }

                        using (SqlDataAdapter readUserChats = new SqlDataAdapter(cmd))
                        {
                            readUserChats.Fill(returnTable);
                        }
                    }
                }
                return returnTable;
            }
            catch (Exception ex)
            {
                // Consider logging the exception
                return returnTable;
            }
            finally
            {
                returnTable.Dispose();
            }
        }

        public string cleanCode(string item)
        {
            Regex digitsOnly = new Regex(@"[^\d]");
            return digitsOnly.Replace(item, "");
        }

        public string cleanBody(string body)
        {
            string newBody = body.Replace("\r\n", "\r");
            newBody = newBody.Replace("\n", "\r");
            newBody = newBody.Replace("\r", "\r\n");
            return newBody;
        }
    }
}