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
            Timer.Interval = TimeSpan.FromSeconds(1);
            Timer.Tick += Timer_Tick;
            Timer.Start();
        }

        private async void Timer_Tick(object sender, EventArgs e)
        {
            Timer.Stop(); // Optional, if you want to control the interval
            await GetUserChat(UserName.Text, "NONE");
            Timer.Start();
        }

        private async Task GetUserChat(string userName, string queryType)
        {
            SQLProcess sqlProcess = new SQLProcess();
            DataTable userChat = await Task.Run(() => sqlProcess.GetUserChat(userName, queryType, SQLConnectDb));

            // Extract distinct UserNames sorted by ChatId descending
            var distinctUserNames = userChat.AsEnumerable()
                .GroupBy(row => row.Field<string>("UserName"))
                .Select(group => group.OrderByDescending(row => row.Field<int>("ChatId")).First()) // Select the most recent ChatId per group
                .OrderByDescending(row => row.Field<int>("ChatId"))
                .Select(row => new
                {
                    UserName = row.Field<string>("UserName"),
                    ChatMessage = row.Field<string>("ChatMessage"),
                    ChannelName = row.Field<string>("ChannelName")
                })
                .ToList(); // Convert to a list for easier iteration and usage

            // Create a DataTable for distinct UserNames and ChatMessages for DetailsDataGrid
            DataTable distinctUserDataTable = new DataTable();
            distinctUserDataTable.Columns.Add("UserName", typeof(string));
            distinctUserDataTable.Columns.Add("ChatMessage", typeof(string));
            distinctUserDataTable.Columns.Add("ChannelName", typeof(string));

            foreach (var userChatData in distinctUserNames)
            {
                distinctUserDataTable.Rows.Add(userChatData.UserName, userChatData.ChatMessage, userChatData.ChannelName);
            }

            // Set DataGrid ItemsSource after data extraction and transformation
            DetailsDataGrid.ItemsSource = distinctUserDataTable.DefaultView;

            // Create a DataTable for distinct UserNames for UserDataGrid if needed
            DataTable distinctUserNamesDataTable = new DataTable();
            distinctUserNamesDataTable.Columns.Add("UserName", typeof(string));
            foreach (var userChatData in distinctUserNames)
            {
                distinctUserNamesDataTable.Rows.Add(userChatData.UserName);
            }

            // Optional: Bind distinct UserNames to UserDataGrid
            UserDataGrid.ItemsSource = distinctUserNamesDataTable.DefaultView;
        }


        #endregion Loaders
    }
}