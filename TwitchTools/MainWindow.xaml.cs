using System.Data;
using System.IO;
using System.Text;
using System.Speech.Synthesis;
using System.Speech.AudioFormat;
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
        SpeechSynthesizer voice = new SpeechSynthesizer();
        SQLConnectionClass SQLConnectDb = new SQLConnectionClass();
        string _defaultVoice = "Microsoft David Desktop";
        string _queryType = "NONE";
        List<TwitchUser> _twitchUsers = new List<TwitchUser>();
        // May need to change this below for performance
        List<TwitchUserChat> _twitchUserChats = new List<TwitchUserChat>();

        public MainWindow()
        {
            InitializeComponent();            
            //Speak(_defaultVoice, @"This is the loading alert voice for the Twitch Tools to make sure they are working");
            LoadSettings();
        }

        private void Speak(string Voice, string Message)
        {
            // Voices          
            // Microsoft David Desktop
            // Microsoft Zira Desktop
            voice.SelectVoice(Voice);
            voice.SpeakAsync(Message);
        }

        #region Loaders
        private void LoadSettings()
        {
            LoadSqlSettings();
            FirstStartTimers();
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

        private void FirstStartTimers()
        {
            Timer.Interval = TimeSpan.FromSeconds(1);
            Timer.Tick += Timer_Tick;
            Timer.Start();
        }

        #endregion Loaders

        #region Timers

        private void StopTimers()
        {
            Timer.Stop();
            Timer.IsEnabled = false;
        }

        private void StartTimers()
        {
            // This needs fixed
            // Restart timer
            //if (Timer.IsEnabled)
            //{
            Timer.Stop();
            Timer.Start();
            //}     
        }

        private async void Timer_Tick(object sender, EventArgs e)
        {
            Timer.Stop(); // Optional, if you want to control the interval
            await GetUserChat(UserName.Text, _queryType);
            Timer.Start();
        }

        #endregion Timers

        #region Methods

        private async Task GetUserChat(string userName, string queryType)
        {
            SQLProcess sqlProcess = new SQLProcess();
            DataTable userChat = await Task.Run(() => sqlProcess.GetUserChat(userName, queryType, SQLConnectDb));

            // Extract distinct UserNames sorted by ChatId descending
            var distinctUserChats = userChat.AsEnumerable()
                //.GroupBy(row => row.Field<string>("UserName"))
                //.Select(group => group.OrderByDescending(row => row.Field<int>("ChatId")).First()) // Select the most recent ChatId per group
                .OrderByDescending(row => row.Field<int>("ChatId"))
                .Select(row => new
                {
                    UserName = row.Field<string>("UserName"),
                    ChatMessage = row.Field<string>("ChatMessage"),
                    ChannelName = row.Field<string>("ChannelName"),
                    IsFlagged = row.Field<bool>("IsFlagged")
                })
                .ToList(); // Convert to a list for easier iteration and usage

            // Create a DataTable for distinct UserNames and ChatMessages for DetailsDataGrid
            DataTable distinctUserDataTable = new DataTable();
            distinctUserDataTable.Columns.Add("UserName", typeof(string));
            distinctUserDataTable.Columns.Add("ChatMessage", typeof(string));
            distinctUserDataTable.Columns.Add("ChannelName", typeof(string));
            distinctUserDataTable.Columns.Add("IsFlagged", typeof(bool));

            _twitchUserChats.Clear();

            _twitchUserChats = distinctUserChats.Select(x => new TwitchUserChat
            {
                UserName = x.UserName,
                ChatMessage = x.ChatMessage,
                ChannelName = x.ChannelName
            }).ToList();

            DetailsDataGrid.ItemsSource = _twitchUserChats;

            // Extract distinct UserNames 
            var distinctUserNames = userChat.AsEnumerable()
                .Select(row => new
                {
                    UserName = row.Field<string>("UserName")
                })
                .Distinct()
                .ToList(); // Convert to a list for easier iteration and usage

            // Distinct UserNames
            DataTable distinctUserNameTable = new DataTable();
            distinctUserNameTable.Columns.Add("UserName", typeof(string));

            foreach (var userChatData in distinctUserNames)
            {
                distinctUserNameTable.Rows.Add(userChatData.UserName);
            }

            _twitchUsers.Clear();
            _twitchUsers = distinctUserNames.Select(x => new TwitchUser
            {
                UserName = x.UserName
            }).ToList();

            UserDataGrid.ItemsSource = _twitchUsers;
        }

        #endregion Methods

        #region MainWindowControls

        private void DetailsDataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (DetailsDataGrid.SelectedItem != null)
            {
                StopTimers();
            }
        }

        private void Speak_Button_Click(object sender, RoutedEventArgs e)
        {
            SpeakButton.IsEnabled = false;
            ClearButton.IsEnabled = false;
            var selectedItem = DetailsDataGrid.SelectedItem;
            if (selectedItem != null && selectedItem is TwitchUserChat row)
            {
                string chatMessage = row.ChatMessage;
                if (!string.IsNullOrEmpty(chatMessage))
                    Speak(_defaultVoice, chatMessage);

                else
                    MessageBox.Show("No chat message to speak for");
            }

            DetailsDataGrid.SelectedItem = null;
            SpeakButton.IsEnabled = true;
            ClearButton.IsEnabled = true;
        }

        private void ClearEverything_Button_Click(object sender, RoutedEventArgs e)
        {
            UserName.Text = "";
            StartTimers();
        }

        private void UserName_Search(object sender, TextChangedEventArgs e)
        {
            if (UserName.Text.Length > 0 && UserDataGrid.SelectedItem == null)
                _queryType = "LIKE";

            else if (UserName.Text.Length > 0 && UserDataGrid.SelectedItem != null)
                _queryType = "EQUAL";

            else
                _queryType = "NONE";
        }

        private void UserName_TargetedSearch(object sender, SelectionChangedEventArgs e)
        {
            var selectedItem = UserDataGrid.SelectedItem;
            if (selectedItem != null && selectedItem is TwitchUser row)
            {
                string userName = row.UserName;
                if (!string.IsNullOrEmpty(userName))
                {
                    _queryType = "EQUAL";
                    UserName.Text = userName;
                }
            }
        }

        #endregion MainWindowControls
    }
}