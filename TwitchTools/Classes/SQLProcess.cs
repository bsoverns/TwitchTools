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

        string _GetAccountsInfo = @"dbo.GetAccounts";

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

        public DataTable GetActiveStockList(SQLConnectionClass SQLConnect)
        {
            DataTable returnTable = new DataTable();
            returnTable.Clear();

            try
            {
                if (SQLConnect.UseIPAdress == true)
                {
                    IPAddress ip = new IPHelper().get_ip_from_host_name(SQLConnect.DataSource);

                    using (System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection("Data Source=" + SQLConnect.DataSource + ";Initial Catalog=" + SQLConnect.InitialCatalog + ";User ID=" + SQLConnect.UserID + ";Password=" + SQLConnect.Password + ";Connect Timeout = 60;"))
                    {
                        using (SqlCommand cmd = new SqlCommand(_GetAccountsInfo, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            using (SqlDataAdapter readActiveStocks = new SqlDataAdapter(cmd))
                            {
                                readActiveStocks.Fill(returnTable);

                                //using (DataTable tempStorageTable = new DataTable())
                                //{
                                //    readActiveStocks.Fill(tempStorageTable);
                                //    returnTable = tempStorageTable;
                                //}
                            }
                        }
                    }
                }

                else
                {
                    using (System.Data.SqlClient.SqlConnection con = new System.Data.SqlClient.SqlConnection("Data Source=" + SQLConnect.DataSource + ";Initial Catalog=" + SQLConnect.InitialCatalog + ";User ID=" + SQLConnect.UserID + ";Password=" + SQLConnect.Password + ";Connect Timeout = 60;"))
                    {
                        using (SqlCommand cmd = new SqlCommand(_GetAccountsInfo, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            using (SqlDataAdapter readActiveStocks = new SqlDataAdapter(cmd))
                            {
                                readActiveStocks.Fill(returnTable);
                            }
                        }
                    }
                }

                if (returnTable.Rows.Count == 0)
                {
                    SqlConnection sqlConnString = new SqlConnection("Data Source=" + SQLConnect.DataSource + ";Initial Catalog=" + SQLConnect.InitialCatalog + ";User ID=" + SQLConnect.UserID + ";Password=" + SQLConnect.Password + ";Connect Timeout = 60;");

                    SqlDataAdapter readStuff = new SqlDataAdapter(_GetAccountsInfo, sqlConnString);

                    sqlConnString.Open();
                    readStuff.Fill(returnTable);
                    sqlConnString.Close();
                }

                return returnTable;
            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.ToString());
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