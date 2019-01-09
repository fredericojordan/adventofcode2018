#!/usr/bin/env elixir
defmodule Puzzle13 do
  @moduledoc """
  --- Part Two ---

  There isn't much you can do to prevent crashes in this ridiculous system. However, by predicting the crashes, the
  Elves know where to be in advance and instantly remove the two crashing carts the moment any crash occurs.

  They can proceed like this for a while, but eventually, they're going to run out of carts. It could be useful to
  figure out where the last cart that hasn't crashed will end up.

  For example:

  />-<\
  |   |
  | /<+-\
  | | | v
  \>+</ |
    |   ^
    \<->/

  /---\
  |   |
  | v-+-\
  | | | |
  \-+-/ |
    |   |
    ^---^

  /---\
  |   |
  | /-+-\
  | v | |
  \-+-/ |
    ^   ^
    \---/

  /---\
  |   |
  | /-+-\
  | | | |
  \-+-/ ^
    |   |
    \---/

  After four very expensive crashes, a tick ends with only one cart remaining; its final location is 6,4.

  What is the location of the last cart at the end of the first tick where it is the only cart left?
  """

  defp read_map_file() do
    {:ok, file_content} = File.read("input13.txt")

    String.split(file_content, "\n")
  end

  defp has_cart?(x), do: String.contains?(x, ["^", "<", ">", "v"])

  defp sort_carts(carts), do: Enum.sort_by(carts, fn {{x, y}, _direction, _turn_counter } -> x + 1000*y end)

  defp parse_map(contents) do
    contents
    |> Enum.map(fn line -> String.graphemes(line) end)
    |> Enum.zip(0..Enum.count(contents)-1)
    |> Enum.map(fn {line, y} -> Enum.zip(
                                  line,
                                  Enum.map(0..Enum.count(line)-1, fn x -> {x, y} end)
                                ) end)
    |> List.flatten()
    |> Enum.reject(fn {square, _coords} -> square == " " end)
    |> Enum.reduce(%{}, fn {square, coords}, acc -> Map.put(acc, coords, square) end)
  end

  defp clean_map(raw_map) do
    raw_map
    |> Enum.reduce(%{}, fn
      {coords, "^"}, acc -> Map.put(acc, coords, "|")
      {coords, "v"}, acc -> Map.put(acc, coords, "|")
      {coords, "<"}, acc -> Map.put(acc, coords, "-")
      {coords, ">"}, acc -> Map.put(acc, coords, "-")
      {coords, square}, acc -> Map.put(acc, coords, square)
    end)
  end

  defp get_carts(raw_map) do
    raw_map
    |> Enum.filter(fn {_coords, square} -> has_cart?(square) end)
    |> Enum.map(fn
      {coords, ">"} -> {coords, 0}
      {coords, "^"} -> {coords, 1}
      {coords, "<"} -> {coords, 2}
      {coords, "v"} -> {coords, 3}
    end)
    |> Enum.map(fn {coords, direction} -> {coords, direction, 0} end)
    |> sort_carts()
  end

  defp advance_cart({{x, y}, 0, turn_counter}), do: {{x+1, y}, 0, turn_counter}
  defp advance_cart({{x, y}, 1, turn_counter}), do: {{x, y-1}, 1, turn_counter}
  defp advance_cart({{x, y}, 2, turn_counter}), do: {{x-1, y}, 2, turn_counter}
  defp advance_cart({{x, y}, 3, turn_counter}), do: {{x, y+1}, 3, turn_counter}

  defp rotate_cart({coords, direction, turn_counter}, map) do
    turns = [1, 0, 3]

    case {Map.get(map, coords), rem(direction, 2)} do
      {"\\", 0} -> {coords, rem(direction+3, 4), turn_counter}
      {"\\", 1} -> {coords, rem(direction+1, 4), turn_counter}
      {"/", 0} -> {coords, rem(direction+1, 4), turn_counter}
      {"/", 1} -> {coords, rem(direction+3, 4), turn_counter}
      {"+", _} ->
        {
          coords,
          rem(direction+Enum.at(turns, rem(turn_counter,3)), 4),
          turn_counter+1
        }
      _ -> {coords, direction, turn_counter}
    end
  end

  defp unf_fn({carts, map}) do
    new_carts =
      carts
      |> sort_carts()
      |> Stream.map(&advance_cart/1)
      |> Stream.map(fn carts -> rotate_cart(carts, map) end)
      |> sort_carts()

    collisions =
      new_carts ++ carts
      |> Enum.group_by(fn {coords, _direction, _turn_counter} -> coords end)
      |> Enum.filter(&match?({_coords, carts} when length(carts) > 1, &1))
      |> Enum.map(fn {coords, _carts} -> coords end)

    non_exploded_carts =
      new_carts
      |> Enum.reject(fn {coords, _direction, _turn_counter} -> Enum.member?(collisions, coords) end)

    {{non_exploded_carts, collisions}, {non_exploded_carts, map}}
  end

  def solve do
    contents = read_map_file()

    raw_map = parse_map(contents)

    map = clean_map(raw_map)

    carts = get_carts(raw_map)

    {carts, map}
    |> Stream.unfold(&unf_fn/1)
    |> Stream.drop_while(fn {carts, _collision} -> length(carts) > 1 end)
    |> Enum.take(1)
    |> List.first()
    |> (fn {[{coords , _direction, _turn_counter}], _collisions} -> coords end).()
  end
end

IO.inspect Puzzle13.solve
