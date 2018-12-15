#!/usr/bin/env elixir
defmodule Puzzle04 do
  @moduledoc """
  --- Part Two ---

  Strategy 2: Of all guards, which guard is most frequently asleep on the same minute?

  In the example above, Guard #99 spent minute 45 asleep more than any other guard or minute - three times in total.
  (In all other cases, any guard spent any minute asleep at most twice.)

  What is the ID of the guard you chose multiplied by the minute you chose? (In the above example, the answer would be
  99 * 45 = 4455.)
  """

  defp read_log_file() do
    {:ok, file_content} = File.read("input04.txt")

    String.split(file_content, "\n")
  end

  defp parse_minutes(<<_::bytes-size(15)>> <> <<minutes::bytes-size(2)>> <> _), do: String.to_integer(minutes)

  defp get_guard_id(entry) do
    entry
    |> String.split(" ")
    |> Enum.at(3)
    |> String.trim_leading("#")
    |> String.to_integer()
  end

  defp chunking_fn(item, []), do: {:cont, [item]}
  defp chunking_fn(<<head::bytes-size(19)>> <> "G" <> tail, acc), do: {:cont, Enum.reverse(acc), [head <> "G" <> tail]}
  defp chunking_fn(item, acc), do: {:cont, [item | acc]}

  def solve do
    read_log_file()
    |> Enum.sort_by(fn "[" <> <<time::bytes-size(16)>> <> _ -> time end)
    |> Enum.chunk_while([], &chunking_fn/2, fn acc -> {:cont, Enum.reverse(acc), []} end)
    |> Enum.map(fn [head|tail] -> {get_guard_id(head), Enum.map(tail, &parse_minutes/1)} end)
    |> Enum.map(fn {id, minute_list} -> {id, Enum.chunk_every(minute_list, 2)} end)
    |> Enum.map(fn {id, naps} -> {id, Enum.map(naps, fn [a,b] -> a..b-1 end)} end)
    |> Enum.reduce(%{}, fn {id, naps}, acc -> Map.update(acc, id, naps, &(&1 ++ naps)) end)
    |> Enum.map(fn {k, naps} -> {k, for t <- 0..59 do Enum.count(naps, &(Enum.member?(&1, t))) end} end)
    |> Enum.max_by(fn {_, naps} -> Enum.max(naps) end)
    |> (fn {id, naps} -> {id, Enum.find_index(naps, &(&1 ==Enum.max(naps)))} end).()
    |> (fn {id, minute} -> id * minute end).()
  end
end

IO.inspect Puzzle04.solve
