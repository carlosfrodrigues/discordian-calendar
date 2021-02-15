# Discordian Calendar ![Hex.pm](https://img.shields.io/hexpm/v/discordian?style=flat-square)

An implementation of the [Discordian Calendar](https://en.wikipedia.org/wiki/Discordian_calendar) built using the Elixir Calendar behaviour

## Usage
You can create a Date in Gregorian Calendar and convert it to Discordian Calendar:
```elixir
{:ok, date} = Date.new(2020, 12, 3, Calendar.ISO)
{:ok, ~D[2020-12-03]}
```
```elixir
{:ok, dicord_date} = Date.convert(date, Discordian.Calendar)
{:ok, ~D[3186-05-45 Discordian.Calendar]}
```
Or you can convert from discordian to gregorian:
```elixir
{:ok, discord} = Date.new(3166, 1, 60, Discordian.Calendar)
{:ok, ~D[3166-01-60 Discordian.Calendar]}
```
```elixir
{:ok, date} = Date.convert(discord, Calendar.ISO)
{:ok, ~D[2000-03-01]}
```
## St. Tib's day
St. Tib's day is an extra day that doesn't count and is equivalent to the February 29 in a leap year. 
Because it is between the Chaos 59 and Chaos 60 I put it representation as month 6 and day 6. 
So, for example, in the year 3166(equivalent to 2000 in the gregorian calendar) the St. Tib's day is 6-6-3166 and it's between 1-59-3166 and 1-60-3166. 
The discordian calendar has only five months so this day in month 6 doesn't mess up with the whole calendar.

## Installation

This package is [available in Hex](https://hexdocs.pm/discordian/0.1.0), it can be installed by adding `discordian` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:discordian, "~> 0.1.0"}
  ]
end
```
