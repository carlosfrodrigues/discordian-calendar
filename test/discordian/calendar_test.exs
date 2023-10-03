defmodule Discordian.CalendarTest do
  use ExUnit.Case
  doctest Discordian.Calendar

  @valid_year 2023
  @valid_season 3
  @valid_day 36

  test "day_of_week with valid input returns correct day of week" do
    assert Discordian.Calendar.day_of_week(@valid_year, @valid_season, @valid_day, :default) == "Boomtime"
  end

  test "day_of_week with invalid input raises error" do
    assert_raise FunctionClauseError, fn ->
      Discordian.Calendar.day_of_week(@valid_year, 10, "invalid_day", :default)
    end
  end
end
