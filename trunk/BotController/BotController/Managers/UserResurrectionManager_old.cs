using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace BotController.Managers
{
  public class UserResurrectionManager
  {
    public static readonly List<User> DeadUsers = new List<User>();

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


    public static void RessurectUser(User user)
    {

      if (user == null)
        return;

      var resurrector = UserManager.GetUserWithRole(UserRoles.Iss);
      if (resurrector == null || DeadUsers.Contains(resurrector))
        resurrector = UserManager.GetUserWithRole(UserRoles.Heal);

      if (resurrector == null || DeadUsers.Contains(resurrector))
      {
        Console.WriteLine("No resurectors found");
        return;
      }

      ServerManager.SendMessageToClient(resurrector,
        string.Format("ressurrect {{\"target\":{0},\"canDelegate\":false}}", user.Id));
    }
  }
}
