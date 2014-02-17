using System;
using BotController.Core;
using BotController.Managers;
using Newtonsoft.Json.Linq;

namespace BotController.Model
{
  [Flags] 
  public enum UserRoles
  {
    Unknown = 0,
    Tank = 0x1,
    Iss = 0x10,
    DD = 0x100,
    RDD = 0x1000,
    Heal = 0x10000,
  }

  public class User
  {
    public int HandleId { get; set; }
    public int Id { get; set; }
    public string Name { get; set; }
    public int Class { get; set; }
    public UserRoles Role { get; set; }

    public UserConfig Config { get; set; }

    public ObservableDictionary<int, SkillInfo> Skills { get; set; }

    public User()
    {
      Skills = new ObservableDictionary<int, SkillInfo>();
    }

    public static User FromDto(int userHandleId, JObject dto)
    {
      var user = FromDto(dto);
      user.HandleId = userHandleId;
      user.Role = UserManager.GetRoleByClass(user.Class);
      return user;
    }

    public static User FromDto(JObject dto)
    {
      return new User
      {
        Id = dto["i"] != null ? (int) dto["i"] : 0,
        Name = dto["n"] != null ? (string)dto["n"] : "No name ?",
        Class = dto["c"] != null ? (int)dto["c"] : 0,
        Config = new UserConfig()
      };
    }

    public override string ToString()
    {
      return Name;
    }

    public override int GetHashCode()
    {
      return Id;
    }

    public override bool Equals(object obj)
    {
      return obj is User && ((User) obj).Id == Id;
    }
  }
}