using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BotController.Model;

namespace BotController.Managers
{
  public class PickupManager
  {
    public static void ToggleDumpAndUpdate(User user)
    {
      if (user == null)
        return;

      user.Config.PickupDump = !user.Config.PickupDump;
      UpdateConfig(user);
    }

    public static void ToggleMasterAndUpdate(User user)
    {
      if (user == null)
        return;

      user.Config.IsPickupMaster = !user.Config.IsPickupMaster;
      UpdateConfig(user);
    }

    public static void UpdateConfig(User user)
    {
      if (user == null)
        return;

      ServerManager.SendMessageToClient(user, CreatePickupConfigMessage(user));
    }

    private static string CreatePickupConfigMessage(User user)
    {
      return string.Format("setPickupSettings {{\"dump\":{0},\"isMaster\":{1}}}",
        user.Config.PickupDump.ToJsonString(), user.Config.IsPickupMaster.ToJsonString());
    }
  }
}
