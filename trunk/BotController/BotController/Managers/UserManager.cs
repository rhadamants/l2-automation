using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BotController.Core;
using BotController.Model;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class UserManager
  {
    #region Constants

    public static readonly Dictionary<int, UserRoles> UserRolesByClass = new Dictionary<int, UserRoles>
    {
      {0, UserRoles.Unknown},
      {144, UserRoles.Iss},
      {146, UserRoles.Heal},
      {139, UserRoles.Tank},
      {143, UserRoles.DD},
      {145, UserRoles.DD},
      {140, UserRoles.DD},
      {141, UserRoles.DD},
      {142, UserRoles.DD},
    };

    #endregion

    #region Users List mmanagement

    public static event UserEventHandler UserListChanged;
    public delegate void UserEventHandler(UserEventArgs e);

    public static readonly Dictionary<int, User> Users = new Dictionary<int, User>()
    {
//      {1, new User{HandleId = 1, Name = "Test", Role = UserRoles.Iss, Config = new UserConfig()}},
//      {2, new User{HandleId = 2, Name = "Test2", Role = UserRoles.RDD, Config = new UserConfig()}}
    };

    public static readonly Dictionary<string, UserConfig> UserConfigs = new Dictionary<string, UserConfig>();

    public static User CurrentUser
    {
      get
      {
        User user;
        Users.TryGetValue(ServerManager.CurrentUserHandleId, out user);
        return user;
      }
    }

    public static User GetUserWithRole(UserRoles role)
    {
      return Users.Values.FirstOrDefault(u => u.Role.HasFlag(role));
    }

    public static IEnumerable<User> GetAllUsersWithRole(UserRoles role)
    {
      return Users.Values.Where(u => u.Role.HasFlag(role));
    }

    public static UserConfig GetUserConfig(string userName)
    {
      if (!UserConfigs.ContainsKey(userName))
        UserConfigs.Add(userName, new UserConfig());
      return UserConfigs[userName];
    }

    #endregion

    #region Users game time simulation

    private static Thread _workerThread;

    public static void Init()
    {
      _workerThread = new Thread(UpdateUsers) { Name = "UpdateUsers", IsBackground = true };
      _workerThread.Start();
    }

    public static async void UpdateUsers()
    {
      while (true)
      {
        foreach (var user in Users.Values)
        {
          var removeSkills = new List<SkillInfo>();
          foreach (var skill in user.Skills.Values)
          {
            skill.Timeout--;
            if (skill.Timeout <= 0)
              removeSkills.Add(skill);
          }
          foreach (var removeSkill in removeSkills)
          {
            user.Skills.Values.Remove(removeSkill);
          }
        }
        await Task.Delay(1000);
      }
    }

    #endregion

    #region Newtork methods

    public static void UserSignIn(int userHandleId, JObject data)
    {
      // build user
      var user = User.FromDto(userHandleId, data);
      AddUser(userHandleId, user);
    }

    // extracted for debug needs
    public static void AddUser(int userHandleId, User user)
    {
      if (Users.ContainsKey(userHandleId))
      {
        Log.Info(@"overlap user handleId {0}", userHandleId);
        Users.Remove(userHandleId);
      }

      user.Config = GetUserConfig(user.Name);
      Users.Add(userHandleId, user);

      var userListChanged = UserListChanged;
      if (userListChanged != null)
        userListChanged(new UserEventArgs(user));

      UpdateUserConfigs(user);
    }

    public static void UserSignOut(int userHandleId)
    {
      Users.Remove(userHandleId);

      var userListChanged = UserListChanged;
      if (userListChanged != null)
        userListChanged(new UserEventArgs());
    }

    public static void MethodSetUserInfo(int userHandleId, JObject data)
    {
      Users.Remove(userHandleId);
      Users.Add(userHandleId, User.FromDto(userHandleId, data));

      var userListChanged = UserListChanged;
      if (userListChanged != null)
        userListChanged(new UserEventArgs());
    }

    public static void RequestPartyFrom(JObject dto)
    {
      var target = (string)dto["target"];
      if (String.IsNullOrEmpty(target))
        return;

      var partyLeader = Users.SingleOrDefault(pair => pair.Value.Name.Equals(target));
      if (partyLeader.IsDefault())
        return;

      ServerManager.SendMessageToClient(partyLeader.Key,
        String.Format("inviteUser {{\"target\":\"{0}\"}}", CurrentUser.Name));
    }

    public static void RequestAssis(int userHandleId, JObject dto)
    {
      var target = (string)dto["target"];
      if (String.IsNullOrEmpty(target))
      {
        Log.Info("Invalid target to assist");
        return;
      }

      var damagers = GetAllUsersWithRole(UserRoles.DD);
      foreach (var user in damagers)
      {
        ServerManager.SendMessageToClient(user, String.Format("assist {{\"target\":{0}}}", target));
      }
    }

    public static void UpdateUserSkill(JObject data)
    {
      if (data["skillId"] == null)
        return;
      var user = CurrentUser;

      var skillId = (int)data["skillId"];
      if (user.Skills.ContainsKey(skillId))
        user.Skills[skillId].Timeout = data["timeout"] != null ? (int)data["timeout"] : 0;

      user.Skills.Add(skillId, SkillInfo.FromDto(data));
    }

    #endregion

    #region Control commands

    public static void RefreshUsersInfo()
    {
      foreach (var user in Users.Values)
      {
        ServerManager.SendMessageToClient(user, "getUserInfo");
      }
    }

    public static async void CreateParty(User pl)
    {
      if (pl == null)
      {
        Log.Info("Invalid party leader");
        return;
      }

      try
      {
        var members = Users.Values.Where(user => !pl.Equals(user));
        foreach (var member in members)
        {
          await Task.Delay(500);
          ServerManager.SendMessageToClient(pl.HandleId, String.Format("inviteUser {{\"target\":\"{0}\"}}", member.Name));
          await Task.Delay(500);
          ServerManager.SendMessageToClient(member.HandleId, "acceptInvite");
        }
      }
      catch (Exception e)
      {
        Log.Info("Failed to create party: {0}", e);
      }
    }

    #endregion

    public static void UpdateUserConfigs(User user)
    {
      //BufferManager.UpdateUserCfg(user);
      //PickupManager.UpdateConfig(user);
    }

    public static UserRoles GetRoleByClass(int userClass)
    {
      if (UserRolesByClass.ContainsKey(userClass))
        return UserRolesByClass[userClass];
      return UserRoles.Unknown;
    }
  }

  public class UserEventArgs
  {
    public User User;
    public object EventData;

    public UserEventArgs()
    { }

    public UserEventArgs(User user)
    {
      User = user;
    }
  }
}
