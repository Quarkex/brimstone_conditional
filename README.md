# Brimstone Conditional
  <!-- INTRODUCTION START -->
  Evaluate conditions defined in a logical structure.

  This module allows to evaluate complex tree conditional structures and digest
  them to get a final output. The main function is `evaluate/2` which will
  digest the struct and return the values with the conditional switches
  resolved.

  The struct itself can be converted to a string to be stored, using
  `:erlang.term_to_binary/1` and `Base.encode64/1` under the hood. The struct
  can be retrieved later using `from_string/1`, which performs the mirror
  operation. These strings include a version at the begining to acomodate the
  possibility of altering this struct in the future and allowing migrations
  from previous stringified conditionals.
  <!-- INTRODUCTION END -->
  <!-- USAGE START -->
  The struct uses recursion to evaluate its parameters. A
  plain boolean will return itself, a list will be assumed
  to be an `and` structure, and a map or keyword list will
  traverse itself as a list of key/value tuples, using the
  key as the operation and the value as parameters.

  Known map operators are the logic gates `and`, `or`, `xor`, `not`, `nor` and
  `xnor`, the comparison operators `eq`, `neq`, `gt`, `ge`, `lt` and `le`, the
  check operators `in` and `match`, the disambiguator `cond`, the scape hatch
  `fn`, and the utility operators `var`, `count`, `cat`, `each` and `sum`.

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
  provided (an empty map as default) to fetch data. All these tasks could be
  handled as functions, but they are so common that including them make the
  struct way more usable.

  `var` will perform a `Map.get/2` using the provided atom or string as key.

  `each` will turn itself into a list containing all values of the state map
  which had a key begining with the atom or string provided, followed with an
  index inside brackets (like the accessor syntax).

  `count` will return the size of the provided list.

  `sum` will asume the provided list contains numbers and will add them up.

  `cat` will try to catenate the elements of the provided argument list
  following a DWIM approach. To do so it will run a reduce function on the list
  and will take into account the data types of both the accumulator that is
  being built and the element we are trying to add. I.E: catenating two
  strings, two lists or two tuples together will simply join them, catenating a
  keyword list to a map will add the keywords to the map, but catenating a map
  to a list (keyword or not) will simply append the map as the last element of
  the list, and so on. If there is not a known approach to what we are trying
  to catenate, this operator will try to cast both elements to string before
  joining them.

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
  <!-- USAGE END -->

## Installation

It is [available in Hex](https://hexdocs.pm/brimstone_conditional), and the
package can be installed by adding `brimstone_conditional` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:brimstone_conditional, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/brimstone_conditional>.

