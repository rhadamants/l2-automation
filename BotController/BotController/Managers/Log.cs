using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BotController.Managers
{
  public class Log
  {
    public static List<string> Messages = new List<string>();

    public static event EventHandler<string> LogChanged;

    public static void Info(string format, params object[] args)
    {
      Info(string.Format(format, args));
    }

    public static void Info(string message)
    {
      Messages.Add(message);

      var logChanged = LogChanged;
      if (logChanged != null)
        logChanged(null, message);
    }
  }
}
