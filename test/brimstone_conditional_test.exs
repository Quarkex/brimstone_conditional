defmodule ConditionalTest do
  use ExUnit.Case
  doctest BrimstoneConditional

  alias BrimstoneConditional, as: Conditional

  @doc false
  def auxiliary_function_a(),
    do: :echo

  @doc false
  def auxiliary_function_b(:marco),
    do: :polo

  describe "Conditional" do
    test "to_string behaviour serializes correctly a conditional" do
      assert String.Chars.to_string(%Conditional{and: [true, true, true]}) ==
               "module:Elixir.BrimstoneConditional;version:0.1.0;g3QAAAAXZAAKX19zdHJ1Y3RfX2QAG0VsaXhpci5Ccmltc3RvbmVDb25kaXRpb25hbGQAA2FuZGwAAAADZAAEdHJ1ZWQABHRydWVkAAR0cnVlamQAA2NhdGQAA25pbGQABGNvbmRkAANuaWxkAAVjb3VudGQAA25pbGQABGVhY2hkAANuaWxkAAJlcWQAA25pbGQAAmZuZAADbmlsZAACZ2VkAANuaWxkAAJndGQAA25pbGQAAmluZAADbmlsZAACbGVkAANuaWxkAAJsdGQAA25pbGQABW1hdGNoZAADbmlsZAAEbmFuZGQAA25pbGQAA25lcWQAA25pbGQAA25vcmQAA25pbGQAA25vdGQAA25pbGQAAm9yZAADbmlsZAADc3VtZAADbmlsZAADdmFyZAADbmlsZAAEeG5vcmQAA25pbGQAA3hvcmQAA25pbA=="
    end

    test "from_string function deserializes correctly a conditional" do
      assert %Conditional{and: [true, true, true]} ==
               Conditional.from_string(
                 "module:Elixir.BrimstoneConditional;version:0.1.0;g3QAAAAXZAAKX19zdHJ1Y3RfX2QAG0VsaXhpci5Ccmltc3RvbmVDb25kaXRpb25hbGQAA2FuZGwAAAADZAAEdHJ1ZWQABHRydWVkAAR0cnVlamQAA2NhdGQAA25pbGQABGNvbmRkAANuaWxkAAVjb3VudGQAA25pbGQABGVhY2hkAANuaWxkAAJlcWQAA25pbGQAAmZuZAADbmlsZAACZ2VkAANuaWxkAAJndGQAA25pbGQAAmluZAADbmlsZAACbGVkAANuaWxkAAJsdGQAA25pbGQABW1hdGNoZAADbmlsZAAEbmFuZGQAA25pbGQAA25lcWQAA25pbGQAA25vcmQAA25pbGQAA25vdGQAA25pbGQAAm9yZAADbmlsZAADc3VtZAADbmlsZAADdmFyZAADbmlsZAAEeG5vcmQAA25pbGQAA3hvcmQAA25pbA=="
               )
    end

    test "and returns true when all conditions are true" do
      assert Conditional.evaluate(%Conditional{and: [true, true, true]}) == true
    end

    test "and returns false when any condition is false" do
      assert Conditional.evaluate(%Conditional{and: [true, false, true]}) == false
    end

    test "nand returns false when all conditions are true" do
      assert Conditional.evaluate(%Conditional{nand: [true, true, true]}) == false
    end

    test "nand returns true when any condition is false" do
      assert Conditional.evaluate(%Conditional{nand: [true, false, true]}) == true
    end

    test "or returns true when at least one condition is true" do
      assert Conditional.evaluate(%Conditional{or: [false, false, true]}) == true
    end

    test "or returns false when no condition is true" do
      assert Conditional.evaluate(%Conditional{or: [false, false, false]}) == false
    end

    test "xor returns true when one condition is true and the rest are false" do
      assert Conditional.evaluate(%Conditional{or: [false, true, false]}) == true
    end

    test "xor returns true when an odd number of conditions are true" do
      assert Conditional.evaluate(%Conditional{xor: [false, true, true, true]}) == true
    end

    test "not returns the negation of the condition" do
      assert Conditional.evaluate(%Conditional{not: [true]}) == false
    end

    test "nor returns true if all conditions are false" do
      assert Conditional.evaluate(%Conditional{nor: [false, false, false]}) == true
    end

    test "nor returns false if not all conditions are false" do
      assert Conditional.evaluate(%Conditional{nor: [true, false, false]}) == false
    end

    test "xnor returns true if the number of met conditions is even" do
      assert Conditional.evaluate(%Conditional{xnor: [true, false, true, false, false]}) == true
    end

    test "xnor returns false if the number of met conditions is odd" do
      assert Conditional.evaluate(%Conditional{xnor: [true, false, true, false, true]}) == false
    end

    test "eq returns true if the first condition is equal to all the others" do
      assert Conditional.evaluate(%Conditional{eq: [1, 1, 1, 1]}) == true
    end

    test "eq returns false if the first condition is not equal to all the others" do
      assert Conditional.evaluate(%Conditional{eq: [1, 1, 3, 1]}) == false
    end

    test "eq handles lists of booleans adequately" do
      assert Conditional.evaluate(%Conditional{eq: [false, false]}) == true
    end

    test "neq returns true if the first condition is not equal to all the others" do
      assert Conditional.evaluate(%Conditional{neq: [1, 2, 3, 4]}) == true
    end

    test "neq returns false if the first condition is not equal to all the others" do
      assert Conditional.evaluate(%Conditional{neq: [1, 2, 3, 1]}) == false
    end

    test "gt returns true if the first element is greater than all the others" do
      assert Conditional.evaluate(%Conditional{gt: [4, 3, 2, 1]}) == true
    end

    test "gt returns false if the first element is not greater than all the others" do
      assert Conditional.evaluate(%Conditional{gt: [1, 2, 1, 1]}) == false
    end

    test "ge returns true if the first element is greater than or equal to all the others" do
      assert Conditional.evaluate(%Conditional{ge: [4, 4, 3, 2]}) == true
    end

    test "ge returns false if the first element is not greater than or equal to all the others" do
      assert Conditional.evaluate(%Conditional{ge: [2, 2, 3, 1]}) == false
    end

    test "lt returns true if the first element is smaller than all the others" do
      assert Conditional.evaluate(%Conditional{lt: [1, 2, 3, 4]}) == true
    end

    test "lt returns false if the first element is not smaller than all the others" do
      assert Conditional.evaluate(%Conditional{lt: [1, 1, 2, 3]}) == false
    end

    test "le returns true if the first element is smaller than or equal to all the others" do
      assert Conditional.evaluate(%Conditional{le: [2, 2, 3, 4]}) == true
    end

    test "le returns false if the first element is not smaller than or equal to all the others" do
      assert Conditional.evaluate(%Conditional{le: [2, 2, 3, 1]}) == false
    end

    test "in returns true if the first element is member of all the other elements" do
      assert Conditional.evaluate(%Conditional{in: [:a, [:a, :b, :c], [:a, :z]]}) == true
    end

    test "in returns false if the first element is not member of all the other elements" do
      assert Conditional.evaluate(%Conditional{in: [:a, [:a, :b, :c], [:d, :e, :f]]}) == false
    end

    test "in returns true if the first element is a substring or member of all the other elements" do
      assert Conditional.evaluate(%Conditional{in: ["foo", "foobar", ["foo", "bar"]]}) == true
    end

    test "in returns false if the first element is not a substring or member of all the other elements" do
      assert Conditional.evaluate(%Conditional{in: ["foo", "foobar", ["bar", "baz"]]}) == false
    end

    test "in returns true if the first element is a subset or member of all the other elements" do
      assert Conditional.evaluate(%Conditional{
               in: [
                 %{foo: "bar"},
                 %{foo: "bar", a: "b"},
                 [%{foo: "bar"}, %{a: "b"}]
               ]
             }) == true
    end

    test "in returns false if the first element is not a subset or member of all the other elements" do
      assert Conditional.evaluate(%Conditional{
               in: [
                 %{foo: "bar"},
                 %{a: "b"},
                 [%{foo: "bar"}, %{a: "b"}]
               ]
             }) == false
    end

    test "match returns true if the first element match all regexes" do
      assert Conditional.evaluate(%Conditional{match: ["foo", ~r/^foo$/, ~r/^f/, ~r/o$/]}) == true
    end

    test "match returns false if the first element don't match all regexes" do
      assert Conditional.evaluate(%Conditional{match: ["foo", ~r/^foo$/, ~r/^o/]}) == false
    end

    test "match tries an exact match if using something that is not a tuple, bitstring or regex as the regex" do
      assert Conditional.evaluate(%Conditional{match: ["foo", :foo, ~r/^f/, ~r/o$/]}) == true
      assert Conditional.evaluate(%Conditional{match: ["foo", :oo, ~r/^f/, ~r/o$/]}) == false
    end

    test "match tries a lazy match if using a bitstring as the regex" do
      assert Conditional.evaluate(%Conditional{match: ["foo", "foo", ~r/^f/, ~r/o$/]}) == true
      assert Conditional.evaluate(%Conditional{match: ["foo", "oo", ~r/^f/, ~r/o$/]}) == true
      assert Conditional.evaluate(%Conditional{match: ["foo", "ooo", ~r/^f/, ~r/o$/]}) == false
    end

    test "match tries to build a regex to match if using a tuple as the regex" do
      assert Conditional.evaluate(%Conditional{match: ["FOO", {"foo", "i"}, ~r/^f/i]}) == true
      assert Conditional.evaluate(%Conditional{match: ["FOO", {"foo", ""}, ~r/^f/i]}) == false
    end

    test "cond returns the second element of the first tuple whose first element is true" do
      assert Conditional.evaluate(%Conditional{cond: [{false, :a}, {true, :b}]}) == :b
      assert Conditional.evaluate(%Conditional{cond: [{true, :a}, {true, :b}]}) == :a
    end

    test "cond handles maps correctrly" do
      assert Conditional.evaluate(%Conditional{
               cond: [
                 {false, {:cond, %{"option" => {:cond, [{false, 1}, {true, 2}]}}}},
                 {true, {:cond, %{"option" => {:cond, [{false, 3}, {true, 4}]}}}}
               ]
             }) == %{"option" => 4}
    end

    test "cond handle single items correctrly" do
      assert Conditional.evaluate(%Conditional{
               cond: %{"option" => {:cond, {true, 1}}}
             }) == %{"option" => 1}
    end

    test "fn executes the first element using the others as function parameters" do
      assert Conditional.evaluate(%Conditional{fn: [&(&1 == :a), :a]}) == true
    end

    test "fn passes the state as first parameter if arity doesn't match the number of arguments" do
      assert Conditional.evaluate(
               %Conditional{fn: [&(Map.get(&1, :foo) == :a)]},
               %{foo: :a}
             ) == true
    end

    test "fn calls by referencing module and function using a tuple" do
      assert Conditional.evaluate(%Conditional{fn: {__MODULE__, :auxiliary_function_a}}) == :echo
    end

    test "fn calls by referencing module, function and args using a tuple" do
      assert Conditional.evaluate(%Conditional{
               fn: {__MODULE__, :auxiliary_function_b, [:marco]}
             }) == :polo
    end

    test "fn calls by passing a function" do
      assert Conditional.evaluate(%Conditional{fn: fn -> true end}) == true
    end

    test "fn calls by passing a function with state as its first argument" do
      assert Conditional.evaluate(
               %Conditional{fn: fn state -> state[:foo] end},
               %{foo: "bar"}
             ) == "bar"
    end

    test "var returns the value of the key stored in the state map" do
      assert Conditional.evaluate(%Conditional{var: "foo"}, %{"foo" => "bar"}) == "bar"
    end

    test "var returns nil if the key is not stored in the state map" do
      assert Conditional.evaluate(%Conditional{var: "foo"}, %{"baz" => "bar"}) == nil
    end

    test "each returns the values of a key with multiple entries in a map" do
      assert Conditional.evaluate(
               %Conditional{each: "foo"},
               %{"foo[0]" => 0, "foo[1]" => 1, "foo[2]" => 2}
             ) == [0, 1, 2]
    end

    test "count returns the ammount of all elements in a list" do
      assert Conditional.evaluate(%Conditional{count: [:a, :b, :c]}) == 3
    end

    test "sum returns the sum of all elements in a list" do
      assert Conditional.evaluate(%Conditional{sum: [1, 2, 3]}) == 6
    end

    test "multiple nested operations and recursivity are supported" do
      conditional = %Conditional{
        eq: [
          1,
          1,
          {:fn, [fn -> 2 - 1 end]},
          {:cond, [{true, 1}, {true, 9}]},
          {:fn, [&String.to_integer/1, "1"]}
        ]
      }

      assert Conditional.evaluate(conditional) == true
    end

    test "evaluate handles state values correctly" do
      conditional = %Conditional{and: [true, {:eq, [42, {:fn, [&Map.get(&1, "var")]}]}]}
      state = %{"var" => 42}
      assert Conditional.evaluate(conditional, state) == true
    end

    test "evaluate handles nil values correctly" do
      assert Conditional.evaluate(%Conditional{and: [true, {:and, nil}]}) == true
    end

    test "evaluate handles string keys correctly" do
      assert Conditional.evaluate(%Conditional{and: [true, {"and", nil}]}) == true
    end
  end
end
