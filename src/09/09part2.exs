#!/usr/bin/env elixir
defmodule Puzzle09 do
  @moduledoc """
  --- Part Two ---

  Amused by the speed of your answer, the Elves are curious:

  What would the new winning Elf's score be if the number of the last marble were 100 times larger?
  """

  defp read_game_description_file() do
    {:ok, file_content} = File.read("input09.txt")

    file_content
    |> String.split(" ")
    |> Enum.to_list()
    |> (fn [players, _, _, _, _, _, points, _] -> [players, points] end).()
    |> Enum.map(&String.to_integer/1)
  end

  defp tr_fn({player, marble}, {left, current, right, points}) when rem(marble, 23) == 0 and length(left) < 7 do
    tr_fn({player, marble}, {left++Enum.reverse(right), current, [], points})
  end

  defp tr_fn({player, marble}, {[l1, l2, l3, l4, l5, l6, l7 | left], current, right, points}) when rem(marble, 23) == 0 do
    new_points = Map.update(points, player, marble+l7, &(&1 + marble+l7))
    {[{left, l6, [l5, l4, l3, l2, l1, current | right], new_points}], {left, l6, [l5, l4, l3, l2, l1, current | right], new_points}}
  end

  defp tr_fn({_player, marble}, {[], current, [], points}) do
    {[{[current], marble, [], points}], {[current], marble, [], points}}
  end

  defp tr_fn({player, marble}, {left, current, [], points}) do
    tr_fn({player, marble}, {[], current, Enum.reverse(left), points})
  end

  defp tr_fn({_player, marble}, {left, current, [r|right], points}) do
    {[{[r|[current|left]], marble, right, points}], {[r|[current|left]], marble, right, points}}
  end

  defp get_max_score({_left, _current, _right, points}), do: Enum.max(Map.values(points))

  defp winning_elf_score(players, last_marble) do
    Stream.iterate({1, 1}, fn {player, marble} -> {rem(player, players)+1, marble+1} end)
    |> Stream.transform({[], 0, [], %{}}, &tr_fn/2)
    |> Stream.drop(last_marble-1)
    |> Enum.take(1)
    |> List.first()
    |> get_max_score()
  end

  def solve do
    [players, last_marble] = read_game_description_file()
    winning_elf_score(players, 100*last_marble)
  end
end

IO.inspect Puzzle09.solve
