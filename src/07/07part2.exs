#!/usr/bin/env elixir
defmodule Puzzle07 do
  @moduledoc """
  --- Part Two ---

  As you're about to begin construction, four of the Elves offer to help. "The sun will set soon; it'll go faster if we
  work together." Now, you need to account for multiple people working on steps simultaneously. If multiple steps are
  available, workers should still begin them in alphabetical order.

  Each step takes 60 seconds plus an amount corresponding to its letter: A=1, B=2, C=3, and so on. So, step A takes
  60+1=61 seconds, while step Z takes 60+26=86 seconds. No time is required between steps.

  To simplify things for the example, however, suppose you only have help from one Elf (a total of two workers) and that
  each step takes 60 fewer seconds (so that step A takes 1 second and step Z takes 26 seconds). Then, using the same
  instructions as above, this is how each second would be spent:

  Second   Worker 1   Worker 2   Done
     0        C          .
     1        C          .
     2        C          .
     3        A          F       C
     4        B          F       CA
     5        B          F       CA
     6        D          F       CAB
     7        D          F       CAB
     8        D          F       CAB
     9        D          .       CABF
    10        E          .       CABFD
    11        E          .       CABFD
    12        E          .       CABFD
    13        E          .       CABFD
    14        E          .       CABFD
    15        .          .       CABFDE

  Each row represents one second of time. The Second column identifies how many seconds have passed as of the beginning
  of that second. Each worker column shows the step that worker is currently doing (or . if they are idle). The Done
  column shows completed steps.

  Note that the order of the steps has changed; this is because steps now take time to finish and multiple workers can
  begin multiple steps simultaneously.

  In this example, it would take 15 seconds for two workers to complete these steps.

  With 5 workers and the 60+ second step durations described above, how long will it take to complete all of the steps?
  """

  defp read_instructions_file() do
    {:ok, file_content} = File.read("input07.txt")

    file_content
    |> String.split("\n")
    |> Enum.map(&(String.split(&1, " ")))
    |> Enum.map(fn [_, a, _, _, _, _, _, b, _, _] -> [a, b] end)
  end

  defp step_duration(id) do
    id
    |> String.to_charlist()
    |> List.first()
    |> fn x -> x - 4 end .()
  end

  defp unf_fn({done, working, {tasks, dependencies}}) do
    after_step =
      working
      |> Enum.map(fn {id, min} -> {id, min-1} end)
      |> Map.new()

    finished_steps =
      after_step
      |> Enum.filter(fn {_id, min} -> min <= 0 end)
      |> Enum.map(fn {id, _min} -> id end)

    new_done = done ++ finished_steps

    newly_available =
      tasks
      |> Enum.filter(fn x -> Enum.all?(Map.get(dependencies, x, []), &(Enum.member?(new_done, &1))) end)
      |> Enum.filter(fn x -> !Enum.member?(done, x) end)
      |> Enum.filter(fn x -> !Enum.member?(Map.keys(working), x) end)
      |> Enum.sort()

    still_working =
      after_step
      |> Enum.filter(fn {_id, min} -> min > 0 end)
      |> Map.new()

    starting_steps = Enum.take(newly_available, 5 - Enum.count(still_working))

    new_working = Enum.reduce(
      starting_steps,
      still_working,
      fn id, acc -> Map.update(acc, id, step_duration(id), fn _ -> step_duration(id) end) end
    )

    if new_working == %{} do
      nil
    else
      {new_working, {
        new_done,
        new_working,
        {tasks, dependencies},
      }}
    end
  end

  def solve do
    tasks =
      read_instructions_file()
      |> Enum.to_list()
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()

    dependencies =
      read_instructions_file()
      |> Enum.reduce(%{}, fn [a, b], acc -> Map.update(acc, b, [a], &(&1 ++ [a])) end)

    {[], %{}, {tasks, dependencies}}
    |> Stream.unfold(&unf_fn/1)
    |> Enum.to_list()
    |> Enum.count()
  end
end

IO.inspect Puzzle07.solve
