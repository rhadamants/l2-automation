using System;
using BotController.Model;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class ServerManager
  {

    public static int CurrentUserHandleId;

    public static void ProcessClientMessage(int userHandleId, string message)
    {
      try
      {
        CurrentUserHandleId = userHandleId;

        var msgJson = JObject.Parse(message);
        switch ((string)msgJson["m"])
        {
          // global
          case "SignIn":
            UserManager.UserSignIn(userHandleId, msgJson["d"] as JObject);
            break;

          // UserResurrectionManager
          case "UpdateDeadUsers":
            UserResurrectionManager.UpdateDeadUsers(userHandleId, msgJson["d"] as JObject);
            break;

          // assist
          case "Assist":
            UserManager.RequestAssis(userHandleId, msgJson["d"] as JObject);
            break;

          // iss buff
          case "RequestPartyFrom":
            UserManager.RequestPartyFrom(msgJson["d"] as JObject);
            break;

          case "NewPM":
            ChatManager.NewPM(userHandleId, msgJson["d"] as JObject);
            break;

          case "MethodSetUserInfo":
            UserManager.MethodSetUserInfo(userHandleId, msgJson["d"] as JObject);
            break;

          case "UpdateUserSkill":
            UserManager.UpdateUserSkill(msgJson["d"] as JObject);
            break;

          case "followersDialogAction":
            NavigationManager.MethodFollowersDialogAction(msgJson["d"] as JObject);
            break;
        }
      }
      catch (Exception e)
      {
        Console.WriteLine("Error in clientMessage {0}", e);
      }
    }

    public static void SendMessageToClient(User user, string message)
    {
      SendMessageToClient(user.HandleId, message);
    }

    public static void SendMessageToClient(int userHandleId, string message)
    {
      Server.SendMessage(userHandleId, message);
    }

    public static void ClientDisconnected(int userHandleId)
    {
      UserManager.UserSignOut(userHandleId);
    }
  }
}
