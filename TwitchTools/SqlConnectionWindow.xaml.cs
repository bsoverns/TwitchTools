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
        public SqlConnectionWindow()
        {
            InitializeComponent();
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
