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
        #region SQLCodeActions

        #region SQLQueries

        string _GetUser = @"SELECT * 
FROM [dbo].[vGetUser]";

        string _GetUserChat = @"SELECT * 
FROM [dbo].[vGetUserChat]";

        string _GetUserChatFlagged = @"SELECT *
FROM [dbo].[vGetUserChatFlagged]";

        string _GetUnModeratedChat = @"SELECT TOP 100 ChatId, ChatMessage FROM [dbo].[vGetUncheckedChatsForModeration] ORDER BY TimeStampUtc";

        string _GetChannelNames = @"SELECT ChannelName, ChannelOrder FROM [dbo].[Channels] ORDER BY ChannelOrder, ChannelName";

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

        #endregion SQLCodeActions

        #region SQLMethods

        public DataTable GetUserChat(string UserName, string QueryType, bool IsFlagged, string ChannelName, SQLConnectionClass SQLConnect)
        {
            DataTable returnTable = new DataTable();
            returnTable.Clear();
            string _UserChatquery = IsFlagged ? _GetUserChatFlagged : _GetUserChat;
            string? _WhereClause = "";
            bool whereIsUsed = false;

            switch (QueryType)
            {
                case "EQUAL":
                    _WhereClause = "\r\nWHERE UserName = @UserName";
                    whereIsUsed = true;
                    break;
                case "LIKE":
                    _WhereClause = "\r\nWHERE UserName LIKE @UserName";
                    whereIsUsed = true;
                    break;
                case "NONE":
                    _WhereClause = null;
                    break;
                default:
                    _WhereClause = null;
                    break;
            }

            if (ChannelName != null)
            {
                switch (ChannelName)
                {
                    case "ALL":                        
                        break;
                    default:
                        if (whereIsUsed)
                        {
                            _WhereClause += " AND ChannelName = @ChannelName";
                        }
                        else
                        {
                            _WhereClause = "\r\nWHERE ChannelName = @ChannelName";
                        }
                        break;
                }
            }

            if (_WhereClause != null)
            {
                _UserChatquery = IsFlagged ? _GetUserChatFlagged : _GetUserChat + _WhereClause + "\r\nORDER BY UserName, TimeStampUtc DESC";
            }

            else
            {
                _UserChatquery = IsFlagged ? _GetUserChatFlagged : _GetUserChat + "\r\nORDER BY TimeStampUtc DESC";
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

                        if (ChannelName != "ALL")
                        {
                            cmd.Parameters.AddWithValue("@ChannelName", ChannelName);
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

        #endregion SQLMethods
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