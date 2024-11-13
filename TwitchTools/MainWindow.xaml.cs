using System.Data;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace TwitchTools
{   
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        SQLConnectionClass SQLConnectDb = new SQLConnectionClass();

        public MainWindow()
        {
            InitializeComponent();
            LoadSettings();
        }

        #region Loaders
        private void LoadSettings()
        {
            LoadSqlSettings();
        }

        private void LoadSqlSettings()
        {
            SQLSettings loadSQLSettings = new SQLSettings();
            string[] sqlSettings = loadSQLSettings.LoadSqlFile();
            if (sqlSettings != null)
            {
                SQLConnectDb.DataSource = sqlSettings[0];
                SQLConnectDb.InitialCatalog = sqlSettings[1];
                SQLConnectDb.UserID = sqlSettings[2];
                SQLConnectDb.Password = sqlSettings[3];
                SQLConnectDb.UseIPAdress = Convert.ToBoolean(sqlSettings[4]);
            }
            else
            {
                // Show dialog to input SQL settings if they don't exist
                SqlConnectionWindow sqlConnectionWindow = new SqlConnectionWindow();
                bool? result = sqlConnectionWindow.ShowDialog();

                if (result == true)
                {
                    // Reload settings after successful save
                    sqlSettings = loadSQLSettings.LoadSqlFile();
                    if (sqlSettings != null)
                    {
                        SQLConnectDb.DataSource = sqlSettings[0];
                        SQLConnectDb.InitialCatalog = sqlSettings[1];
                        SQLConnectDb.UserID = sqlSettings[2];
                        SQLConnectDb.Password = sqlSettings[3];
                        SQLConnectDb.UseIPAdress = Convert.ToBoolean(sqlSettings[4]);
                    }
                }
            }
        }

        #endregion Loaders
    }
}