defmodule DiscordianTest do
  use ExUnit.Case
  doctest Discordian

  test "St. Tibs Day" do
    assert Discordian.to_gregorian({3166, 6, 6}) == {2000, 2, 29}
  end

  test "Day after St. Tibs" do
    assert Discordian.to_gregorian({3166, 1, 60}) == {2000, 3, 1}
  end

  test "Convert to discordian" do
    assert Discordian.to_discordian({2021, 2, 14}) == {3187, 1, 45}
  end

  test "Last day of year" do
    assert Discordian.to_discordian({2021, 12, 31}) == {3187, 5, 73}
  end
end
