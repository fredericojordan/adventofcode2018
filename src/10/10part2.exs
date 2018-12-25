#!/usr/bin/env elixir
defmodule Puzzle10 do
  @moduledoc """
  --- Part Two ---

  Good thing you didn't have to wait, because that would have taken a long time - much longer than the 3 seconds in the example above.

  Impressed by your sub-hour communication capabilities, the Elves are curious: exactly how many seconds would they have needed to wait for that message to appear?
  """

  defp read_light_points_file() do
    {:ok, file_content} = File.read("input10.txt")

    file_content
    |> String.split("\n")
    |> Stream.map(&(String.split(&1, ["<", ",", ">"])))
    |> Stream.map(fn [_, px, py, _, vx, vy, _] -> [px, py, vx, vy] end)
    |> Stream.map(fn x -> Enum.map(x, &(String.to_integer(String.trim(&1)))) end)
    |> Enum.to_list()
  end

  defp update_positions(state), do: Enum.map(state, fn [px, py, vx, vy] -> [px+vx, py+vy, vx, vy] end)

  defp is_scrambled?(state) do
    state
    |> Enum.reduce(%{}, fn [px, _py, _vx, _vy], acc -> Map.update(acc, px, 1, &(&1+1)) end)
    |> Map.values()
    |> Enum.max()
    |> Kernel.<(20)
  end

  def solve do
    [px0, _, vx, _] =
      read_light_points_file()
      |> Enum.take(1)
      |> List.first()

    [px1, _, _, _] =
      Stream.iterate(read_light_points_file(), &update_positions/1)
      |> Stream.drop(10000)
      |> Stream.drop_while(&is_scrambled?/1)
      |> Enum.take(1)
      |> List.first()
      |> Enum.take(1)
      |> List.first()

    (px1-px0)/vx
  end
end

IO.inspect Puzzle10.solve
