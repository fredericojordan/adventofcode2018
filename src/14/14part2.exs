#!/usr/bin/env elixir
ExUnit.start()

defmodule Puzzle14 do
  @moduledoc """
  --- Part Two ---
  As it turns out, you got the Elves' plan backwards. They actually want to know how many recipes appear on the scoreboard to the left of the first recipes whose scores are the digits from your puzzle input.

  - 51589 first appears after 9 recipes.
  - 01245 first appears after 5 recipes.
  - 92510 first appears after 18 recipes.
  - 59414 first appears after 2018 recipes.

  How many recipes appear on the scoreboard to the left of the score sequence in your puzzle input?
  """
  use ExUnit.Case, async: true

  defp next_tick({recipes, len, elf_positions, elf_recipes}) do
    new_recipes =
      elf_recipes
      |> Enum.sum()
      |> Integer.digits()

    next_recipes =
      new_recipes
      |> Enum.zip(0..5)
      |> Enum.reduce(recipes, fn {rec, i}, acc -> Map.put(acc, len+i, rec) end)

    new_len = len + Enum.count(new_recipes)

    next_positions =
      elf_positions
      |> Enum.zip(elf_recipes)
      |> Enum.map(fn {pos, score} -> rem(pos + score + 1, new_len) end)

    next_scores = Enum.map(next_positions, fn pos -> Map.get(next_recipes, pos) end)

    {
      {recipes, len},
      {next_recipes, len+Enum.count(new_recipes), next_positions, next_scores}
    }
  end

  defp recipes_before(score_string) do
    digits =
      score_string
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    {%{0=>3, 1=>7}, 2, [0, 1], [3, 7]}
    |> Stream.unfold(&next_tick/1)
    |> Enum.reduce_while(nil, fn x, _acc -> reduce_until_found(digits, x) end)
  end

  defp reduce_until_found(digits, {recipes, size}) do
    len = length(digits)

    starting_index = size-len-1
    index =
      starting_index..size-1
      |> Enum.map(fn x -> Map.get(recipes, x) end)
      |> Enum.chunk_every(len, 1, :discard)
      |> Enum.find_index(fn x -> x == digits end)

    case index do
      nil -> {:cont, nil}
      i -> {:halt, starting_index+i}
    end
  end

  def solve do
    assert recipes_before("01245") == 5
    assert recipes_before("51589") == 9
    assert recipes_before("92510") == 18
    assert recipes_before("59414") == 2018

    {:ok, input} = File.read("input14.txt")

    recipes_before(input)
  end
end

IO.inspect Puzzle14.solve
