import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/string
import trie

const test_list = [#([1, 2], "a"), #([1], "b"), #([], "c"), #([3, 4, 5], "d")]

fn count(list: List(a)) -> Dict(a, Int) {
  list
  |> list.group(by: function.identity)
  |> dict.map_values(fn(_, copies) { list.length(copies) })
}

fn same_elements(list: List(a), of other: List(a)) -> Nil {
  assert count(list) == count(other)
}

// TODO: Property based testing would be great for this kind of functions!

pub fn delete_test() {
  assert trie.new() == trie.delete(trie.new(), [])
  assert trie.new() == trie.delete(trie.new(), [1, 2])
  assert test_list
    |> trie.from_list
    |> trie.delete([])
    |> trie.delete([1, 2])
    |> trie.delete([3, 4, 5])
    == trie.singleton([1], "b")
}

pub fn fold_test() {
  let fun = fn(p: #(List(Int), String)) -> Int {
    list.fold(p.0, 0, int.multiply) + string.length(p.1)
  }

  assert test_list
    |> trie.from_list
    |> trie.fold(from: 0, with: fn(acc, path, value) {
      acc + fun(#(path, value))
    })
    == test_list
    |> list.map(fun)
    |> list.fold(from: 0, with: int.add)
}

pub fn from_list_test() {
  test_list
  |> trie.from_list
  |> trie.to_list
  |> same_elements(of: test_list)

  []
  |> trie.from_list
  |> trie.to_list
  |> same_elements(of: [])
}

pub fn get_test() {
  let assert Error(_) = trie.get(trie.new(), at: [])
  let assert Error(_) = trie.get(trie.new(), at: [1, 2, 3])

  use #(path, value) <- list.each(test_list)
  assert Ok(value)
    == test_list
    |> trie.from_list
    |> trie.get(at: path)
}

pub fn has_path_test() {
  assert False == trie.has_path(trie.new(), [])
  assert False == trie.has_path(trie.new(), [1, 2])
  assert False
    == test_list
    |> trie.from_list
    |> trie.has_path([3, 4])

  use #(path, _) <- list.each(test_list)
  assert True
    == test_list
    |> trie.from_list
    |> trie.has_path(path)
}

pub fn insert_test() {
  assert trie.new()
    |> trie.insert(at: [], value: "c")
    |> trie.insert(at: [1], value: "z")
    |> trie.insert(at: [3, 4, 5], value: "d")
    |> trie.insert(at: [1, 2], value: "a")
    |> trie.insert(at: [1], value: "b")
    == trie.from_list(test_list)
}

pub fn is_empty_test() {
  assert trie.is_empty(trie.new()) == True

  assert trie.is_empty(trie.singleton([1, 2], "a")) == False

  assert test_list
    |> trie.from_list
    |> trie.is_empty
    == False
}

pub fn map_test() {
  assert test_list
    |> trie.from_list
    |> trie.map(fn(_) { "!" })
    == test_list
    |> list.map(pair.map_second(_, fn(_) { "!" }))
    |> trie.from_list
}

pub fn new_test() {
  assert trie.to_list(trie.new()) == []
}

pub fn paths_test() {
  assert trie.paths(trie.new()) == []

  test_list
  |> trie.from_list
  |> trie.paths
  |> same_elements(of: list.map(test_list, pair.first))
}

pub fn singleton_test() {
  assert trie.to_list(trie.singleton([1, 2], "a")) == [#([1, 2], "a")]
}

pub fn size_test() {
  assert trie.size(trie.new()) == 0

  assert trie.size(trie.singleton([1, 2], "a")) == 1

  assert test_list
    |> trie.from_list
    |> trie.size
    == list.length(test_list)
}

// [#([1, 2], "a"), #([1], "b"), #([], "c"), #([3, 4, 5], "d")]
pub fn subtrie_test() {
  let assert Ok(value) = trie.subtrie(trie.new(), at: [])
  assert value == trie.new()

  let assert Error(_) = trie.subtrie(trie.new(), at: [1, 2])

  let assert Ok(value) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [])
  assert value == trie.from_list(test_list)

  let assert Ok(value) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [1, 2])
  assert value == trie.singleton([1, 2], "a")

  let assert Ok(value) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [1])
  assert value == trie.from_list([#([1, 2], "a"), #([1], "b")])

  let assert Ok(value) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [3, 4])
  assert value == trie.singleton([3, 4, 5], "d")

  let assert Error(_) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [1, 3])

  let assert Error(_) =
    test_list
    |> trie.from_list
    |> trie.subtrie(at: [1, 2, 3])
}

pub fn update_test() {
  assert trie.update(trie.singleton([1, 2], "a"), at: [1, 2], with: fn(n) {
      option.map(n, fn(_) { "b" })
    })
    == trie.singleton([1, 2], "b")

  assert trie.update(trie.singleton([1, 2], "a"), at: [1, 2], with: fn(_) {
      None
    })
    == trie.new()

  assert trie.update(trie.singleton([1, 2], "a"), at: [1], with: fn(_) {
      Some("b")
    })
    == trie.from_list([#([1, 2], "a"), #([1], "b")])
}

pub fn values_test() {
  assert trie.values(trie.new()) == []

  test_list
  |> trie.from_list
  |> trie.values
  |> same_elements(of: list.map(test_list, pair.second))
}
