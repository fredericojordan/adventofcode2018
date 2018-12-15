#!/usr/bin/env elixir
defmodule Puzzle05 do
  @moduledoc """
  --- Part Two ---

  Time to improve the polymer.

  One of the unit types is causing problems; it's preventing the polymer from collapsing as much as it should. Your goal
  is to figure out which unit type is causing the most problems, remove all instances of it (regardless of polarity),
  fully react the remaining polymer, and measure its length.

  For example, again using the polymer dabAcCaCBAcCcaDA from above:

  Removing all A/a units produces dbcCCBcCcD. Fully reacting this polymer produces dbCBcD, which has length 6.
  Removing all B/b units produces daAcCaCAcCcaDA. Fully reacting this polymer produces daCAcaDA, which has length 8.
  Removing all C/c units produces dabAaBAaDA. Fully reacting this polymer produces daDA, which has length 4.
  Removing all D/d units produces abAcCaCBAcCcaA. Fully reacting this polymer produces abCBAc, which has length 6.
  In this example, removing all C/c units was best, producing the answer 4.

  What is the length of the shortest polymer you can produce by removing all units of exactly one type and fully
  reacting the result?
  """

  defp read_polymer_file() do
    {:ok, file_content} = File.read("input05.txt")

    file_content
  end

  defp destroys?([a,b]) do
    Enum.all?([
      String.upcase(a) == String.upcase(b),
      String.downcase(a) == String.downcase(b),
      a != b,
    ])
  end

  defp reducing_fn(x, []), do: {:cont, [x]}

  defp reducing_fn(x, [head|tail]) do
    if destroys?([x, head]) do
      {:cont, tail}
    else
      {:cont, [x|[head|tail]]}
    end
  end

  defp remove_unit(polymer, unit) do
    polymer
    |> String.graphemes()
    |> Enum.reject(fn x -> String.downcase(x) == unit end)
    |> Enum.reduce(&Kernel.<>/2)
  end

  def solve do
    polymer = read_polymer_file()

    polymer_units =
      polymer
      |> String.graphemes()
      |> Enum.reduce(MapSet.new(), fn x, acc -> MapSet.put(acc, String.downcase(x)) end)

    polymer_units
      |> Enum.map(fn x -> remove_unit(polymer, x) end)
      |> Enum.map(fn x -> Enum.reduce_while(String.graphemes(x), [], &reducing_fn/2) end)
      |> Enum.map(&Enum.count/1)
      |> Enum.min()
  end
end

IO.inspect Puzzle05.solve
