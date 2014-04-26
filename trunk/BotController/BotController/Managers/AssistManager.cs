using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BotController.Model;

namespace BotController.Managers
{
  public class AssistManager
  {
    public static void StartAssist()
    {
      foreach (var user in UserManager.Users.Values)
        if (!string.IsNullOrEmpty(user.Config.AssistMaster))
          StartAssist(user);
    }

    public static void StartAssist(User user)
    {
      if (user == null)
        return;

      if (user.Role.HasFlag(UserRoles.Heal))
      {
        Log.Info("We shouldn't enable assist for heal: {0} -> assist disabled", user.Name);
        user.Config.AssistMaster = null;
        return;
      }

      ServerManager.SendMessageToClient(user, CreateStartAssistMessage(user));
    }

    public static void StopAssist()
    {
      foreach (var user in UserManager.Users.Values)
        if (!string.IsNullOrEmpty(user.Config.AssistMaster))
          StopAssist(user);
    }

    public static void StopAssist(User user)
    {
      if (user == null)
        return;

      ServerManager.SendMessageToClient(user, "stopAssist");
    }

    private static string CreateStartAssistMessage(User user)
    {
      return string.Format("startAssist {{\"master\":\"{0}\"}}", user.Config.AssistMaster);
    }
  }
}
