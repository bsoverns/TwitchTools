using System;
using System.Data;
using System.IO;
using System.Xml;

namespace TwitchTools
{
    class SQLSettings
    {
        public bool SaveStockData(SQLConnectionClass SqlConnectData)
        {
            bool _saveStatusReturn = false;
            //string _main_path = AppDomain.CurrentDomain.BaseDirectory;
            string _main_path = (@"C:\SandboxFiles\JsonTest\TwitchTools\");
            string _File_name = (@"SqlSettings.xml");
            string _combine = System.IO.Path.Combine(_main_path, _File_name);
            string SqlDbKey = SqlConnectData.DataSource + "|||" + SqlConnectData.InitialCatalog + "|||" + SqlConnectData.UserID + "|||" + SqlConnectData.Password + "|||" + Convert.ToString(SqlConnectData.UseIPAdress);
            string encryptPatientDbKey = EncryptionClass.Encrypt(SqlDbKey);

            try
            {
                XmlWriterSettings settings = new XmlWriterSettings();
                settings.Indent = true;
                settings.IndentChars = ("\t");

                if (!Directory.Exists(_main_path))
                {
                    Directory.CreateDirectory(_main_path);
                }

                XmlWriter xmlOut = XmlWriter.Create(_combine, settings);
                xmlOut.WriteStartDocument();
                xmlOut.WriteStartElement("SQLSettings");
                xmlOut.WriteAttributeString("SqlDbKey", encryptPatientDbKey);

                xmlOut.WriteEndElement();
                xmlOut.WriteEndDocument();
                xmlOut.Close();

                _saveStatusReturn = true;
            }

            catch (Exception ex)
            {
                //MessageBox.Show(ex.ToString());
            }

            return _saveStatusReturn;
        }

        public string[] LoadSqlFile()
        {
            string SqlDbKey = "";
            string[] separators = { "|||" };
            string[] _loadStatusReturn = null;
            //string _main_path = AppDomain.CurrentDomain.BaseDirectory;
            string _main_path = (@"C:\SandboxFiles\JsonTest\TwitchTools\");
            string _File_name = (@"SqlSettings.xml");
            string _combine = System.IO.Path.Combine(_main_path, _File_name);

            if (File.Exists(_combine) == false)
            {
                try
                {
                    _loadStatusReturn = null;
                }

                catch (Exception ex)
                {
                    //MessageBox.Show("Error clearing out SQLConnect: " + ex.ToString());
                }
            }

            if (File.Exists(_combine) == true)
            {
                try
                {
                    XmlReaderSettings settings = new XmlReaderSettings();
                    settings.IgnoreWhitespace = true;
                    settings.IgnoreComments = true;

                    XmlReader xmlIn = XmlReader.Create(_combine, settings);

                    if (xmlIn.ReadToDescendant("SQLSettings"))
                    {
                        SqlDbKey = xmlIn["SqlDbKey"].ToString();
                    }

                    string[] SplitKey = EncryptionClass.Decrypt(SqlDbKey).Split(separators, StringSplitOptions.RemoveEmptyEntries);

                    xmlIn.Close();

                    _loadStatusReturn = SplitKey;
                }

                catch (Exception ex)
                {
                    //MessageBox.Show(ex.ToString());
                }
            }

            return _loadStatusReturn;
        }
    }
}
