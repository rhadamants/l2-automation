using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using BotController.Core;
using BotController.Managers;
using Application = System.Windows.Application;

namespace BotController
{
  /// <summary>
  /// Interaction logic for App.xaml
  /// </summary>
  public partial class App : Application
  {
    public App()
    {
      var listenerThread = new Thread(Server.StartListening) { IsBackground = true };
      listenerThread.Start();

      UserManager.Init();

//      var keyHook = new GlobalKeyboardHook();
//      keyHook.KeyPressed += keyHook_KeyPressed;
//      keyHook.HookedKeys.Add(Keys.NumPad0);
    }

    void keyHook_KeyPressed(object sender, KeyPressedEventArgs e)
    {
      Console.Write(e.Key);
    }
  }
}
