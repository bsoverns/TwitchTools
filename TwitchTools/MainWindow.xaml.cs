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
using System.Diagnostics;

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
        bool _isFlagged = false;
        List<TwitchUser> _twitchUsers = new List<TwitchUser>();
        List<TwitchUserChat> _twitchUserChats = new List<TwitchUserChat>();
        List<string> _channelNames = new List<string>() { "ALL" };
        string botName = "bsoverns"; // This will need to be made configurable if I start using different bots and maybe changed to an array or something

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
            LoadDefaultChannel();
            GetBotStatus();
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

        private void LoadDefaultChannel()
        {
            string LoadDefaultChannel = "ALL";
            cmbChannelSelect.ItemsSource = _channelNames;
            cmbChannelSelect.SelectedItem = LoadDefaultChannel;
        }

        private void GetBotStatus()
        {
            SQLProcess sqlProcess = new SQLProcess();
            bool botStatus = sqlProcess.GetBotStatus(botName, SQLConnectDb);
            if (botStatus)
                StatusToggle.IsChecked = true;
            else
                StatusToggle.IsChecked = false;
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
            if (_isFlagged)
                await GetUserChat(UserName.Text, _queryType);
            else
                await GetUserChat(UserName.Text, _queryType);
            Timer.Start();
        }

        #endregion Timers

        #region Methods

        private async Task GetUserChat(string userName, string queryType)
        {
            SQLProcess sqlProcess = new SQLProcess();
            string channelName = cmbChannelSelect.SelectedItem as string ?? "ALL";
            DataTable userChat = await Task.Run(() => sqlProcess.GetUserChat(userName, queryType, _isFlagged, channelName, SQLConnectDb));

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
                    IsFlagged = row.Field<bool>("IsFlagged"),
                    FlaggedReason = row.Field<string>("FlaggedReason")
                })
                .ToList(); // Convert to a list for easier iteration and usage

            // Create a DataTable for distinct UserNames and ChatMessages for DetailsDataGrid
            DataTable distinctUserDataTable = new DataTable();
            distinctUserDataTable.Columns.Add("UserName", typeof(string));
            distinctUserDataTable.Columns.Add("ChatMessage", typeof(string));
            distinctUserDataTable.Columns.Add("ChannelName", typeof(string));
            distinctUserDataTable.Columns.Add("IsFlagged", typeof(bool));
            distinctUserDataTable.Columns.Add("FlaggedReason", typeof(string));

            _twitchUserChats.Clear();

            _twitchUserChats = distinctUserChats.Select(x => new TwitchUserChat
            {
                UserName = x.UserName,
                ChatMessage = x.ChatMessage,
                ChannelName = x.ChannelName,
                IsFlagged = x.IsFlagged,
                FlaggedReason = x.FlaggedReason
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

            // Extract distinct channel names
            var distinctChannelNames = userChat.AsEnumerable()
                .Select(row => new
                {
                    ChannelName = row.Field<string>("ChannelName")
                })
                .Distinct()
                .ToList(); // Convert to a list for easier iteration and usage

            List<string> tempChannelNames = new List<string>();

            tempChannelNames.Add("ALL");

            foreach (var channelNameData in distinctChannelNames)
            {
                tempChannelNames.Add(channelNameData.ChannelName);
            }

            bool listsAreEqual = _channelNames.SequenceEqual(tempChannelNames);

            if (!listsAreEqual)
            {
                _channelNames = tempChannelNames;
                cmbChannelSelect.ItemsSource = _channelNames;
            }
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

        private void ClearEverything_Button_Click(object sender, RoutedEventArgs e)
        {
            UserName.Text = "";
            StartTimers();
        }

        private void FlaggedCheckBox_Checked(object sender, RoutedEventArgs e)
        {
            _isFlagged = true;            
        }

        private void FlaggedCheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            _isFlagged = false;
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
            _isFlagged = false;
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
        private void StatusToggle_Checked(object sender, RoutedEventArgs e)
        {
            //Debug.WriteLine("Toggle ON: Bot is Active");
            SQLProcess sqlProcess = new SQLProcess();
            sqlProcess.UpsertBotStatus(botName, true, SQLConnectDb);
        }

        private void StatusToggle_Unchecked(object sender, RoutedEventArgs e)
        {
            //Debug.WriteLine("Toggle OFF: Bot is Inactive");
            SQLProcess sqlProcess = new SQLProcess();
            sqlProcess.UpsertBotStatus(botName, false, SQLConnectDb);
        }



        #endregion MainWindowControls
    }
}