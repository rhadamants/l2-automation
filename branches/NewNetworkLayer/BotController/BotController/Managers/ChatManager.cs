using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class ChatManager
  {
    public static List<string> Messangers = new List<string>();
    public static event EventHandler OnMessangersListChanged;

    public static void NewPM(int userHandleId, JObject jObject)
    {
      var msnger = (string) jObject["msnger"];
      if (Messangers.Contains(msnger))
        return;

      Messangers.Add(msnger);

      var onMessangersListChanged = OnMessangersListChanged;
      if (onMessangersListChanged != null)
        onMessangersListChanged(null, null);
    }

    public static void BlockChatUser(string userName)
    {
      if (string.IsNullOrEmpty(userName))
        return;

      foreach (var user in UserManager.Users)
      {
        ServerManager.SendMessageToClient(user.Key, string.Format("blockChatUser {{\"userName\":\"{0}\"}}", userName));
      }
    }
  }
}
