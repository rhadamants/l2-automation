using GalaSoft.MvvmLight;
using Newtonsoft.Json.Linq;

namespace BotController.Model
{
  public class SkillInfo : ObservableObject
  {
    public int SkillId { get; set; }
    public SkillCategory SkillCategory { get; set; }

    public int TimeoutValue;
    public int Timeout
    {
      get { return TimeoutValue; }
      set { Set("Timeout", ref TimeoutValue, value); }
    }

    public static SkillInfo FromDto(JObject dto)
    {
      return new SkillInfo
      {
        SkillId = dto["id"] != null ? (int)dto["i"] : 0,
        Timeout = dto["timeout"] != null ? (int)dto["timeout"] : 0,
      };
    }
  }

  public enum SkillCategory
  {
    Resurrect
  }
}