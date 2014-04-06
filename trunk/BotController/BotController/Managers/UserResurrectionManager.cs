using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BotController;
using BotController.Model;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class UserResurrectionManager
  {
    public static readonly Dictionary<int, int> ResurrectionPriorities = new Dictionary<int, int>
    {
      {146, 9}, // Heal
      {139, 8}, // Tank
      {144, 7}, // Iss
      {0, 1} // all the rest
    };

    public static readonly List<User> DeadUsers = new List<User>()
    {
//      new User { Name = "Test dead", Class = 144, Role = UserRoles.RDD}
    };

    public static event EventHandler OnDeadUsersListChanged;

    public static void UpdateDeadUsers(int userHandleId, JObject data)
    {
      var deads = data["deads"].Select(token => User.FromDto((JObject) token)).ToList();

      // all deads are known
      if (DeadUsers.Count == deads.Count() && DeadUsers.All(deads.Contains))
        return;

      DeadUsers.Clear();
      DeadUsers.AddRange(deads);

      var onDeadUsersListChanged = OnDeadUsersListChanged;
      if (onDeadUsersListChanged != null)
        onDeadUsersListChanged(null, null);
    }

    public static void ResurrectByIss(User target)
    {
      var resurrector = UserManager.GetUserWithRole(UserRoles.Iss);
      if (resurrector == null || DeadUsers.Contains(resurrector))
        return;
      ServerManager.SendMessageToClient(resurrector,
        string.Format("ressurrect {{\"target\":{0},\"canDelegate\":false}}", target.Id));
    }

    public static void RessurectUser(User user)
    {

      if (user == null)
        return;

      var resurrector = UserManager.GetUserWithRole(UserRoles.Heal);
      if (resurrector == null || DeadUsers.Contains(resurrector))
        resurrector = UserManager.GetUserWithRole(UserRoles.Iss);

      if (resurrector == null || DeadUsers.Contains(resurrector))
      {
        Log.Info("No resurectors found");
        return;
      }

      Log.Info("Send ressurrect to {0}", resurrector.Name);

      ServerManager.SendMessageToClient(resurrector,
        string.Format("ressurrect {{\"target\":{0},\"canDelegate\":false}}", user.Id));
    }
  }
}

/*
 // TEST
      AddTestDeadUserCommand = new RelayCommand(AddTestDeadUserCommandExecute);
 public RelayCommand AddTestDeadUserCommand { get; set; }
    private int _testUsersCounter;
    private void AddTestDeadUserCommandExecute()
    {
      switch (_testUsersCounter)
      {
        case 0:
          UserResurrectionManager.DeadUsers.Add(new User
          {
            Id = 1,
            Name = "Damager",
            Class = 1
          });
          break;
        case 1:
          UserResurrectionManager.DeadUsers.Add(new User
          {
            Id = 2,
            Name = "Iss",
            Class = 144
          });
          break;
        case 2:
          UserResurrectionManager.DeadUsers.Add(new User
          {
            Id = 3,
            Name = "tank",
            Class = 139
          });
          break;
        case 3:
          UserResurrectionManager.DeadUsers.Add(new User
          {
            Id = 4,
            Name = "heal",
            Class = 146
          });
          break;
      }
      _testUsersCounter++;

      OnDeadUsersListChanged(null, null);
    }*/
