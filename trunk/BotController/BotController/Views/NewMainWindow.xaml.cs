using System;
using System.Collections.Generic;
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

namespace BotController.Views
{
  /// <summary>
  /// Interaction logic for NewMainWindow.xaml
  /// </summary>
  public partial class NewMainWindow : Window
  {
    public NewMainWindow()
    {
      InitializeComponent();
    }

    private void DeadUsersList_OnTargetUpdated(object sender, DataTransferEventArgs e)
    {
      ListBox lb = sender as ListBox;
      if (lb != null && lb.HasItems) lb.SelectedIndex = 0;
    }

    private void OpenLog_OnClick(object sender, RoutedEventArgs e)
    {
      var win2 = new LogWindow();
      win2.Show();
    }

    private void OpenOldWindow_OnClick(object sender, RoutedEventArgs e)
    {
      var win2 = new MainWindow();
      win2.Show();
    }
  }
}
