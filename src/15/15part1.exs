#!/usr/bin/env elixir
ExUnit.start()

defmodule Puzzle15 do
  @moduledoc """
  --- Day 15: Beverage Bandits ---

  Having perfected their hot chocolate, the Elves have a new problem: the Goblins that live in these caves will do
  anything to steal it. Looks like they're here for a fight.

  You scan the area, generating a map of the walls (#), open cavern (.), and starting position of every Goblin (G) and
  Elf (E) (your puzzle input).

  Combat proceeds in rounds; in each round, each unit that is still alive takes a turn, resolving all of its actions
  before the next unit's turn begins. On each unit's turn, it tries to move into range of an enemy (if it isn't already)
  and then attack (if it is in range).

  All units are very disciplined and always follow very strict combat rules. Units never move or attack diagonally, as
  doing so would be dishonorable. When multiple choices are equally valid, ties are broken in reading order:
  top-to-bottom, then left-to-right. For instance, the order in which units take their turns within a round is the
  reading order of their starting positions in that round, regardless of the type of unit or whether other units have
  moved after the round started. For example:

                       would take their
      These units:   turns in this order:
        #######           #######
        #.G.E.#           #.1.2.#
        #E.G.E#           #3.4.5#
        #.G.E.#           #.6.7.#
        #######           #######

  Each unit begins its turn by identifying all possible targets (enemy units). If no targets remain, combat ends.

  Then, the unit identifies all of the open squares (.) that are in range of each target; these are the squares which
  are adjacent (immediately up, down, left, or right) to any target and which aren't already occupied by a wall or
  another unit. Alternatively, the unit might already be in range of a target. If the unit is not already in range of a
  target, and there are no open squares which are in range of a target, the unit ends its turn.

  If the unit is already in range of a target, it does not move, but continues its turn with an attack. Otherwise, since
  it is not in range of a target, it moves.

  To move, the unit first considers the squares that are in range and determines which of those squares it could reach
  in the fewest steps. A step is a single movement to any adjacent (immediately up, down, left, or right) open (.)
  square. Units cannot move into walls or other units. The unit does this while considering the current positions of
  units and does not do any prediction about where units will be later. If the unit cannot reach (find an open path to)
  any of the squares that are in range, it ends its turn. If multiple squares are in range and tied for being reachable
  in the fewest steps, the square which is first in reading order is chosen. For example:

      Targets:      In range:     Reachable:    Nearest:      Chosen:
      #######       #######       #######       #######       #######
      #E..G.#       #E.?G?#       #E.@G.#       #E.!G.#       #E.+G.#
      #...#.#  -->  #.?.#?#  -->  #.@.#.#  -->  #.!.#.#  -->  #...#.#
      #.G.#G#       #?G?#G#       #@G@#G#       #!G.#G#       #.G.#G#
      #######       #######       #######       #######       #######

  In the above scenario, the Elf has three targets (the three Goblins):

  Each of the Goblins has open, adjacent squares which are in range (marked with a ? on the map).
  Of those squares, four are reachable (marked @); the other two (on the right) would require moving through a wall or
  unit to reach.
  Three of these reachable squares are nearest, requiring the fewest steps (only 2) to reach (marked !).
  Of those, the square which is first in reading order is chosen (+).
  The unit then takes a single step toward the chosen square along the shortest path to that square. If multiple steps
  would put the unit equally closer to its destination, the unit chooses the step which is first in reading order. (This
  requires knowing when there is more than one shortest path so that you can consider the first step of each such path.)
  For example:

      In range:     Nearest:      Chosen:       Distance:     Step:
      #######       #######       #######       #######       #######
      #.E...#       #.E...#       #.E...#       #4E212#       #..E..#
      #...?.#  -->  #...!.#  -->  #...+.#  -->  #32101#  -->  #.....#
      #..?G?#       #..!G.#       #...G.#       #432G2#       #...G.#
      #######       #######       #######       #######       #######

  The Elf sees three squares in range of a target (?), two of which are nearest (!), and so the first in reading order
  is chosen (+). Under "Distance", each open square is marked with its distance from the destination square; the two
  squares to which the Elf could move on this turn (down and to the right) are both equally good moves and would leave
  the Elf 2 steps from being in range of the Goblin. Because the step which is first in reading order is chosen, the Elf
  moves right one square.

  Here's a larger example of movement:

      Initially:
      #########
      #G..G..G#
      #.......#
      #.......#
      #G..E..G#
      #.......#
      #.......#
      #G..G..G#
      #########

      After 1 round:
      #########
      #.G...G.#
      #...G...#
      #...E..G#
      #.G.....#
      #.......#
      #G..G..G#
      #.......#
      #########

      After 2 rounds:
      #########
      #..G.G..#
      #...G...#
      #.G.E.G.#
      #.......#
      #G..G..G#
      #.......#
      #.......#
      #########

      After 3 rounds:
      #########
      #.......#
      #..GGG..#
      #..GEG..#
      #G..G...#
      #......G#
      #.......#
      #.......#
      #########

  Once the Goblins and Elf reach the positions above, they all are either in range of a target or cannot find any square
  in range of a target, and so none of the units can move until a unit dies.

  After moving (or if the unit began its turn in range of a target), the unit attacks.

  To attack, the unit first determines all of the targets that are in range of it by being immediately adjacent to it.
  If there are no such targets, the unit ends its turn. Otherwise, the adjacent target with the fewest hit points is
  selected; in a tie, the adjacent target with the fewest hit points which is first in reading order is selected.

  The unit deals damage equal to its attack power to the selected target, reducing its hit points by that amount. If
  this reduces its hit points to 0 or fewer, the selected target dies: its square becomes . and it takes no further
  turns.

  Each unit, either Goblin or Elf, has 3 attack power and starts with 200 hit points.

  For example, suppose the only Elf is about to attack:

             HP:            HP:
      G....  9       G....  9
      ..G..  4       ..G..  4
      ..EG.  2  -->  ..E..
      ..G..  2       ..G..  2
      ...G.  1       ...G.  1

  The "HP" column shows the hit points of the Goblin to the left in the corresponding row. The Elf is in range of three
  targets: the Goblin above it (with 4 hit points), the Goblin to its right (with 2 hit points), and the Goblin below it
  (also with 2 hit points). Because three targets are in range, the ones with the lowest hit points are selected: the
  two Goblins with 2 hit points each (one to the right of the Elf and one below the Elf). Of those, the Goblin first in
  reading order (the one to the right of the Elf) is selected. The selected Goblin's hit points (2) are reduced by the
  Elf's attack power (3), reducing its hit points to -1, killing it.

  After attacking, the unit's turn ends. Regardless of how the unit's turn ends, the next unit in the round takes its
  turn. If all units have taken turns in this round, the round ends, and a new round begins.

  The Elves look quite outnumbered. You need to determine the outcome of the battle: the number of full rounds that were
  completed (not counting the round in which combat ends) multiplied by the sum of the hit points of all remaining units
  at the moment combat ends. (Combat only ends when a unit finds no targets during its turn.)

  Below is an entire sample combat. Next to each map, each row's units' hit points are listed from left to right.

      Initially:
      #######
      #.G...#   G(200)
      #...EG#   E(200), G(200)
      #.#.#G#   G(200)
      #..G#E#   G(200), E(200)
      #.....#
      #######

      After 1 round:
      #######
      #..G..#   G(200)
      #...EG#   E(197), G(197)
      #.#G#G#   G(200), G(197)
      #...#E#   E(197)
      #.....#
      #######

      After 2 rounds:
      #######
      #...G.#   G(200)
      #..GEG#   G(200), E(188), G(194)
      #.#.#G#   G(194)
      #...#E#   E(194)
      #.....#
      #######

  Combat ensues; eventually, the top Elf dies:

      After 23 rounds:
      #######
      #...G.#   G(200)
      #..G.G#   G(200), G(131)
      #.#.#G#   G(131)
      #...#E#   E(131)
      #.....#
      #######

      After 24 rounds:
      #######
      #..G..#   G(200)
      #...G.#   G(131)
      #.#G#G#   G(200), G(128)
      #...#E#   E(128)
      #.....#
      #######

      After 25 rounds:
      #######
      #.G...#   G(200)
      #..G..#   G(131)
      #.#.#G#   G(125)
      #..G#E#   G(200), E(125)
      #.....#
      #######

      After 26 rounds:
      #######
      #G....#   G(200)
      #.G...#   G(131)
      #.#.#G#   G(122)
      #...#E#   E(122)
      #..G..#   G(200)
      #######

      After 27 rounds:
      #######
      #G....#   G(200)
      #.G...#   G(131)
      #.#.#G#   G(119)
      #...#E#   E(119)
      #...G.#   G(200)
      #######

      After 28 rounds:
      #######
      #G....#   G(200)
      #.G...#   G(131)
      #.#.#G#   G(116)
      #...#E#   E(113)
      #....G#   G(200)
      #######

  More combat ensues; eventually, the bottom Elf dies:

      After 47 rounds:
      #######
      #G....#   G(200)
      #.G...#   G(131)
      #.#.#G#   G(59)
      #...#.#
      #....G#   G(200)
      #######

  Before the 48th round can finish, the top-left Goblin finds that there are no targets remaining, and so combat ends.
  So, the number of full rounds that were completed is 47, and the sum of the hit points of all remaining units is
  200+131+59+200 = 590. From these, the outcome of the battle is 47 * 590 = 27730.

  Here are a few example summarized combats:

      #######       #######
      #G..#E#       #...#E#   E(200)
      #E#E.E#       #E#...#   E(197)
      #G.##.#  -->  #.E##.#   E(185)
      #...#E#       #E..#E#   E(200), E(200)
      #...E.#       #.....#
      #######       #######

      Combat ends after 37 full rounds
      Elves win with 982 total hit points left
      Outcome: 37 * 982 = 36334


      #######       #######
      #E..EG#       #.E.E.#   E(164), E(197)
      #.#G.E#       #.#E..#   E(200)
      #E.##E#  -->  #E.##.#   E(98)
      #G..#.#       #.E.#.#   E(200)
      #..E#.#       #...#.#
      #######       #######

      Combat ends after 46 full rounds
      Elves win with 859 total hit points left
      Outcome: 46 * 859 = 39514


      #######       #######
      #E.G#.#       #G.G#.#   G(200), G(98)
      #.#G..#       #.#G..#   G(200)
      #G.#.G#  -->  #..#..#
      #G..#.#       #...#G#   G(95)
      #...E.#       #...G.#   G(200)
      #######       #######

      Combat ends after 35 full rounds
      Goblins win with 793 total hit points left
      Outcome: 35 * 793 = 27755


      #######       #######
      #.E...#       #.....#
      #.#..G#       #.#G..#   G(200)
      #.###.#  -->  #.###.#
      #E#G#G#       #.#.#.#
      #...#G#       #G.G#G#   G(98), G(38), G(200)
      #######       #######

      Combat ends after 54 full rounds
      Goblins win with 536 total hit points left
      Outcome: 54 * 536 = 28944


      #########       #########
      #G......#       #.G.....#   G(137)
      #.E.#...#       #G.G#...#   G(200), G(200)
      #..##..G#       #.G##...#   G(200)
      #...##..#  -->  #...##..#
      #...#...#       #.G.#...#   G(200)
      #.G...G.#       #.......#
      #.....G.#       #.......#
      #########       #########

      Combat ends after 20 full rounds
      Goblins win with 937 total hit points left
      Outcome: 20 * 937 = 18740

  What is the outcome of the combat described in your puzzle input?
  """
  use ExUnit.Case, async: true

  @hitpoints 200
  @attack_power 3

  defp parse_row(partial_map, row_num, input_row) do
    input_row
    |> String.graphemes()
    |> Enum.zip(0..String.length(input_row))
    |> Enum.map(fn {spot, col_num} -> {spot, {col_num, row_num}} end)
    |> Enum.reduce(partial_map, fn
      {"#", index}, acc -> Map.put(acc, index, {"#", 0})
      {".", index}, acc -> Map.put(acc, index, {".", 0})
      {spot, index}, acc -> Map.put(acc, index, {spot, @hitpoints})
    end)
  end

  defp parse_map(input_row, {partial_map, row_num}), do: {parse_row(partial_map, row_num, input_row), row_num+1}

  defp get_goblins(game_state), do: :maps.filter(fn _coords, {type, _l} -> type == "G" end, game_state)

  defp get_elves(game_state), do: :maps.filter(fn _coords, {type, _l} -> type == "E" end, game_state)

  defp get_units(game_state), do: :maps.filter(fn _coords, {type, _l} -> type == "G" or type == "E" end, game_state)

  defp get_adversaries(game_state, {"G", _life}), do: get_elves(game_state)
  defp get_adversaries(game_state, {"E", _life}), do: get_goblins(game_state)

  defp adjacent_coords({col_num, row_num}) do
    [
      {col_num+1, row_num},
      {col_num-1, row_num},
      {col_num,   row_num+1},
      {col_num,   row_num-1},
    ]
  end

  defp adjacent_squares(coords, game_state) do
    adjacent_coords(coords)
    |> Enum.map(fn coords -> {coords, Map.get(game_state, coords)} end)
  end

  defp open_adjacent_squares(coords, game_state) do
    adjacent_squares(coords, game_state)
    |> Enum.filter(fn {_coords, {type, _life}} -> type == "." end)
  end

  defp open_adjacent_coords(coords, game_state) do
    open_adjacent_squares(coords, game_state)
    |> Enum.map(fn {coords, _unit} -> coords end)
  end

  defp read_cave_map_file(filename) do
    {:ok, file_content} = File.read(filename)

    file_content
    |> String.split("\n")
    |> Enum.reduce({%{}, 0}, &parse_map/2)
    |> (fn {map, _row_count} -> map end).()
  end

  defp fill_iterate({game_state, round, fill}) do
    {
      game_state,
      round+1,
      fill
      |> Enum.map(fn {c,r} -> {c,r,open_adjacent_coords(c, game_state)} end)
      |> Enum.reduce({%{}, %{}}, fn {c,r,l}, {fil, new} ->
        {
          Map.put(fil, c, r),
          Enum.reduce(l, new, fn coords, acc -> Map.put(acc, coords, round+1) end)
        } end)
      |> (fn {fil, new} -> {fil, Enum.filter(new, fn {coords, _r} -> !Map.has_key?(fil, coords) end)} end).()
      |> (fn {fil, new} -> Enum.reduce(new, fil, fn {k,v}, acc -> Map.put(acc, k, v) end) end).()
    }
  end

  defp reachable_coords(coords, game_state) do
    {game_state, 0, %{coords => 0}}
    |> Stream.iterate(&fill_iterate/1)
    |> Stream.drop_while(fn {_gs, round, fill} -> Enum.member?(Map.values(fill), round) end)
    |> Enum.take(1)
    |> List.first()
    |> (fn {_gs, _r, fill} -> fill end).()
  end

  defp besides_target(unit_coord, game_state) do
    adjacent_values =
      adjacent_squares(unit_coord, game_state)
      |> Enum.map(fn {_coords, {type, _life}} -> type end)

    case Map.get(game_state, unit_coord) do
      {"G", _life} -> Enum.member?(adjacent_values, "E")
      {"E", _life} -> Enum.member?(adjacent_values, "G")
      _ -> nil
    end
  end

  defp get_target(unit_coord, game_state) do
    reach = reachable_coords(unit_coord, game_state)

    range =
      game_state
      |> get_adversaries(Map.get(game_state, unit_coord))
      |> Enum.map(fn {c,_} -> c end)
      |> Enum.map(fn c -> open_adjacent_coords(c, game_state) end)
      |> Enum.reduce(&Kernel.++/2)

    :maps.filter(fn coords, _dist -> Enum.member?(range, coords) end, reach)
    |> get_smallest_value()
  end

  defp get_step(unit_coord, game_state) do
    if besides_target(unit_coord, game_state) do
      unit_coord
    else
      get_step_direction(unit_coord, game_state)
    end
  end

  defp get_step_direction_to_target(unit_coord, game_state, target) do
    reach = reachable_coords(target, game_state)

    range = open_adjacent_coords(unit_coord, game_state)

    :maps.filter(fn coords, _dist -> Enum.member?(range, coords) end, reach)
    |> get_smallest_value()
  end

  defp get_step_direction(unit_coord, game_state) do
    target = get_target(unit_coord, game_state)

    case target do
      nil -> unit_coord
      _ -> get_step_direction_to_target(unit_coord, game_state, target)
    end
  end

  defp get_smallest_value(map) when map_size(map) == 0, do: nil

  defp get_smallest_value(map) do
    map
    |> Enum.group_by(fn {_,v} -> v end)
    |> Enum.min(fn {k,_} -> k end)
    |> (fn {_, l} -> l end).()
    |> Enum.map(fn {k,_} -> k end)
    |> Enum.sort_by(&sort_coords_fn/1)
    |> List.first()
  end

  defp sort_coords_fn({x, y}), do: 100_000*y + x

  defp simulate_round(game_state) do
    game_state
    |> walk_units()
    |> attack_units()
  end

  defp attack_units(game_state) do
    game_state
    |> get_units()
    |> Enum.sort_by(fn {c,_u} -> sort_coords_fn(c) end)
    |> Enum.reduce(game_state, &attack_units/2)
  end

  defp attack_units({coords, unit}, game_state_acc) do
    if besides_target(coords, game_state_acc) do
      deal_damage({coords, unit}, game_state_acc)
    else
      game_state_acc
    end
  end

  def adversary("G"), do: "E"
  def adversary("E"), do: "G"

  def deal_damage({coords, {my_type, _life}}, game_state_acc) do
    if match?({".", _}, Map.get(game_state_acc, coords)) do
      game_state_acc
    else
      {target_coords, {target_type, target_life}} =
        adjacent_squares(coords, game_state_acc)
        |> Enum.filter(fn {_coords, {type, _life}} -> type == adversary(my_type) end)
        |> Enum.group_by(fn {_coords, {_type, life}} -> life end)
        |> Enum.sort_by(fn {k,_} -> k end)
        |> List.first()
        |> (fn {_, unit_list} -> unit_list end).()
        |> Enum.sort_by(fn {c,_u} -> sort_coords_fn(c) end)
        |> List.first()

      if target_life > @attack_power do
        Map.put(game_state_acc, target_coords, {target_type, target_life - @attack_power})
      else
        Map.put(game_state_acc, target_coords, {".", 0})  # TODO: remove from attackers
      end
    end
  end

  defp walk_units(game_state) do
    game_state
    |> get_units()
    |> Enum.sort_by(fn {c,_u} -> sort_coords_fn(c) end)
    |> Enum.reduce(game_state, &walk_units/2)
  end

  defp walk_units({coords, unit}, game_state_acc) do
    Map.put(Map.put(game_state_acc, coords, {".", 0}), get_step(coords, game_state_acc), unit)
  end

  defp print_game_state(game_state) do
    game_state
    |> Enum.group_by(fn {{_x,y},_u} -> y end)
    |> Enum.sort_by(fn {k,_} -> k end)
    |> Enum.map(fn {_,v} -> v end)
    |> Enum.map(fn x -> Enum.sort_by(x, fn {k,_} -> k end) end)
    |> Enum.map(fn x -> Enum.reduce(x, {"", []}, fn
      {_c, {type,life}}, {string, lifes} -> {string <> type, lifes ++ [life]}
    end) end)
    |> Enum.map(fn {row, lifes} -> {row, Enum.filter(lifes, &(&1>0))} end)
    |> Enum.map(fn {row, lifes} -> {row, Enum.map(lifes, &Integer.to_string/1)} end)
    |> Enum.map(fn {row, lifes} -> Enum.join([row, Enum.join(lifes, ",")], " ")end)
    |> Enum.each(&IO.puts/1)

    game_state
  end

  def has_both_types({game_state, _index}) do
    game_state
    |> Enum.group_by(fn {_coords, {type, _life}} -> type end)
    |> Enum.count()
    |> Kernel.>(3)
  end

  def solve do
    assert 27730 = solve(read_cave_map_file("test_input_27730.txt"))
    assert 36334 = solve(read_cave_map_file("test_input_36334.txt"))
    assert 39514 = solve(read_cave_map_file("test_input_39514.txt"))

    solve(read_cave_map_file("input15.txt"))
  end

  def solve(game_state) do
    {final_game_state, round_count} =
      game_state
      |> Stream.iterate(&simulate_round/1)
      |> Stream.with_index()
      |> Stream.drop_while(&has_both_types/1)
      |> Enum.take(1)
      |> List.first()

    life_sum = Enum.reduce(final_game_state, 0, fn {_coords, {_type, life}}, acc -> acc + life end)

    print_game_state(final_game_state)
    IO.puts("#{round_count} * #{life_sum} = #{round_count*life_sum}")
    IO.puts("")

    round_count * life_sum
  end
end

IO.inspect Puzzle15.solve
