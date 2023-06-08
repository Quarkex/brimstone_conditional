defmodule BrimstoneConditional do
  @moduledoc """
  Evaluate conditions defined in a logical structure.

  This module allows to evaluate complex tree conditional structures and digest
  them to get a final output. The main function is `evaluate/2` which will digest
  the struct and return the values with the conditional switches resolved.

  The struct itself can be converted to a string to be stored, using
  `:erlang.term_to_binary/1` and `Base.encode64/1` under the hood. The struct
  can be retrieved later using `from_string/1`, which performs the mirror
  operation. These strings include a version at the begining to acomodate the
  possibility of altering this struct in the future and allowing migrations
  from previous stringified conditionals.
  """

  require Integer

  @module_name String.Chars.to_string(__MODULE__)

  @valid_condition_args ~w{
    and nand or xor not nor xnor
    eq neq gt ge lt le in match
    cond fn var count each sum
  }a

  defstruct Enum.map(@valid_condition_args, &{&1, nil})

  @doc """
  Evaluate conditions defined in a condition structure, returning the computed
  value.

  This uses recursion to evaluate its parameters. A plain boolean will return
  itself, a list will be assumed to be an `and` structure, and a map or keyword
  list will traverse itself as a list of key/value tuples, using the key as the
  operation and the value as parameters.

  Known map operators are the logic gates `and`, `or`, `xor`, `not`, `nor` and
  `xnor`, the comparison operators `eq`, `neq`, `gt`, `ge`, `lt` and `le`, the
  check operators `in` and `match`, the disambiguator `cond`, the scape hatch
  `fn`, and the utility operators `var`, `count`, `each` and `sum`.

  The comparison operators assume that the first element is the topic that we
  are comparing, and any other element is what are we comparing it to,
  therefore is possible to ask if something is greather that "this thing" and
  also to "that other thing" in the same step, or if "this thing" if different
  to "this other thing" and also to "that other thing".

  The check operator `match` will check if the string provided as the first
  element of the argument list matches all regex and strings provided as the
  rest of arguments. Strings will be compiled to regex, and other data types
  will try to convert themselves to a string, then surround themselves with the
  regex operators `^` and `$` and compile the resulting string to a regex, thus
  if you try to match "22" and "2" this will return true, as "2" is a string
  contained in "22", but if you try to match "22" and 2 it will return false,
  as the integer 2 will become the regex "^2$". This is intentional. If you
  require to pass aditional options to the regex you wish to compile, you may
  do so with a tuple of size two where each element correspond to the arguments
  of `Regex.compile!/2`.

  The check operator `in` will test membership of elements on the first element
  provided. It works on Lists, Strings and Maps. Maps are a special case, as it
  will check if the specified map arguments are a subset of the topic map.

  The disambiguator operator `cond` will operate exactly as an elixir `cond`.
  It expects to receive a list of tuples, where each tuple is a pair with a
  condition that will be evaluated with this very same function, and a value.
  It will substitute itself with the first element of this list that return
  `true` after checking its condition.

  The utility operators will perform common basic tasks, usually on the state
  provided (an empty map as default) to fetch data. `var` will perform a
  `Map.get/2` using the provided atom or string as key. `each` will turn itself
  into a list containing all values of the state map which had a key begining
  with the atom or string provided, followed with an index inside brackets
  (like the accessor syntax). `count` will return the size of the provided
  list, and `sum` will asume the provided list contains numbers and will add
  them up. All these tasks could be handled as functions, but they are so
  common that including them make the struct way more usable.

  Any other operator that receives a list as a parameter will be handled as an
  `and` operation of the result of applying the specfied operator to each
  element in the list, with the exception of the scape hatch `fn`, which will
  assume that the first element of the provided list is a function and will
  apply using the rest of the list as arguments. The `fn` operator also can
  acceps a different syntax using tuples, where you may specify `{module,
  function_name, arg_list}` or `{function, arg_list}`. In any case, it will
  check the arity of the relevant function. If the arity is equal to the
  arguments provided it will call it only with the provided arguments, and
  prepend the entire state to the argument list otherwise.
  """
  def evaluate(%__MODULE__{} = condition, %{} = state \\ %{}),
    do: digest(condition, state, false)

  defp is_met?(%__MODULE__{} = condition, state),
    do: Enum.all?(digest(condition, state), &is_met?(&1, state))

  defp is_met?({key, nil}, _state) when key in @valid_condition_args,
    do: true

  defp is_met?({key, value}, state) when is_bitstring(key),
    do: is_met?({String.to_existing_atom(key), value}, state)

  defp is_met?({:not, item}, state) when not is_list(item),
    do: !is_met?(item, state)

  defp is_met?({:and, list}, state) when is_list(list),
    do: Enum.all?(digest(list, state), &is_met?(&1, state))

  defp is_met?({:nand, list}, state) when is_list(list),
    do: !Enum.all?(digest(list, state), &is_met?(&1, state))

  defp is_met?({:or, list}, state) when is_list(list),
    do: Enum.any?(digest(list, state), &is_met?(&1, state))

  defp is_met?({:nor, list}, state) when is_list(list),
    do: !Enum.any?(digest(list, state), &is_met?(&1, state))

  defp is_met?({:xor, list}, state) when is_list(list),
    do: Enum.reduce(digest(list, state), false, &if(is_met?(&1, state), do: !&2, else: &2))

  defp is_met?({:xnor, list}, state) when is_list(list) do
    list
    |> digest(state)
    |> Enum.map(&is_met?(&1, state))
    |> Enum.frequencies()
    |> Map.get(true, 0)
    |> Integer.is_even()
  end

  defp is_met?({key, list}, state) when (is_atom(key) or is_bitstring(key)) and is_list(list),
    do: Enum.all?(digest(list, state), &is_met?({key, &1}, state))

  defp is_met?(anything_else, _state),
    do: anything_else

  defp is_in?(content, container) when is_bitstring(container) and is_bitstring(content),
    do: String.contains?(container, content)

  defp is_in?(content, container) when is_map(container) and is_map(content),
    do: MapSet.subset?(MapSet.new(content), MapSet.new(container))

  defp is_in?(content, container) when is_list(container),
    do: Enum.member?(container, content)

  # Replace any `cond: [{conditions, value}, ...]` occurence with the first valid
  # option in maps and lists, recursively. Return any other value unchanged.
  defp apply_cond_switch({:cond, map}, state) when is_map(map) do
    map
    |> Map.to_list()
    |> apply_cond_switch(state)
    |> Map.new()
  end

  defp apply_cond_switch(list, state) when is_list(list),
    do: Enum.map(list, &apply_cond_switch(&1, state))

  defp apply_cond_switch({:cond, items}, state) when is_list(items) do
    Enum.find(items, {nil, nil}, &is_met?(elem(&1, 0), state))
    |> elem(1)
    |> apply_cond_switch(state)
  end

  defp apply_cond_switch({:cond, item}, state),
    do: apply_cond_switch({:cond, [item]}, state)

  defp apply_cond_switch({key, value}, state),
    do: {key, apply_cond_switch(value, state)}

  defp apply_cond_switch(value, _state),
    do: value

  defp digest(item, state, dont_recurse \\ false)

  defp digest(%__MODULE__{} = condition, state, false) do
    condition =
      condition
      |> Map.from_struct()
      |> Enum.reject(&is_nil(elem(&1, 1)))

    cond do
      Enum.count(condition) == 1 && is_tuple(List.first(condition)) &&
          elem(List.first(condition), 0) in @valid_condition_args ->
        {head, tail} = List.first(condition)
        digest({head, tail}, state)

      true ->
        digest(condition, state)
    end
  end

  defp digest(map, state, false) when is_map(map) do
    list =
      map
      |> Map.to_list()
      |> digest(state)

    if is_list(list) &&
         Enum.all?(list, &is_tuple/1) &&
         Enum.all?(list, &(tuple_size(&1) == 2)) &&
         Enum.all?(list, &(is_atom(elem(&1, 0)) || is_bitstring(elem(&1, 0)))),
       do: Map.new(list),
       else: list
  end

  defp digest({:match, [other | patterns]}, state, false) when not is_bitstring(other),
    do: digest({:match, ["#{other}" | patterns]}, state)

  defp digest({:match, [binary | patterns]}, state, false) when is_bitstring(binary) do
    Enum.reduce(
      digest(patterns, state),
      true,
      &if(
        &2 &&
          String.match?(
            binary,
            cond do
              match?(%Regex{}, &1) -> &1
              is_bitstring(&1) -> Regex.compile!(&1)
              is_tuple(&1) -> Regex.compile!(elem(&1, 0), elem(&1, 1))
              true -> Regex.compile!("^#{&1}$")
            end
          ),
        do: true,
        else: false
      )
    )
  end

  defp digest({:match, anything_else}, state, false),
    do: digest({:match, digest(anything_else, state)}, state)

  defp digest({:eq, list}, state, false) do
    list = digest(list, state)

    Enum.reduce_while(list, true, fn item, _ ->
      if(List.first(list) == item, do: {:cont, true}, else: {:halt, false})
    end)
  end

  defp digest({:neq, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &(digest(head, state) != &1))
  end

  defp digest({:gt, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &(digest(head, state) > &1))
  end

  defp digest({:ge, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &(digest(head, state) >= &1))
  end

  defp digest({:lt, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &(digest(head, state) < &1))
  end

  defp digest({:le, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &(digest(head, state) <= &1))
  end

  defp digest({:in, list}, state, false) do
    [head | tail] = digest(list, state)
    Enum.all?(digest(tail, state), &is_in?(digest(head, state), &1))
  end

  defp digest({key, nil}, state, false),
    do: {digest(key, state), nil}

  defp digest({:var, key}, state, false)
       when is_map(state) and (is_atom(key) or is_bitstring(key)),
       do: Map.get(state, digest(key, state))

  defp digest({:count, variables}, state, false),
    do: Enum.count(digest(variables, state))

  defp digest({:each, key}, state, false)
       when is_map(state) and (is_atom(key) or is_bitstring(key)) do
    state
    |> Enum.filter(
      &String.match?("#{elem(&1, 0)}", Regex.compile!("#{digest(key, state)}\[[0-9]+\]$"))
    )
    |> Enum.map(&digest(elem(&1, 1), state))
  end

  defp digest({:sum, variables}, state, false),
    do: Enum.sum(Enum.map(digest(variables, state), &digest(&1, state)))

  defp digest({:fn, {module, name}}, state, false) when is_atom(module) and is_atom(name),
    do: digest({:fn, {module, name, []}}, state)

  defp digest({:fn, {module, name, args}}, state, false)
       when is_atom(module) and is_atom(name) and is_list(args) do
    arity = Enum.count(args)

    arity =
      if Code.ensure_loaded?(module) && function_exported?(module, name, arity + 1),
        do: arity + 1,
        else: arity

    digest({:fn, [Function.capture(module, name, arity)] ++ args}, state)
  end

  defp digest({:fn, function}, state, false) when is_function(function),
    do: digest({:fn, [function]}, state)

  defp digest({:fn, [function | args]}, state, false)
       when is_function(function) and is_list(args) do
    args = Enum.map(args, &digest(&1, state))

    if(:erlang.fun_info(function)[:arity] == Enum.count(args),
      do: apply(function, args),
      else: apply(function, [state] ++ args)
    )
  end

  defp digest({:cond, value}, state, false),
    do: apply_cond_switch({:cond, digest(value, state)}, state)

  defp digest({:not, item}, state, false),
    do: is_met?({:not, item}, state)

  defp digest({:and, list}, state, false),
    do: is_met?({:and, list}, state)

  defp digest({:nand, list}, state, false),
    do: is_met?({:nand, list}, state)

  defp digest({:or, list}, state, false),
    do: is_met?({:or, list}, state)

  defp digest({:nor, list}, state, false),
    do: is_met?({:nor, list}, state)

  defp digest({:xnor, list}, state, false),
    do: is_met?({:xnor, list}, state)

  defp digest({:xor, list}, state, false),
    do: is_met?({:xor, list}, state)

  defp digest({key, value}, state, false),
    do: {digest(key, state), digest(value, state)}

  defp digest(list, state, false) when is_list(list),
    do: digest(Enum.map(list, &digest(&1, state)), state, true)

  defp digest(anything_else, _state, _),
    do: anything_else

  @doc """
  Restore a conditional struct from its string form.
  """
  def from_string("module:#{@module_name};version:0.1.0;" <> data64),
    do: :erlang.binary_to_term(Base.decode64!(data64))

  defimpl String.Chars, for: __MODULE__ do
    @module_name String.replace("#{__MODULE__}", "Elixir.String.Chars", "Elixir")
    @current_struct_version "0.1.0"

    def to_string(instance),
      do:
        "module:#{@module_name};" <>
          "version:#{@current_struct_version};" <>
          Base.encode64(:erlang.term_to_binary(instance))
  end
end
