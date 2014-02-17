namespace BotController.Managers
{
  public static class Extensions
  {
    public static bool IsDefault<T>(this T value) where T : struct
    {
      bool isDefault = value.Equals(default(T));

      return isDefault;
    }

    public static string ToJsonString(this bool value)
    {
      return value ? "true" : "false";
    }
  }
}