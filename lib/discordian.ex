defmodule Discordian do
  @days_per_leap_year 366
  @days_per_year 365
  def to_discordian({gy, gm, gd}) do
    days_to_discordian(gregorian_to_days({gy, gm, gd}))
  end

  def to_gregorian({dy, 6, 6}), do: {dy - 1166, 02, 29}

  def to_gregorian({dy, dm, dd}) do
    year = dy - 1166
    day_of_year = 73*(dm-1) + dd
    real_day_year =
      case is_leap_year(year) and (dm == 1 and dd >= 60) or dm > 1 do
        true -> day_of_year+1
        false -> day_of_year
      end
    {month, day_of_month} = year_day_to_date(year, real_day_year-1)
    {year, month, day_of_month}
  end

  def is_leap_year(year) when year == 0, do: false
  def is_leap_year(year) when year != 0 do
    cond do
      rem(year,4) == 0 and
      rem(year, 100) == 0 and
      rem(year, 400) == 0 ->
        true
      rem(year,4) == 0 and
      rem(year,100) != 0 ->
        true
      true ->
        false
    end
  end

  @spec discordian_day_year(year :: non_neg_integer(), season :: non_neg_integer(), day :: non_neg_integer()) :: non_neg_integer()
  def discordian_day_year(_, season, day)
      when season >= 1 and season <= 5 and day >= 1 and day <= 73 do
    days_per_season = 73
    (season - 1) * days_per_season + day
  end

  @doc """
  This function converts a discordian date to gregorian days
  """
  def discordian_to_days(year, month, day) do
    {gy, gm, gd} = to_gregorian({year, month, day})
    dy(gy) + dm(gm) + df(gy, gm) + gd - 1
  end

  def discordian_month_lenght(year, month) do
    if (is_leap_year(year) and month == 1), do: 74, else: 73
  end

  def is_valid_discordian_date({year, month, day}) when month == 6 and day == 6, do: is_leap_year(year-1166)

  def is_valid_discordian_date({_year, month, day}) do
    1 <= month and month <= 5 and 1 <= day and day <= 73
  end

  def iso_days_to_discordian(days) do
    {year, day_of_year} = day_to_year(days)
    {month, day_of_month} = year_day_to_date(year, day_of_year)
    case {year, month, day_of_month} do
      {year, 2, 29 } -> {year+1166, 6, 6}
      _ -> to_discordian({year, month, day_of_month})
    end
  end


  #This function uses search interpolation. It was based on the function with the same name on the
  #Erlang/OTP code calendar.erl
  #https://github.com/erlang/otp/blob/master/lib/stdlib/src/calendar.erl

  defp day_to_year(days) when days >= 0 do
    year_max = div(days, @days_per_year)
    year_min = div(days, @days_per_leap_year)
    {year, day} = dty(year_min, year_max, days, dy(year_min), dy(year_max))
    {year, days - day}
  end

  defp dty(min, max, _d1, dmin, _dmax) when min == max, do: {min, dmin}

  defp dty(min, max, d1, dmin, dmax) do
    diff = max - min
    mid = min + div((diff*(d1 - dmin)), dmax - dmin)
    mid_length =
      case is_leap_year(mid) do
        true -> @days_per_leap_year
        false -> @days_per_year
      end
    case dy(mid) do
      d2 when d1 < d2 ->
        new_max = mid - 1
        dty(min, new_max, d1, dmin, dy(new_max))
      d2 when d1 - d2 >= mid_length ->
        new_min = mid + 1
        dty(new_min, max, d1, dy(new_min), dmax)
      d2 ->
        {mid, d2}
    end
  end

  #return the days in previous years
  defp dy(year) when year <= 0, do: 0
  defp dy(year) do
    previous_year = year - 1
    div(previous_year, 4) - div(previous_year, 100) + div(previous_year, 400) +
      previous_year*@days_per_year
  end

  #acount extra day if leap year in gregorian calendar
  defp df(_year, month) when month < 3, do: 0
  defp df(year, _month) do
    case is_leap_year(year) do
      true -> 1
      false -> 0
    end
  end

  #return the total number of days in all months
  defp dm(month) when month >= 1 and month <= 12 do
    (month - 1) * 30 + div(month - 2, 2)
  end

  defp year_day_to_date(year, day_of_year) do
    extra_day =
    case is_leap_year(year) do
      true -> 1
      false -> 0
    end
    {month, day} = year_day_to_date2(extra_day, day_of_year)
    {month, day+1}
  end

  defp year_day_to_date2(_, day) when day < 31, do: {1, day}
  defp year_day_to_date2(e, day) when 31 <= day and day < 59 + e, do: {2, day - 31}
  defp year_day_to_date2(e, day) when 59 + e <= day and day < 90 + e, do: {3, day - (59 + e)}
  defp year_day_to_date2(e, day) when 90 + e <= day and day < 120 + e, do: {4, day - (90 + e)}
  defp year_day_to_date2(e, day) when 120 + e <= day and day < 151 + e, do: {5, day - (120 + e)}
  defp year_day_to_date2(e, day) when 151 + e <= day and day < 181 + e, do: {6, day - (151 + e)}
  defp year_day_to_date2(e, day) when 181 + e <= day and day < 212 + e, do: {7, day - (181 + e)}
  defp year_day_to_date2(e, day) when 212 + e <= day and day < 243 + e, do: {8, day - (212 + e)}
  defp year_day_to_date2(e, day) when 243 + e <= day and day < 273 + e, do: {9, day - (243 + e)}
  defp year_day_to_date2(e, day) when 273 <= day and day < 304 + e, do: {10, day - (273 + e)}
  defp year_day_to_date2(e, day) when 304 <= day and day < 334 + e, do: {11, day - (304 + e)}
  defp year_day_to_date2(e, day) when 334 + e <= day, do: {12, day - (334 + e)}



  @spec gregorian_to_days({Integer.t, Integer.t, Integer.t}) :: {Integer.t, Integer.t}
  defp gregorian_to_days({gy, gm, gd}) do
    months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    days =
      case gm-2 >= 0 do
        true -> gd + (Enum.slice(months, 0..(gm-2)) |> Enum.sum)
        false -> gd
      end

    if (is_leap_year(gy) and gm > 2), do: {days, gy}, else: {days, gy}
  end

  @spec days_to_discordian({Integer.t, Integer.t}) :: {Integer.t, Integer.t, Integer.t}
  defp days_to_discordian({days, year}) do
    month = div(days-1, 73)+1
    day = days - (month-1)*73
    {year + 1166, month, day}
  end
end
