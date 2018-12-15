#!/usr/bin/env elixir
defmodule Puzzle03 do
  @moduledoc """
  --- Part Two ---

  Amidst the chaos, you notice that exactly one claim doesn't overlap by even a single square inch of fabric with any
  other claim. If you can somehow draw attention to it, maybe the Elves will be able to make Santa's suit after all!

  For example, in the claims above, only claim 3 is intact after all claims are made.

  What is the ID of the only claim that doesn't overlap?
  """

  defp parse_line(line) do
    line
    |> String.split(["#", " @ ", ",", ": ", "x"])
    |> Enum.drop(1)  # Elixir splits starting character with leading empty string
    |> Enum.map(&String.to_integer/1)
  end

  defp filled_spots([x, y, w, h]) do
    for a <- x..x+w-1,
        b <- y..y+h-1, do:
          {a, b}
  end

  defp read_fabric_claims_file() do
    {:ok, file_content} = File.read("input03.txt")

    file_content
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp overlaps?([_id, x, y, w, h], used_fabric) do
    filled_spots([x, y, w, h])
    |> Enum.any?(fn x -> used_fabric[x] > 1 end)
  end

  def solve do
    used_fabric =
      read_fabric_claims_file()
      |> Stream.flat_map(fn [_id, x, y, w, h] -> filled_spots([x, y, w, h]) end)
      |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)

    read_fabric_claims_file()
    |> Stream.drop_while(fn x -> overlaps?(x, used_fabric) end)
    |> Enum.take(1)
    |> List.first()
    |> List.first()
  end
end

IO.inspect Puzzle03.solve
