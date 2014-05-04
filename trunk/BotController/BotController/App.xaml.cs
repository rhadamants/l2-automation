using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
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
      Server.Start();

      UserManager.Init();

      Exit += OnExit;

//      var keyHook = new GlobalKeyboardHook();
//      keyHook.KeyPressed += keyHook_KeyPressed;
//      keyHook.HookedKeys.Add(Keys.NumPad0);
    }

    private void OnExit(object sender, ExitEventArgs exitEventArgs)
    {
      Server.Stop();
    }

    void keyHook_KeyPressed(object sender, KeyPressedEventArgs e)
    {
      Console.Write(e.Key);
    }
  }
}
