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

  defp unf_fn({recipes, elf_positions}) do
    new_positions = Enum.map(
      elf_positions,
      fn pos -> rem(pos + 1 + Enum.at(recipes, pos), Enum.count(recipes)) end
    )

    new_recipes =
      new_positions
      |> Enum.map(fn pos -> Enum.at(recipes, pos) end)
      |> Enum.sum()
      |> Integer.digits()

    {recipes, {recipes++new_recipes, new_positions}}
  end

  defp recipes_before(score_string) do
    {[3, 7], [0, 1]}
    |> Stream.unfold(&unf_fn/1)
    |> Stream.drop_while(fn x -> length(String.split(
                                   Integer.to_string(Integer.undigits(x)),
                                   score_string
                                 )) <= 1 end)
    |> Enum.take(1)
    |> List.first()
    |> (fn recipes -> Integer.to_string(Integer.undigits(recipes)) end).()
    |> (fn recipes_string -> String.split(recipes_string, score_string) end).()
    |> (fn [head | _tail] -> String.length(head) end).()
  end

  def solve do
    assert recipes_before("01245") == 5
    assert recipes_before("51589") == 9
    assert recipes_before("92510") == 18
    assert recipes_before("59414") == 2018

    {:ok, input} = File.read("input14.txt")
#    recipes_before(input)
  end
end

IO.inspect Puzzle14.solve
