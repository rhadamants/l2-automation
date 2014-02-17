using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using BotController.Model;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  /// <summary>
  /// OLD ONE
  /// </summary>
  public class IssBuffManager
  {
    private static IssBuffManager _current;
    public static IssBuffManager Current
    {
      get { return _current ?? (_current = new IssBuffManager()); }
    }

    public bool IsOopMode;
    public bool IsInviteMode;
    public string InviteName;
    public bool IsRequestParty;
    public string RequestPartyName;

    public void StartWatchBuff()
    {
      var iss = UserManager.GetUserWithRole(UserRoles.Iss);
      if (iss == null)
        Console.WriteLine(@"No Iss found");

      ServerManager.SendMessageToClient(iss, CreateWatchBuffConfigMessage());
      ServerManager.SendMessageToClient(iss, "issBuffStart");
    }

    public void PauseWatchBuff()
    {
      var iss = UserManager.GetUserWithRole(UserRoles.Iss);
      if (iss == null)
        Console.WriteLine(@"No Iss found");

      ServerManager.SendMessageToClient(iss, "issBuffPause");
    }

    public void StopWatchBuff()
    {
      var iss = UserManager.GetUserWithRole(UserRoles.Iss);
      if (iss == null)
        Console.WriteLine(@"No Iss found");

      ServerManager.SendMessageToClient(iss, "issBuffStop");
    }

    private string CreateWatchBuffConfigMessage()
    {
      return string.Format("issBuffCfg {{\"oopMode\":{0},\"inviteMode\":{1},\"inviteName\":\"{2}\",\"requestParty\":{3},\"requestPartyName\":\"{4}\"}}",
        IsOopMode.ToJsonString(), IsInviteMode.ToJsonString(), InviteName, IsRequestParty.ToJsonString(), RequestPartyName);
    }

    public static void RequestPartyFrom(int userHandleId, JObject dto)
    {
      var target = (string)dto["target"];
      if (string.IsNullOrEmpty(target))
        return;

      var partyLeader = UserManager.Users.SingleOrDefault(pair => pair.Value.Name.Equals(target));
      if (partyLeader.IsDefault())
        return;

      var userToInvite = UserManager.Users[userHandleId];

      ServerManager.SendMessageToClient(partyLeader.Key,
        string.Format("inviteUser {{\"target\":\"{0}\"}}", userToInvite.Name));
    }
  }
}
