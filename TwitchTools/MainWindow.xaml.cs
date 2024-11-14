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
using System.Windows.Threading;

namespace TwitchTools
{   
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        SQLConnectionClass SQLConnectDb = new SQLConnectionClass();
        //System.Timers.Timer Timer = new System.Timers.Timer();        

        public MainWindow()
        {
            InitializeComponent();
            LoadSettings();
        }

        #region Loaders
        private void LoadSettings()
        {
            LoadSqlSettings();
            StartTimers();
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

        private DispatcherTimer Timer = new DispatcherTimer();

        private void StartTimers()
        {
            Timer.Interval = TimeSpan.FromSeconds(5);
            Timer.Tick += Timer_Tick;
            Timer.Start();
        }

        private async void Timer_Tick(object sender, EventArgs e)
        {
            Timer.Stop(); // Optional, if you want to control the interval
            await GetUserChat(UserName.Text, "NONE");
            Timer.Start();
        }

        private async Task GetUserChat(string UserName, string QueryType)
        {
            SQLProcess sqlProcess = new SQLProcess();
            DataTable userChat = await Task.Run(() => sqlProcess.GetUserChat(UserName, QueryType, SQLConnectDb));

            DetailsDataGrid.ItemsSource = userChat.DefaultView;
        }


        #endregion Loaders
    }
}