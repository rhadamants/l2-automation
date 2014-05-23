using System;
using System.Collections.Generic;
using BotController.Model;
using BotController.ViewModel;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class PathLoc
  {
    public double X;
    public double Y;
  }

  public class PathPoint
  {
    public PathLoc Loc;
  }

  public class NavigationManager
  {
    public static Dictionary<User, int> PositionByUser = new Dictionary<User, int>();

    public static void StartFollow()
    {
      foreach (var user in UserManager.Users.Values)
        if (!string.IsNullOrEmpty(user.Config.UserToFollow))
          StartFollow(user);
    }

    public static void StartFollow(User user)
    {
      if (user == null || user.Config.UserToFollow.Equals(user.Name))
        return;

      var followPosition = 1;
      if (PositionByUser.ContainsKey(user))
        followPosition = PositionByUser[user];
      else
      {
        followPosition = PositionByUser.Count%4 + 1;
        PositionByUser[user] = followPosition;
      }
      ServerManager.SendMessageToClient(user.HandleId, string.Format("follow {{\"pos\":{0},\"target\":\"{1}\"}}", followPosition, user.Config.UserToFollow));
    }

    public static void StopFollow()
    {
      foreach (var user in UserManager.Users.Values)
        if (!string.IsNullOrEmpty(user.Config.UserToFollow))
          StopFollow(user);
    }

    public static void StopFollow(User user)
    {
      if (user == null)
        return;

      ServerManager.SendMessageToClient(user, "stopFollow");
    }

    public static void MethodFollowersDialogAction(JObject jObject)
    {
      var action = (string) jObject["action"];
      var param = (int) jObject["param"];
      var msg = string.Format("dialogAction {{\"action\":\"{0}\",\"param\":{1}}}", action, param);
      foreach (var user in UserManager.Users.Values)
      {
        ServerManager.SendMessageToClient(user.HandleId, msg);
      }
    }

    public static readonly Dictionary<User, List<PathPoint>> UsersPath = new Dictionary<User, List<PathPoint>>();

    public static void MethodSyncuserPath(JObject jObject)
    {
      //UserManager.CurrentUser.
    }
  }
}