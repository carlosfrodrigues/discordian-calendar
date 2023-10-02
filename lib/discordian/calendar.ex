defmodule Discordian.Calendar do

  @behaviour Calendar
  @type year :: Integer.t()
  @type month :: 1..6
  @type day :: 1..73
  @type day_of_week :: 1..5
  @type hour :: 0..23
  @type minute :: 0..59
  @type second :: 0..60
  @type microsecond :: Integer.t()
  @days_of_week ~w(Sweetmorn Boomtime Pungenday Prickle-Prickle Setting_Orange)
  @seconds_per_minute 60
  @seconds_per_hour 60*60
  @seconds_per_day 24*60*60
  @microseconds_per_second 1000000
  @months_in_year 5

  @doc """
  Converts the date into a string according to the calendar.
  """
  @impl true
  @spec date_to_string(year, month, day) :: String.t()
  def date_to_string(year, month, day) do
    zero_pad(year, 4) <> "-" <> zero_pad(month, 2) <> "-" <> zero_pad(day, 2)
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  @impl true
  def datetime_to_string(
    year,
    month,
    day,
    hour,
    minute,
    second,
    microsecond,
    time_zone,
    zone_abbr,
    utc_offset,
    std_offset
  ) do
    date_to_string(year, month, day) <>
    " " <>
    time_to_string(hour, minute, second, microsecond) <>
    offset_to_string(utc_offset, std_offset, time_zone) <>
    zone_to_string(utc_offset, std_offset, zone_abbr, time_zone)
  end

  @doc """
  Calculates the day and era from the given year, month, and day.
  """
  @spec day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
  @impl true
  def day_of_era(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) and year > 0 do
    day = Discordian.discordian_to_days(year, month, day)
    {day, 1}
  end

  def day_of_era(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) and year < 0 do
    day = Discordian.discordian_to_days(year, month, day)
    {day, 0}
  end

  @doc """
  Calculates the day of the week from the given year, month, and day.
  """
  @impl true
  @spec day_of_week(year :: integer, month :: integer, day :: integer, :default | atom()) :: String.t()
  def day_of_week(year, month, day, :default) when is_integer(year) and is_integer(month) and is_integer(day) do
    day_of_year(year, month, day) - 1
    |> rem(5)
    |> day_of_week_name()
  end


  defp day_of_week_name(day_number) do
    Enum.at(@days_of_week, day_number)
  end

  @doc """
  Calculates the day of the year from the given year, month, and day.
  """
  @impl true
  @spec day_of_year(year, month, day) :: 1..366
  def day_of_year(year, month, day) do
    Discordian.discordian_day_year(year, month, day)
  end

  @doc """
  Define the rollover moment for the given calendar.
  """
  @impl true
  def day_rollover_relative_to_midnight_utc(), do: {0,1}

  @doc """
  Returns how many days there are in the given year-month.
  """
  @impl true
  @spec days_in_month(Calendar.year(), Calendar.month()) :: Calendar.day()
  def days_in_month(year, month), do: Discordian.discordian_month_lenght(year, month)

  @doc """
  Returns true if the given year is a leap year.
  """
  @impl true
  @spec leap_year?(Calendar.year()) :: boolean
  def leap_year?(year), do: Discordian.is_leap_year(year)

  @doc """
  Returns how many months there are in the given year.
  """
  @impl true
  @spec months_in_year(year) :: 5
  def months_in_year(_year), do: @months_in_year

  @doc """
  Converts iso_days/0 to the Calendar's datetime format.
  """
  @impl true
  @spec naive_datetime_from_iso_days(Calendar.iso_days()) ::
    {Calendar.year(), Calendar.month(), Calendar.day(), Calendar.hour(), Calendar.minute(),
    Calendar.second(), Calendar.microsecond()}
  def naive_datetime_from_iso_days({days, day_fraction}) do
    {year, month, day} = Discordian.iso_days_to_discordian(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
  end

  @doc """
  Converts the given datetime (without time zone) into the iso_days/0 format.
  """
  @impl true
  @spec naive_datetime_to_iso_days(
    Calendar.year(),
    Calendar.month(),
    Calendar.day(),
    Calendar.hour(),
    Calendar.minute(),
    Calendar.second(),
    Calendar.microsecond()
  ) :: Calendar.iso_days()
  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {Discordian.discordian_to_days(year, month, day),
    time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  @impl true
  @spec naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) :: String.t()
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    date_to_string(year, month, day) <> " " <> time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Parses the string representation for a date returned by date_to_string/3 into a date-tuple.
  """
  @impl true
  def parse_date(string_date) do
    date_list = String.split(string_date, "-")
    date_tuple = date_list |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    {:ok, date_tuple}
  end

  @doc """
  Parses the string representation for a naive datetime returned by naive_datetime_to_string/7 into a naive-datetime-tuple.
  """
  @impl true
  def parse_naive_datetime(string_date) do
    date_list = String.split(string_date, "-")
    date_tuple = date_list |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    {:ok, date_tuple}
  end

  @doc """
  Parses the string representation for a time returned by time_to_string/4 into a time-tuple.
  """
  @impl true
  def parse_time(string_date) do
    date_list = String.split(string_date, "-")
    date_tuple = date_list |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    {:ok, date_tuple}
  end

  @doc """
  Parses the string representation for a datetime returned by datetime_to_string/11 into a datetime-tuple.
  """
  @impl true
  def parse_utc_datetime(string_date) do
    date_list = String.split(string_date, "-")
    date_tuple = date_list |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    {:ok, date_tuple}
  end

  @doc """
  Calculates the quarter of the year from the given year, month, and day.
  """
  @impl true
  @spec quarter_of_year(year, month, day) :: 1..4
  def quarter_of_year(year, month, day)
      when is_integer(year) and is_integer(month) and is_integer(day) do
    trunc((month-1)/1.25) + 1
  end

  @doc """
  Converts day_fraction/0 to the Calendar's time format.
  """
  @impl true
  @spec time_from_day_fraction(Calendar.day_fraction()) ::
      {Calendar.hour(), Calendar.minute(), Calendar.second(), Calendar.microsecond()}
  def time_from_day_fraction({parts_in_day, parts_per_day}) do
    total_microseconds =
      div(parts_in_day * @seconds_per_day * @microseconds_per_second, parts_per_day)

    {hours, rest_microseconds1} =
      {div(total_microseconds, @seconds_per_hour * @microseconds_per_second),
      rem(total_microseconds, @seconds_per_hour * @microseconds_per_second)}

    {minutes, rest_microseconds2} =
      {div(rest_microseconds1, @seconds_per_minute * @microseconds_per_second),
      rem(rest_microseconds1, @seconds_per_minute * @microseconds_per_second)}

    {seconds, microseconds} = {div(rest_microseconds2, @microseconds_per_second),
                              rem(rest_microseconds2, @microseconds_per_second)}

    {hours, minutes, seconds, {microseconds, 6}}
  end

  @doc """
  Converts the given time to the day_fraction/0 format.
  """
  @impl true
  @spec time_to_day_fraction(
    Calendar.hour(),
    Calendar.minute(),
    Calendar.second(),
    Calendar.microsecond()
  ) :: Calendar.day_fraction()
  def time_to_day_fraction(hour, minute, second, {microsecond, _}) do
    combined_seconds = hour * @seconds_per_hour + minute * @seconds_per_minute + second

    {combined_seconds * @microseconds_per_second + microsecond,
      @seconds_per_day * @microseconds_per_second}
  end

  @doc """
  Converts the time into a string according to the calendar.
  """
  @impl true
  def time_to_string(hour, minute, second, microsecond) do
    Integer.to_string(hour) <> ":" <> Integer.to_string(minute) <> ":" <> Integer.to_string(second) <> ":" <> Integer.to_string(microsecond)
  end

  @doc """
  Should return true if the given date describes a proper date in the calendar.
  """
  @impl true
  def valid_date?(year, month, day), do: Discordian.is_valid_discordian_date({year, month, day})

  @doc """
  Should return true if the given time describes a proper time in the calendar.
  """
  @impl true
  def valid_time?(hour, minute, second, {microsecond, precision}) do
    hour in 0..23 and minute in 0..59 and second in 0..60 and
    microsecond in 0..999_999 and precision in 0..6
  end

  @doc """
  Calculates the year and era from the given year.
  """
  @spec year_of_era(year) :: {year, era :: 0..1}
  @impl true
  def year_of_era(year) when is_integer(year) and year > 0, do: {year, 1}
  def year_of_era(year) when is_integer(year) and year < 1, do: {abs(year) + 1, 0}

  defp offset_to_string(utc, std, zone, format \\ :extended)
  defp offset_to_string(0, 0, "Etc/UTC", _format), do: "Z"
  defp offset_to_string(utc, std, _zone, format) do
    total = utc + std
    second = abs(total)
    minute = second |> rem(3600) |> div(60)
    hour = div(second, 3600)
    format_offset(total, hour, minute, format)
  end

  defp format_offset(total, hour, minute, :extended) do
    sign(total) <> zero_pad(hour, 2) <> ":" <> zero_pad(minute, 2)
  end

  defp format_offset(total, hour, minute, :basic) do
    sign(total) <> zero_pad(hour, 2) <> zero_pad(minute, 2)
  end

  defp zone_to_string(0, 0, _abbr, "Etc/UTC"), do: ""
  defp zone_to_string(_, _, abbr, zone), do: " " <> abbr <> " " <> zone

  defp sign(total) when total < 0, do: "-"
  defp sign(_), do: "+"

  defp zero_pad(val, count) do
    num = Integer.to_string(val)
    :binary.copy("0", count - byte_size(num)) <> num
  end

end
