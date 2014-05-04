using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using BotController.Managers;

namespace BotController
{
  public class UserConnectionHandle
  {
    public Socket WorkSocket = null;
    public int UserHandleId;

    public const int BufferSize = 1024;
    public byte[] Buffer = new byte[BufferSize];
    public StringBuilder Sb = new StringBuilder();
  }

  public class Server
  {
    public static ConcurrentDictionary<int, UserConnectionHandle> Clients = new ConcurrentDictionary<int, UserConnectionHandle>();
    private static int _clientIdCounter;

    private static readonly ManualResetEvent _allDone = new ManualResetEvent(false);
    private static Thread _listenerThread;

    public static void Start()
    {
      _listenerThread = new Thread(StartListening) { IsBackground = true };
      _listenerThread.Start();
    }

    public static void Stop()
    {
      _listenerThread.Abort();
      foreach (var handle in Clients.Values)
      {
        handle.WorkSocket.Disconnect(false);
      }
    }

    public static void StartListening()
    {
      var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

      try
      {
#if DEBUG
          socket.Bind(new IPEndPoint(IPAddress.Any, 8888));
#else
        socket.Bind(new IPEndPoint(IPAddress.Any, 8887));
#endif
          socket.Listen(10);           

          while (true)
          {
            _allDone.Reset();

            Log.Info("Waiting for a connection...");
            socket.BeginAccept(AcceptCallback, socket);

            _allDone.WaitOne();
          }
      }
      catch (Exception e)
      {
        Console.WriteLine(e.ToString());
      }
      Log.Info("Closing the listener...");
    }


    public static void AcceptCallback(IAsyncResult ar)
    {
        // Get the socket that handles the client request.
      var listener = (Socket) ar.AsyncState;
      var handler = listener.EndAccept(ar);

      // Signal the main thread to continue.
      _allDone.Set();

      // Create the state object.
      var userHandle = new UserConnectionHandle
      {
        WorkSocket = handler,
        UserHandleId = _clientIdCounter++
      };
      Clients[userHandle.UserHandleId] = userHandle;

      //ServerManager.StartUserSession(userHandle.UserHandleId);

      handler.BeginReceive(userHandle.Buffer, 0, UserConnectionHandle.BufferSize, 0, ReadCallback, userHandle);
    }

    public static void ReadCallback(IAsyncResult ar)
    {
        var userHandle = (UserConnectionHandle)ar.AsyncState;
      try
      { 
        var userSocket = userHandle.WorkSocket;

        // Read data from the client socket.
        int read = userSocket.EndReceive(ar);

        // Data was read from the client socket.
        if (read > 0)
        {
          var msg = Encoding.ASCII.GetString(userHandle.Buffer, 0, read);
          userHandle.Sb.Append(msg);
          Console.WriteLine("Read from socket: {0}", msg);
          ServerManager.ProcessClientMessage(userHandle.UserHandleId, msg);
          
          userSocket.BeginReceive(userHandle.Buffer, 0, UserConnectionHandle.BufferSize, 0, ReadCallback, userHandle);
        }
        else
        {
          //if (userHandle.Sb.Length > 1)
          //{
            // All the data has been read from the client;
            // display it on the console.
            //string content = userHandle.Sb.ToString();
            //Console.WriteLine("Read {0} bytes from socket.\n Data : {1}", content.Length, content);
          //}
          //userSocket.Close();
          CloseConnection(userHandle.UserHandleId);
        }
      }
      catch (Exception e)
      {
          CloseConnection(userHandle.UserHandleId);
          Console.WriteLine(e);
      }
    }

    public static void SendMessage(int userHandleId, string data)
    {
      try
      {
        byte[] byteData = Encoding.ASCII.GetBytes(data + "\n\r");
        var args = new SocketAsyncEventArgs();
        args.SetBuffer(byteData, 0, byteData.Length);
        args.Completed += (o, eventArgs) => { Console.WriteLine("Message sent"); };
        
          UserConnectionHandle userHandle;
          Clients.TryGetValue(userHandleId, out userHandle);
          //Clients[userHandleId].WorkSocket.SendAsync(args);
          if (userHandle == null)
              throw new Exception(string.Format("Unable to find UserConnectionHandle by id {0}", userHandleId));
              userHandle.WorkSocket.SendAsync(args);
      }
      catch (Exception ex)
      {
          CloseConnection(userHandleId);
        Log.Info("Fail to send msg: {0}", ex);
      }
    }

      private static void CloseConnection(int userHandleId)
      {
          UserConnectionHandle userConnectionState;
          Clients.TryRemove(userHandleId, out userConnectionState);
          handle.WorkSocket.Disconnect(false);
          ServerManager.ClientDisconnected(userHandleId);
      }
  }
}
