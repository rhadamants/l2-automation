using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using BotController.Managers;
using BotController.Model;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;

namespace BotController.ViewModel
{
  public class LogViewModel : ViewModelBase
  {
    private ObservableCollection<string> _logs;
    public ObservableCollection<string> Logs
    {
      get { return _logs ?? (_logs = new ObservableCollection<string>()); }
    }

    public RelayCommand AddTestUserCommand { get; set; }

    public LogViewModel()
    {
      Logs.AddRange(Log.Messages);
      Log.LogChanged += LogOnLogChanged;

      AddTestUserCommand = new RelayCommand(AddTestUserExecute);
    }

    private static void AddTestUserExecute()
    {
      UserManager.AddUser(3, new User{Name = "Test3", Class = 145, HandleId = 3, Role = UserRoles.DD, Config = new UserConfig(), Id = 123});
    }

    private void LogOnLogChanged(object sender, string s)
    {
      Application.Current.Dispatcher.InvokeAsync(()=>Logs.Add(s));
    }
  }
}
