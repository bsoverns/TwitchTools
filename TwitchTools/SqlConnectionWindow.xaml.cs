using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace TwitchTools
{
    /// <summary>
    /// Interaction logic for SqlConnectionWindow.xaml
    /// </summary>
    public partial class SqlConnectionWindow : Window
    {
        SQLConnectionClass SQLConnectDb = new SQLConnectionClass();

        public SqlConnectionWindow()
        {
            InitializeComponent();
            LoadSettings();
        }

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

            DataSourceTextBox.Text = SQLConnectDb.DataSource;
            InitialCatalogTextBox.Text = SQLConnectDb.InitialCatalog;
            UserIdTextBox.Text = SQLConnectDb.UserID;
            PasswordBox.Password = SQLConnectDb.Password;
            UseIpAddressCheckBox.IsChecked = SQLConnectDb.UseIPAdress;
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            SQLConnectionClass sqlConnection = new SQLConnectionClass
            {
                DataSource = DataSourceTextBox.Text,
                InitialCatalog = InitialCatalogTextBox.Text,
                UserID = UserIdTextBox.Text,
                Password = PasswordBox.Password,
                UseIPAdress = UseIpAddressCheckBox.IsChecked == true
            };

            SQLSettings sqlSettings = new SQLSettings();
            bool isSaved = sqlSettings.SaveStockData(sqlConnection);

            if (isSaved)
            {
                MessageBox.Show("Settings saved successfully.", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                this.DialogResult = true;
                this.Close();
            }
            else
            {
                MessageBox.Show("Failed to save settings.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void TestConnectionButton_Click(object sender, RoutedEventArgs e)
        {
            string connectionString = $"Data Source={DataSourceTextBox.Text};Initial Catalog={InitialCatalogTextBox.Text};User ID={UserIdTextBox.Text};Password={PasswordBox.Password}";

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    MessageBox.Show("Connection successful!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Connection failed: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
