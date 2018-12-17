#!/usr/bin/env elixir
ExUnit.start()

defmodule Puzzle09 do
  @moduledoc """
  --- Day 9: Marble Mania ---

  You talk to the Elves while you wait for your navigation system to initialize. To pass the time, they introduce you to
  their favorite marble game.

  The Elves play this game by taking turns arranging the marbles in a circle according to very particular rules. The
  marbles are numbered starting with 0 and increasing by 1 until every marble has a number.

  First, the marble numbered 0 is placed in the circle. At this point, while it contains only a single marble, it is
  still a circle: the marble is both clockwise from itself and counter-clockwise from itself. This marble is designated
  the current marble.

  Then, each Elf takes a turn placing the lowest-numbered remaining marble into the circle between the marbles that are
  1 and 2 marbles clockwise of the current marble. (When the circle is large enough, this means that there is one marble
  between the marble that was just placed and the current marble.) The marble that was just placed then becomes the
  current marble.

  However, if the marble that is about to be placed has a number which is a multiple of 23, something entirely different
  happens. First, the current player keeps the marble they would have placed, adding it to their score. In addition, the
  marble 7 marbles counter-clockwise from the current marble is removed from the circle and also added to the current
  player's score. The marble located immediately clockwise of the marble that was removed becomes the new current marble.

  For example, suppose there are 9 players. After the marble with value 0 is placed in the middle, each player (shown in
  square brackets) takes a turn. The result of each of those turns would produce circles of marbles like this, where
  clockwise is to the right and the resulting current marble is in parentheses:

  [-] (0)
  [1]  0 (1)
  [2]  0 (2) 1
  [3]  0  2  1 (3)
  [4]  0 (4) 2  1  3
  [5]  0  4  2 (5) 1  3
  [6]  0  4  2  5  1 (6) 3
  [7]  0  4  2  5  1  6  3 (7)
  [8]  0 (8) 4  2  5  1  6  3  7
  [9]  0  8  4 (9) 2  5  1  6  3  7
  [1]  0  8  4  9  2(10) 5  1  6  3  7
  [2]  0  8  4  9  2 10  5(11) 1  6  3  7
  [3]  0  8  4  9  2 10  5 11  1(12) 6  3  7
  [4]  0  8  4  9  2 10  5 11  1 12  6(13) 3  7
  [5]  0  8  4  9  2 10  5 11  1 12  6 13  3(14) 7
  [6]  0  8  4  9  2 10  5 11  1 12  6 13  3 14  7(15)
  [7]  0(16) 8  4  9  2 10  5 11  1 12  6 13  3 14  7 15
  [8]  0 16  8(17) 4  9  2 10  5 11  1 12  6 13  3 14  7 15
  [9]  0 16  8 17  4(18) 9  2 10  5 11  1 12  6 13  3 14  7 15
  [1]  0 16  8 17  4 18  9(19) 2 10  5 11  1 12  6 13  3 14  7 15
  [2]  0 16  8 17  4 18  9 19  2(20)10  5 11  1 12  6 13  3 14  7 15
  [3]  0 16  8 17  4 18  9 19  2 20 10(21) 5 11  1 12  6 13  3 14  7 15
  [4]  0 16  8 17  4 18  9 19  2 20 10 21  5(22)11  1 12  6 13  3 14  7 15
  [5]  0 16  8 17  4 18(19) 2 20 10 21  5 22 11  1 12  6 13  3 14  7 15
  [6]  0 16  8 17  4 18 19  2(24)20 10 21  5 22 11  1 12  6 13  3 14  7 15
  [7]  0 16  8 17  4 18 19  2 24 20(25)10 21  5 22 11  1 12  6 13  3 14  7 15

  The goal is to be the player with the highest score after the last marble is used up. Assuming the example above ends
  after the marble numbered 25, the winning score is 23+9=32 (because player 5 kept marble 23 and removed marble 9,
  while no other player got any points in this very short example game).

  Here are a few more examples:

  10 players; last marble is worth 1618 points: high score is 8317
  13 players; last marble is worth 7999 points: high score is 146373
  17 players; last marble is worth 1104 points: high score is 2764
  21 players; last marble is worth 6111 points: high score is 54718
  30 players; last marble is worth 5807 points: high score is 37305

  What is the winning Elf's score?
  """
  use ExUnit.Case, async: true

  defp read_game_description_file() do
    {:ok, file_content} = File.read("input09.txt")

    file_content
    |> String.split(" ")
    |> Enum.to_list()
    |> (fn [players, _, _, _, _, _, points, _] -> [players, points] end).()
    |> Enum.map(&String.to_integer/1)
  end

  defp next_spot([], 0), do: 0
  defp next_spot(list, current), do: rem(current+1, Enum.count(list)) + 1

  defp tr_fn({player, marble}, {list, current, points}) when rem(marble, 23) == 0 do
    len = Enum.count(list)
    pop_pos = rem(current+len-8, len) + 1
    {removed, new_list} = List.pop_at(list, pop_pos)
    new_points = Map.update(points, player, marble+removed, &(&1 + marble+removed))
    {[{new_list, pop_pos, new_points}], {new_list, pop_pos, new_points}}
  end

  defp tr_fn({_player, marble}, {list, current, points}) do
    next = next_spot(list, current)
    new_list = List.insert_at(list, next, marble)
    {[{new_list, next, points}], {new_list, next, points}}
  end

  defp get_max_score({_list, _position, points}), do: Enum.max(Map.values(points))

  defp winning_elf_score(players, last_marble) do
    Stream.iterate({1, 1}, fn {player, marble} -> {rem(player, players)+1, marble+1} end)
    |> Stream.transform({[0], 0, %{}}, &tr_fn/2)
    |> Enum.take(last_marble)
    |> Enum.take(-1)
    |> List.first()
    |> get_max_score()
  end

  def solve do
    assert 8317   = winning_elf_score(10, 1618)
    assert 146373 = winning_elf_score(13, 7999)
    assert 2764   = winning_elf_score(17, 1104)
    assert 54718  = winning_elf_score(21, 6111)
    assert 37305  = winning_elf_score(30, 5807)

    [players, last_marble] = read_game_description_file()
    winning_elf_score(players, last_marble)
  end
end

IO.inspect Puzzle09.solve
