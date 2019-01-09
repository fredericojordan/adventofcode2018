#!/usr/bin/env elixir
ExUnit.start()

defmodule Puzzle13 do
  @moduledoc """
  --- Day 13: Mine Cart Madness ---

  A crop of this size requires significant logistics to transport produce, soil, fertilizer, and so on. The Elves are
  very busy pushing things around in carts on some kind of rudimentary system of tracks they've come up with.

  Seeing as how cart-and-track systems don't appear in recorded history for another 1000 years, the Elves seem to be
  making this up as they go along. They haven't even figured out how to avoid collisions yet.

  You map out the tracks (your puzzle input) and see where you can help.

  Tracks consist of straight paths (| and -), curves (/ and \), and intersections (+). Curves connect exactly two
  perpendicular pieces of track; for example, this is a closed loop:

  /----\
  |    |
  |    |
  \----/

  Intersections occur when two perpendicular paths cross. At an intersection, a cart is capable of turning left, turning
  right, or continuing straight. Here are two loops connected by two intersections:

  /-----\
  |     |
  |  /--+--\
  |  |  |  |
  \--+--/  |
     |     |
     \-----/
  Several carts are also on the tracks. Carts always face either up (^), down (v), left (<), or right (>). (On your
  initial map, the track under each cart is a straight path matching the direction the cart is facing.)

  Each time a cart has the option to turn (by arriving at any intersection), it turns left the first time, goes straight
  the second time, turns right the third time, and then repeats those directions starting again with left the fourth
  time, straight the fifth time, and so on. This process is independent of the particular intersection at which the cart
  Has arrived - that is, the cart has no per-intersection memory.

  Carts all move at the same speed; they take turns moving a single step at a time. They do this based on their current
  location: carts on the top row move first (acting from left to right), then carts on the second row move (again from
  left to right), then carts on the third row, and so on. Once each cart has moved one step, the process repeats; each
  of these loops is called a tick.

  For example, suppose there are two carts on a straight track:

  |  |  |  |  |
  v  |  |  |  |
  |  v  v  |  |
  |  |  |  v  X
  |  |  ^  ^  |
  ^  ^  |  |  |
  |  |  |  |  |

  First, the top cart moves. It is facing down (v), so it moves down one square. Second, the bottom cart moves. It is
  facing up (^), so it moves up one square. Because all carts have moved, the first tick ends. Then, the process
  repeats, starting with the first cart. The first cart moves down, then the second cart moves up - right into the first
  cart, colliding with it! (The location of the crash is marked with an X.) This ends the second and last tick.

  Here is a longer example:

  /->-\
  |   |  /----\
  | /-+--+-\  |
  | | |  | v  |
  \-+-/  \-+--/
    \------/

  /-->\
  |   |  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \->--/
    \------/

  /---v
  |   |  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-+>-/
    \------/

  /---\
  |   v  /----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-+->/
    \------/

  /---\
  |   |  /----\
  | /->--+-\  |
  | | |  | |  |
  \-+-/  \-+--^
    \------/

  /---\
  |   |  /----\
  | /-+>-+-\  |
  | | |  | |  ^
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /----\
  | /-+->+-\  ^
  | | |  | |  |
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /----<
  | /-+-->-\  |
  | | |  | |  |
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /---<\
  | /-+--+>\  |
  | | |  | |  |
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /--<-\
  | /-+--+-v  |
  | | |  | |  |
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /-<--\
  | /-+--+-\  |
  | | |  | v  |
  \-+-/  \-+--/
    \------/

  /---\
  |   |  /<---\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \-<--/
    \------/

  /---\
  |   |  v----\
  | /-+--+-\  |
  | | |  | |  |
  \-+-/  \<+--/
    \------/

  /---\
  |   |  /----\
  | /-+--v-\  |
  | | |  | |  |
  \-+-/  ^-+--/
    \------/

  /---\
  |   |  /----\
  | /-+--+-\  |
  | | |  X |  |
  \-+-/  \-+--/
    \------/

  After following their respective paths for a while, the carts eventually crash. To help prevent crashes, you'd like to
  know the location of the first crash. Locations are given in X,Y coordinates, where the furthest left column is X=0
  and the furthest top row is Y=0:

             111
   0123456789012
  0/---\
  1|   |  /----\
  2| /-+--+-\  |
  3| | |  X |  |
  4\-+-/  \-+--/
  5  \------/

  In this example, the location of the first crash is 7,3.
  """
  use ExUnit.Case, async: true

  defp read_map_file() do
    {:ok, file_content} = File.read("input13.txt")
#    {:ok, file_content} = File.read("test_input.txt")

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

    {{new_carts, collisions}, {new_carts, map}}
  end

  def solve do
    contents = read_map_file()

#    Enum.each(contents, &IO.puts/1)

    raw_map = parse_map(contents)

    map = clean_map(raw_map)

    carts = get_carts(raw_map)

    {carts, map}
    |> Stream.unfold(&unf_fn/1)
    |> Stream.drop_while(fn {_carts, collision} -> collision == [] end)
    |> Enum.take(1)
    |> List.first()
    |> (fn {_carts, collisions} -> collisions end).()
    |> List.last()
  end
end

IO.inspect Puzzle13.solve
