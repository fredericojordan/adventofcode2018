#!/usr/bin/env elixir
defmodule Puzzle06 do
  @moduledoc """
  The device on your wrist beeps several times, and once again you feel like you're falling.

  "Situation critical," the device announces. "Destination indeterminate. Chronal interference detected. Please specify new target coordinates."

  The device then produces a list of coordinates (your puzzle input). Are they places it thinks are safe or dangerous? It recommends you check manual page 729. The Elves did not give you a manual.

  If they're dangerous, maybe you can minimize the danger by finding the coordinate that gives the largest distance from the other points.

  Using only the Manhattan distance, determine the area around each coordinate by counting the number of integer X,Y locations that are closest to that coordinate (and aren't tied in distance to any other coordinate).

  Your goal is to find the size of the largest area that isn't infinite. For example, consider the following list of coordinates:

  1, 1
  1, 6
  8, 3
  3, 4
  5, 5
  8, 9
  If we name these coordinates A through F, we can draw them on a grid, putting 0,0 at the top left:

  ..........
  .A........
  ..........
  ........C.
  ...D......
  .....E....
  .B........
  ..........
  ..........
  ........F.
  This view is partial - the actual grid extends infinitely in all directions. Using the Manhattan distance, each location's closest coordinate can be determined, shown here in lowercase:

  aaaaa.cccc
  aAaaa.cccc
  aaaddecccc
  aadddeccCc
  ..dDdeeccc
  bb.deEeecc
  bBb.eeee..
  bbb.eeefff
  bbb.eeffff
  bbb.ffffFf
  Locations shown as . are equally far from two or more coordinates, and so they don't count as being closest to any.

  In this example, the areas of coordinates A, B, C, and F are infinite - while not shown here, their areas extend forever outside the visible grid. However, the areas of coordinates D and E are finite: D is closest to 9 locations, and E is closest to 17 (both including the coordinate's location itself). Therefore, in this example, the size of the largest area is 17.

  What is the size of the largest area that isn't infinite?
  """

  defp read_coordinates_file() do
    {:ok, file_content} = File.read("input06.txt")

    file_content
    |> String.split([", ", "\n"])
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk(2)
  end

  defp manhattan_distance([x1, y1], [x2, y2]), do: abs(x1-x2)+abs(y1-y2)

  defp closests(coords, [x, y]) do
    distances =
      coords
      |> Enum.map(&(manhattan_distance(&1, [x, y])))

    min = Enum.min(distances)

    distances
    |> Enum.with_index(1)
    |> Enum.filter(fn {x, _} -> x == min end)
  end

  defp r_fn([{_, index}], acc), do: Map.update(acc, index, 1, &(&1+1))
  defp r_fn(_, acc), do: acc

  defp f_fn({[x, y], [{_distance, _id}]}), do: x == 0 or y == 0
  defp f_fn(_), do: false

  def solve do
    coords = read_coordinates_file()

    max_coord =
      coords
      |> Enum.max_by(&Enum.max/1)
      |> Enum.max()

    infinite_areas =
      for x <- 0..max_coord,
          y <- 0..max_coord do
          [x, y]
      end
      |> Enum.map(&({&1, closests(coords, &1)}))
      |> Enum.filter(&f_fn/1)
      |> Enum.map(fn {_, [{_distance, id}]} -> id end)
      |> Enum.uniq()

    for x <- 0..max_coord,
        y <- 0..max_coord do
        [x, y]
    end
    |> Enum.map(&(closests(coords, &1)))
    |> Enum.reduce(%{}, &r_fn/2)
    |> Enum.filter(fn {id, _size} -> !Enum.member?(infinite_areas, id) end)
    |> Enum.max_by(fn {_id, size} -> size end)
    |> fn {_id, size} -> size end . ( )   # hahahahaha
  end
end

IO.inspect Puzzle06.solve
