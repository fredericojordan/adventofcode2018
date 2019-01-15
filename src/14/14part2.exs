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

  defp unf_fn({recipes, elf_positions, elf_recipes}) do
    len = Enum.count(recipes)

    new_positions =
      elf_positions
      |> Enum.zip(elf_recipes)
      |> Enum.map(fn {pos, score} -> rem(pos + score + 1, len) end)

    new_scores =
      new_positions
      |> Enum.map(fn pos -> Enum.at(recipes, len-pos-1) end)

    new_recipes =
      new_scores
      |> Enum.sum()
      |> Integer.digits()
      |> Enum.reverse()

    {recipes, {new_recipes++recipes, new_positions, new_scores}}
  end

  defp recipes_before(score_string) do
    [a, b, c, d, e, f] =
#    [a, b, c, d, e] =
      score_string
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    {[7, 3], [1, 0], [7, 3]}
    |> Stream.unfold(&unf_fn/1)
    |> Stream.drop_while(fn x -> !(match?([^f, ^e, ^d, ^c, ^b, ^a | _], x) or match?([_, ^f, ^e, ^d, ^c, ^b, ^a | _], x)) end)
#    |> Stream.drop_while(fn x -> !(match?([^e, ^d, ^c, ^b, ^a | _], x) or match?([_, ^e, ^d, ^c, ^b, ^a | _], x)) end)
    |> Enum.take(1)
    |> List.first()
    |> Enum.reverse()
    |> (fn recipes -> Integer.to_string(Integer.undigits(recipes)) end).()
    |> (fn recipes_string -> String.split(recipes_string, score_string) end).()
    |> (fn [head | _tail] -> String.length(head) end).()
  end

  defp score_after(recipe_count) do
    {[7, 3], [1, 0], [7, 3]}
    |> Stream.unfold(&unf_fn/1)
    |> Stream.drop_while(&(length(&1) < recipe_count + 10))
    |> Enum.take(1)
    |> List.first()
    |> Enum.reverse()
    |> Enum.slice(recipe_count, 10)
    |> Integer.undigits()
  end

  def solve do
    assert 0124515891 = score_after(5)
    assert 5158916779 = score_after(9)
    assert 9251071085 = score_after(18)
    assert 5941429882 = score_after(2018)

#    assert recipes_before("01245") == 5
#    assert recipes_before("51589") == 9
#    assert recipes_before("92510") == 18
#    assert recipes_before("59414") == 2018

    {:ok, input} = File.read("input14.txt")
#    score_after(String.to_integer(input))
    recipes_before(input)
  end
end

IO.inspect Puzzle14.solve
