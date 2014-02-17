using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Threading;
using BotController.Managers;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;

namespace BotController.ViewModel
{
  public class MainViewModel : ViewModelBase
  {
    private ObservableCollection<User> _users;
    public ObservableCollection<User> Users
    {
      get { return _users ?? (_users = new ObservableCollection<User>()); }
    }

    #region IssBuff

    public RelayCommand StartWatchBuffCommand { get; set; }
    public RelayCommand StopWatchBuffCommand { get; set; }
    public RelayCommand PauseWatchBuffCommand { get; set; }

    public bool IsOopMode
    {
      get { return IssBuffManager.Current.IsOopMode; }
      set
      {
        IssBuffManager.Current.IsOopMode = value;
        RaisePropertyChanged("IsOopMode");
      }
    }

    public bool IsInviteMode
    {
      get { return IssBuffManager.Current.IsInviteMode; }
      set
      {
        IssBuffManager.Current.IsInviteMode = value;
        RaisePropertyChanged("IsInviteMode");
      }
    }

    public string InviteName
    {
      get { return IssBuffManager.Current.InviteName; }
      set
      {
        IssBuffManager.Current.InviteName = value;
        RaisePropertyChanged("InviteName");
      }
    }

    public bool IsRequestParty
    {
      get { return IssBuffManager.Current.IsRequestParty; }
      set
      {
        IssBuffManager.Current.IsRequestParty = value;
        RaisePropertyChanged("IsRequestParty");
      }
    }

    public string RequestPartyName
    {
      get { return IssBuffManager.Current.RequestPartyName; }
      set
      {
        IssBuffManager.Current.RequestPartyName = value;
        RaisePropertyChanged("RequestPartyName");
      }
    }

    #endregion

    #region Resurrection

    public RelayCommand<User> ResUserCommand { get; set; }

    private ObservableCollection<User> _deadUsers;
    public ObservableCollection<User> DeadUsers
    {
      get { return _deadUsers ?? (_deadUsers = new ObservableCollection<User>()); }
    }

    private bool _hasDeadUsers;
    public bool HasDeadUsers
    {
      get { return _hasDeadUsers; }
      set
      {
        _hasDeadUsers = value;
        RaisePropertyChanged("HasDeadUsers");
      }
    }

    private void OnDeadUsersListChanged(object sender, EventArgs eventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(() =>
        {
          DeadUsers.Clear();
          foreach (var user in UserResurrectionManager.DeadUsers)
          {
            DeadUsers.Add(user);
          }

          HasDeadUsers = DeadUsers.Count > 0;
        });
    }

    #endregion

    #region ChatManager

    private ObservableCollection<string> _messangers;
    public ObservableCollection<string> Messangers
    {
      get { return _messangers ?? (_messangers = new ObservableCollection<string>()); }
    }

    public RelayCommand<string> BlockChatUserCommand { get; set; }

    private void OnMessangersListChanged(object sender, EventArgs eventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(() =>
      {
        Messangers.Clear();
        foreach (var msger in ChatManager.Messangers)
        {
          Messangers.Add(msger);
        }

      });
    }

    #endregion

    public MainViewModel()
    {
      StartWatchBuffCommand = new RelayCommand(IssBuffManager.Current.StartWatchBuff);
      StopWatchBuffCommand = new RelayCommand(IssBuffManager.Current.StopWatchBuff);
      PauseWatchBuffCommand = new RelayCommand(IssBuffManager.Current.PauseWatchBuff);

      ResUserCommand = new RelayCommand<User>(UserResurrectionManager.RessurectUser);
      UserResurrectionManager.OnDeadUsersListChanged += OnDeadUsersListChanged;
      OnDeadUsersListChanged(null, null);

      ChatManager.OnMessangersListChanged += OnMessangersListChanged;
      BlockChatUserCommand = new RelayCommand<string>(ChatManager.BlockChatUser);

      UserManager.OnUserSingnIn += OnOnUserSingnIn;
      UserManager.OnUserSingnOut += OnOnUserSingnOut;
    }

    private void UpdateUsersList()
    {
      Users.Clear();
      foreach (var kvp in UserManager.Users)
      {
        Users.Add(kvp.Value);
      }
    }

    private void OnOnUserSingnOut(UserEventArgs userEventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(UpdateUsersList);
    }

    private async void OnOnUserSingnIn(UserEventArgs userEventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(UpdateUsersList);
    }
  }
}