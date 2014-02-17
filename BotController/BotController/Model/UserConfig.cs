﻿using GalaSoft.MvvmLight;

namespace BotController.Model
{
  public class UserConfig : ObservableObject
  {
    private bool _isHuman;
    public bool IsHuman
    {
      get { return _isHuman; }
      set { Set("IsHuman", ref _isHuman, value); }
    }

    #region IssBuff

    private bool _isOopMode;
    private bool _isInviteMode;
    private string _inviteName;
    private bool _isRequestParty;
    private string _requestPartyName;

    public bool IsOopMode
    {
      get { return _isOopMode; }
      set { Set("IsOopMode", ref _isOopMode, value); }
    }

    public bool IsInviteMode
    {
      get { return _isInviteMode; }
      set { Set("IsInviteMode", ref _isInviteMode, value); }
    }

    public string InviteName
    {
      get { return _inviteName; }
      set { Set("InviteName", ref _inviteName, value); }
    }

    public bool IsRequestParty
    {
      get { return _isRequestParty; }
      set { Set("IsRequestParty", ref _isRequestParty, value); }
    }

    public string RequestPartyName
    {
      get { return _requestPartyName; }
      set { Set("RequestPartyName", ref _requestPartyName, value); }
    }

    #endregion

    #region Follow

    private string _userToFollow;
    public string UserToFollow
    {
      get { return _userToFollow; }
      set { Set("UserToFollow", ref _userToFollow, value); }
    }

    #endregion
  }
}