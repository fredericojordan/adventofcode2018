#!/usr/bin/env elixir
defmodule Puzzle02 do
  @moduledoc """
  Confident that your list of box IDs is complete, you're ready to find the boxes full of prototype fabric.

  The boxes will have IDs which differ by exactly one character at the same position in both strings. For example, given the following box IDs:

  abcde
  fghij
  klmno
  pqrst
  fguij
  axcye
  wvxyz
  The IDs abcde and axcye are close, but they differ by two characters (the second and fourth). However, the IDs fghij and fguij differ by exactly one character, the third (h and u). Those must be the correct boxes.

  What letters are common between the two correct box IDs? (In the example above, this is found by removing the differing character from either ID, producing fgij.)
  """

  defp read_box_ids_file() do
    {:ok, file_content} = File.read("input02.txt")
    
    String.split(file_content, "\n")
  end
  
  defp matching_letters(word1, word2) do
    [word1, word2]
      |> Enum.map(&String.graphemes/1)
      |> List.zip()
      |> Enum.filter(fn {a,b} -> a == b end)
      |> Enum.map(fn {a,b} -> a end)
      |> Enum.reduce(fn x, acc -> acc <> x end)
  end

  def solve do
    read_box_ids_file()
  end
end

IO.puts Puzzle02.solve
