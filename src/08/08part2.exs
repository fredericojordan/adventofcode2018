#!/usr/bin/env elixir
defmodule Puzzle08 do
  @moduledoc """
  --- Part Two ---
  The second check is slightly more complicated: you need to find the value of the root node (A in the example above).

  The value of a node depends on whether it has child nodes.

  If a node has no child nodes, its value is the sum of its metadata entries. So, the value of node B is 10+11+12=33,
  and the value of node D is 99.

  However, if a node does have child nodes, the metadata entries become indexes which refer to those child nodes. A
  metadata entry of 1 refers to the first child node, 2 to the second, 3 to the third, and so on. The value of this node
  is the sum of the values of the child nodes referenced by the metadata entries. If a referenced child node does not
  exist, that reference is skipped. A child node can be referenced multiple time and counts each time it is referenced.
  A metadata entry of 0 does not refer to any child node.

  For example, again using the above nodes:

  - Node C has one metadata entry, 2. Because node C has only one child node, 2 references a child node which does not
    exist, and so the value of node C is 0.

  - Node A has three metadata entries: 1, 1, and 2. The 1 references node A's first child node, B, and the 2 references
    node A's second child node, C. Because node B has a value of 33 and node C has a value of 0, the value of node A is
    33+33+0=66.

  So, in this example, the value of the root node is 66.

  What is the value of the root node?
  """

  defp read_tree_file() do
    {:ok, file_content} = File.read("input08.txt")

    file_content
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end


  defp unf_fn({[], _, _, _}), do: nil
  defp unf_fn({[childs | [metas | tail]], [], [], tree}), do: unf_fn({tail, [childs], [metas], tree})

  defp unf_fn({[0 | [metas | tail]], [b|bros], pend, [t|tree]}) do
    value = Enum.sum(Enum.take(tail, metas))

    {
      value,
      {Enum.drop(tail, metas), [b-1|bros], pend, [t++[value]|tree]}
    }
  end

  defp unf_fn({list, [0|bros], [p|pend], [t|tree]}) do
    value =
      Enum.take(list, p)
      |> Enum.map(fn x -> Enum.at(Enum.reverse(t), x-1, 0) end)
      |> Enum.sum()

    new_tree =
      if tree == [] do
        [[value]]
      else
        [nt|ntree] = tree
        [[value]++nt|ntree]
      end

    {
      value,
      {Enum.drop(list, p), bros, pend, new_tree}
    }
  end

  defp unf_fn({[childs | [metas | tail]], [b|bros], pend, tree}), do: unf_fn({tail, [childs|[b-1|bros]], [metas|pend], [[]|tree]})

  def solve do
    {read_tree_file(), [], [], [[]]}
    |> Stream.unfold(&unf_fn/1)
    |> Enum.take(-1)
    |> List.first()
  end
end

IO.inspect Puzzle08.solve
