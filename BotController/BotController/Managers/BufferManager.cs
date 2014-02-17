using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BotController.Model;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  /// <summary>
  /// NEW ONE
  /// </summary>
  class BufferManager
  {
    public static void StartWatchBuff(User user)
    {
      if (user == null || !user.Role.HasFlag(UserRoles.Iss))
      {
        Log.Info(@"Selected user is not iss");
        return;
      }

      ServerManager.SendMessageToClient(user, CreateWatchBuffConfigMessage(user));
      ServerManager.SendMessageToClient(user, "issBuffStart");
    }

    public static void PauseWatchBuff(User user)
    {
      if (user == null || !user.Role.HasFlag(UserRoles.Iss))
      {
        Log.Info(@"Selected user is not iss");
        return;
      }

      ServerManager.SendMessageToClient(user, "issBuffPause");
    }

    public static void StopWatchBuff(User user)
    {
      if (user == null || !user.Role.HasFlag(UserRoles.Iss))
      {
        Log.Info(@"Selected user is not iss");
        return;
      }

      ServerManager.SendMessageToClient(user, "issBuffStop");
    }

    private static string CreateWatchBuffConfigMessage(User user)
    {
      return string.Format("issBuffCfg {{\"oopMode\":{0},\"inviteMode\":{1},\"inviteName\":\"{2}\",\"requestParty\":{3},\"requestPartyName\":\"{4}\"}}",
        user.Config.IsOopMode.ToJsonString(), user.Config.IsInviteMode.ToJsonString(), user.Config.InviteName, user.Config.IsRequestParty.ToJsonString(), user.Config.RequestPartyName);
    }
  }
}
