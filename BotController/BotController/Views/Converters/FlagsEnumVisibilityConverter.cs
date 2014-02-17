using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;

namespace BotController.Views.Converters
{
  public class FlagsEnumVisibilityConverter : IValueConverter
  {
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
      var mask = (int)parameter;
      var targetValue = (int)value;
      return ((mask & targetValue) != 0) ? Visibility.Visible : Visibility.Collapsed;
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
    {
      throw new NotImplementedException();
    }
  }
}