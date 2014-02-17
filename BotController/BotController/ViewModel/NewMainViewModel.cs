using System;
using System.Collections.Generic;
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
  public class NewMainViewModel : ViewModelBase
  {

    #region IssBuff

    public RelayCommand<User> StartWatchBuffCommand { get; set; }
    public RelayCommand<User> StopWatchBuffCommand { get; set; }
    public RelayCommand<User> PauseWatchBuffCommand { get; set; }

    private ObservableCollection<User> _buffersList;
    public ObservableCollection<User> BuffersList
    {
      get { return _buffersList ?? (_buffersList = new ObservableCollection<User>()); }
    }

    private User _selectedBuffer;
    public User SelectedBuffer
    {
      get { return _selectedBuffer; }
      set { Set("SelectedBuffer", ref _selectedBuffer, value); }
    }

    private void BufferInit()
    {
      StartWatchBuffCommand = new RelayCommand<User>(BufferManager.StartWatchBuff);
      StopWatchBuffCommand = new RelayCommand<User>(BufferManager.StopWatchBuff);
      PauseWatchBuffCommand = new RelayCommand<User>(BufferManager.PauseWatchBuff);
    }

    private void UpdateBuffers()
    {
      var selectedBuffer = _selectedBuffer;
      BuffersList.Clear();
      BuffersList.AddRange(Users.Where(user => user.Role.HasFlag(UserRoles.Iss)));

      if (selectedBuffer == null || !BuffersList.Contains(selectedBuffer))
        SelectedBuffer = BuffersList.FirstOrDefault();
    }

    #endregion

    public NewMainViewModel()
    {
      UserManager.UserListChanged += OnUsersListChanged;
      UpdateUsersList();

      BufferInit();

      ResUserCommand = new RelayCommand<User>(UserResurrectionManager.RessurectUser);
      UserResurrectionManager.OnDeadUsersListChanged += OnDeadUsersListChanged;
      OnDeadUsersListChanged(null, null);
      
      CreatePartyCommand = new RelayCommand<User>(UserManager.CreateParty);
//      RefreshUsersCommand = new RelayCommand(UserManager.RefreshUsersInfo);

      StartFollowCommand = new RelayCommand<User>(NavigationManager.StartFollow);
      StopFollowCommand = new RelayCommand<User>(NavigationManager.StopFollow);

      StartFollowAllCommand = new RelayCommand(NavigationManager.StartFollow);
      StopFollowAllCommand = new RelayCommand(NavigationManager.StopFollow);

      // pickup
      TogglePickupDumpCommand = new RelayCommand<User>(PickupManager.ToggleDumpAndUpdate);
      ToggleIsPickupMasterCommand = new RelayCommand<User>(PickupManager.ToggleMasterAndUpdate);
    }

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

    #region Follow
    public RelayCommand<User> StartFollowCommand { get; set; }
    public RelayCommand<User> StopFollowCommand { get; set; }

    public RelayCommand StartFollowAllCommand { get; set; }
    public RelayCommand StopFollowAllCommand { get; set; }

    private FollowPosition _followPosition;
    public FollowPosition FollowPosition
    {
      get { return _followPosition; }
      set { Set("FollowPosition", ref _followPosition, value); }
    }

    #endregion

    #region Pickup
    
    public RelayCommand<User> TogglePickupDumpCommand { get; set; }
    public RelayCommand<User> ToggleIsPickupMasterCommand { get; set; }

    #endregion

    #region MainWindow

    private ObservableCollection<User> _users;
    public ObservableCollection<User> Users
    {
      get { return _users ?? (_users = new ObservableCollection<User>()); }
    }
    
    public RelayCommand<User> CreatePartyCommand { get; set; }

//    public RelayCommand RefreshUsersCommand { get; set; } 

    private void UpdateUsersList()
    {
      Users.Clear();
      Users.AddRange(UserManager.Users.Values);

      UpdateBuffers();
    }

    private void OnUsersListChanged(UserEventArgs userEventArgs)
    {
      Application.Current.Dispatcher.InvokeAsync(UpdateUsersList);
    }

    #endregion
  }

  public static class ObservableCollectionExt
  {
    public static void AddRange<T>(this ObservableCollection<T> collection, IEnumerable<T> items)
    {
      foreach (var item in items)
      {
        collection.Add(item);
      }
    }
  }
}