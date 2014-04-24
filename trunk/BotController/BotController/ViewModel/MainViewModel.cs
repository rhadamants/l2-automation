using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Threading;
using BotController.Managers;
using BotController.Model;
using GalaSoft.MvvmLight;
using GalaSoft.MvvmLight.Command;

namespace BotController.ViewModel
{
  public class MainViewModel : ViewModelBase
  {

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

    private User _selectedDeadUser;
    public User SelectedDeadUser
    {
      get { return _selectedDeadUser; }
      set { Set("SelectedDeadUser", ref _selectedDeadUser, value); }
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
        var prios = UserResurrectionManager.ResurrectionPriorities;
        var selectedPrio = 0;
        User selected = null;
        DeadUsers.Clear();
        foreach (var user in UserResurrectionManager.DeadUsers)
        {
          var userPrioKey = prios.ContainsKey(user.Class) ? user.Class : 0;
          var userPrio = UserResurrectionManager.ResurrectionPriorities[userPrioKey];
          if (userPrio > selectedPrio)
            selected = user;
          DeadUsers.Add(user);
        }

        //SelectedDeadUserIndex = DeadUsers.IndexOf(selected);
        SelectedDeadUser = selected;

        HasDeadUsers = DeadUsers.Count > 0;
      });
    }

    #endregion

    #region ChatManager

    private ObservableCollection<string> _messangers;
    private bool _isSelectedIss;

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
      UserResurrectionManager.DeadUsersListChanged += OnDeadUsersListChanged;
      OnDeadUsersListChanged(null, null);

      ChatManager.OnMessangersListChanged += OnMessangersListChanged;
      BlockChatUserCommand = new RelayCommand<string>(ChatManager.BlockChatUser);

      UserManager.UserListChanged += OnUsersListChanged;
      UpdateUsersList();

      UpdateSelectedUserInfo();

      CreatePartyCommand = new RelayCommand<User>(UserManager.CreateParty);
      RefreshUsersCommand = new RelayCommand(UserManager.RefreshUsersInfo);

      // DEV
      StartFollowCommand = new RelayCommand<User>(StartFollow);
      StopFollowCommand = new RelayCommand(NavigationManager.StopFollow);
    }

    #region Follow
    public RelayCommand<User> StartFollowCommand { get; set; }
    public RelayCommand StopFollowCommand { get; set; }

    private FollowPosition _followPosition;
    public FollowPosition FollowPosition
    {
      get { return _followPosition; }
      set { Set("FollowPosition", ref _followPosition, value); }
    }

    private void StartFollow(User user)
    {
      NavigationManager.StartFollow(user);
    }

    #endregion

    #region MainWindow

    private ObservableCollection<User> _users;
    public ObservableCollection<User> Users
    {
      get { return _users ?? (_users = new ObservableCollection<User>()); }
    }

    private User _selectedUser;
    public User SelectedUser
    {
      get { return _selectedUser; }
      set
      {
        Set("SelectedUser", ref _selectedUser, value);
        UpdateSelectedUserInfo();
      }
    }

    public bool IsSelectedIss
    {
      get { return _isSelectedIss; }
      set { Set("IsSelectedIss", ref _isSelectedIss, value); }
    }

    public RelayCommand<User> CreatePartyCommand { get; set; }

    public RelayCommand RefreshUsersCommand { get; set; } 

    private void UpdateUsersList()
    {
      Users.Clear();
      foreach (var kvp in UserManager.Users)
      {
        Users.Add(kvp.Value);
      }
      UpdateSelectedUserInfo();
    }

    private void UpdateSelectedUserInfo()
    {
      IsSelectedIss = SelectedUser != null && SelectedUser.Class == 144;
    }

    private void OnUsersListChanged(UserEventArgs userEventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(UpdateUsersList);
    }

    #endregion
  }

  public enum FollowPosition
  {
    Pos1 = 1,
    Pos2 = 2,
    Pos3 = 3,
    Pos4 = 4
  }
}