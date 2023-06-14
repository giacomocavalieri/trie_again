import gleam/option.{None, Option, Some}
import gleam/map.{Map}
import gleam/result
import gleam/list

/// A `Trie(k, v)` is a data structure that allows to store values of type `v` indexed by lists
/// of values of type `k`.
/// 
pub opaque type Trie(k, v) {
  Trie(entry: Option(v), children_map: Map(k, Trie(k, v)))
}

/// Creates a new empty trie.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new() |> size
/// 0
/// ```
/// 
pub fn new() -> Trie(k, v) {
  Trie(None, map.new())
}

/// Creates a new trie from a list of pairs path-value.
/// 
/// ## Examples
/// 
/// ```gleam
/// > from_list([#([1, 2], "foo"), #([1, 3], "bar")]) |> values
/// ["foo", "bar"]
/// ```
///
pub fn from_list(list: List(#(List(k), v))) -> Trie(k, v) {
  list.fold(
    over: list,
    from: new(),
    with: fn(trie, pair) { insert(trie, pair.0, pair.1) },
  )
}

/// Determines wether or not the trie is empty.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new() |> is_empty
/// True
/// ```
/// 
/// ```gleam
/// > new() |> insert([1], "foo") |> is_empty
/// False
/// ```
/// 
pub fn is_empty(trie: Trie(k, v)) -> Bool {
  size(trie) == 0
}

/// Gets the number of elements in the trie.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new() |> insert([1, 2], "foo") |> insert([2], "bar") |> size
/// 2
/// ```
/// 
pub fn size(trie: Trie(k, v)) -> Int {
  fold(trie, from: 0, with: fn(acc, _, _) { acc + 1 })
}

/// Gets a list of all the values in a given trie.
/// 
/// Tries are not ordered so the values are not returned in any specific order.
/// Do not write code that relies on the order values are returned by this function
/// as it may change in later versions of the library.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new() |> insert(at: [1, 2], value: "foo") |> insert(at: [1], value: "bar")
/// ["foo", "bar"]
/// ```
/// 
/// ```gleam
/// > new() |> values
/// []
/// ```
/// 
pub fn values(trie: Trie(k, v)) -> List(v) {
  fold(trie, from: [], with: fn(values, _, value) { [value, ..values] })
}

/// Fetches a value from a trie for a given path.
/// If a value is present at the given path it returns it wrapped in an `Ok`,
/// otherwise it returns `Error(Nil)`.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new() |> get(at: [1, 2])
/// Result(Nil)
/// ```
/// 
/// ```gleam
/// > new() |> insert(at: [1, 2], value: "foo") |> get(at: [1, 2])
/// Ok("foo")
/// ```
/// 
pub fn get(from: Trie(k, v), at path: List(k)) -> Result(v, Nil) {
  case path, from {
    [], Trie(None, _) -> Error(Nil)
    [], Trie(Some(value), _) -> Ok(value)
    [first, ..rest], Trie(_, children_map) ->
      children_map
      |> map.get(first)
      |> result.then(get(_, rest))
  }
}

/// Inserts a value in a trie at a given path. If there already is a value
/// at the given path it is replaced by the new one.
/// 
/// ## Examples
/// 
/// ```gleam
/// > new()
/// > |> insert(at: [1, 2], value: "foo")
/// > |> insert(at: [1], value: "bar")
/// > |> values
/// ["foo", "bar"]
/// ```
/// 
/// ```gleam
/// > new()
/// > |> insert(at: [1, 2], value: "foo")
/// > |> insert(at: [1, 2], value: "bar")
/// > |> values
/// ["bar"]
/// ```
/// 
pub fn insert(
  into trie: Trie(k, v),
  at path: List(k),
  value value: v,
) -> Trie(k, v) {
  case path, trie {
    [], Trie(_, children_map) -> Trie(Some(value), children_map)
    [first, ..rest], Trie(entry, children_map) -> {
      map.get(children_map, first)
      |> result.unwrap(new())
      |> insert(rest, value)
      |> map.insert(children_map, first, _)
      |> Trie(entry, _)
    }
  }
}

/// Combines all the trie's values into a single one by calling a given function on each one.
/// 
/// The function takes as input the accumulator, the path of a value and the corresponding value.
/// 
/// ## Examples
/// 
/// ```gleam
/// > from_list([#(["b", "a"], 1), #(["b", "c"], 10)])
/// > |> fold(from: 0, with: fn(sum, _, value) { sum + value })
/// 11
/// ```
/// 
pub fn fold(
  over trie: Trie(k, a),
  from initial: b,
  with fun: fn(b, List(k), a) -> b,
) -> b {
  map.fold(
    over: trie.children_map,
    from: trie.entry
    |> option.map(fun(initial, [], _))
    |> option.unwrap(initial),
    with: fn(acc, first, trie) {
      fold(
        over: trie,
        from: acc,
        with: fn(acc, rest, value) { fun(acc, [first, ..rest], value) },
      )
    },
  )
}
