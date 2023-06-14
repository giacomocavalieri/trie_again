import gleeunit/should
import trie
import gleam/pair
import gleam/list
import gleam/map.{Map}
import gleam/function
import gleam/option.{None, Some}
import gleam/int
import gleam/string

const test_list = [#([1, 2], "a"), #([1], "b"), #([], "c"), #([3, 4, 5], "d")]

fn count(list: List(a)) -> Map(a, Int) {
  list
  |> list.group(by: function.identity)
  |> map.map_values(fn(_, copies) { list.length(copies) })
}

fn same_elements(list: List(a), of other: List(a)) -> Nil {
  list
  |> count
  |> should.equal(count(other))
}

// TODO: Property based testing would be great for this kind of functions!

pub fn delete_test() {
  trie.new()
  |> trie.delete([])
  |> should.equal(trie.new())

  trie.new()
  |> trie.delete([1, 2])
  |> should.equal(trie.new())

  test_list
  |> trie.from_list
  |> trie.delete([])
  |> trie.delete([1, 2])
  |> trie.delete([3, 4, 5])
  |> should.equal(trie.singleton([1], "b"))
}

pub fn fold_test() {
  let fun = fn(p: #(List(Int), String)) -> Int {
    list.fold(p.0, 0, int.multiply) + string.length(p.1)
  }

  test_list
  |> trie.from_list
  |> trie.fold(
    from: 0,
    with: fn(acc, path, value) { acc + fun(#(path, value)) },
  )
  |> should.equal(
    test_list
    |> list.map(fun)
    |> list.fold(from: 0, with: int.add),
  )
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
  trie.new()
  |> trie.get(at: [])
  |> should.equal(Error(Nil))

  trie.new()
  |> trie.get(at: [1, 2, 3])
  |> should.equal(Error(Nil))

  use #(path, value) <- list.each(test_list)
  test_list
  |> trie.from_list
  |> trie.get(at: path)
  |> should.equal(Ok(value))
}

pub fn has_path_test() {
  trie.new()
  |> trie.has_path([])
  |> should.equal(False)

  trie.new()
  |> trie.has_path([1, 2])
  |> should.equal(False)

  test_list
  |> trie.from_list
  |> trie.has_path([3, 4])
  |> should.equal(False)

  use #(path, _) <- list.each(test_list)
  test_list
  |> trie.from_list
  |> trie.has_path(path)
  |> should.equal(True)
}

pub fn insert_test() {
  trie.new()
  |> trie.insert(at: [], value: "c")
  |> trie.insert(at: [1], value: "z")
  |> trie.insert(at: [3, 4, 5], value: "d")
  |> trie.insert(at: [1, 2], value: "a")
  |> trie.insert(at: [1], value: "b")
  |> should.equal(trie.from_list(test_list))
}

pub fn is_empty_test() {
  trie.new()
  |> trie.is_empty
  |> should.equal(True)

  trie.singleton([1, 2], "a")
  |> trie.is_empty
  |> should.equal(False)

  test_list
  |> trie.from_list
  |> trie.is_empty
  |> should.equal(False)
}

pub fn map_test() {
  test_list
  |> trie.from_list
  |> trie.map(fn(_) { "!" })
  |> should.equal(
    test_list
    |> list.map(pair.map_second(_, fn(_) { "!" }))
    |> trie.from_list,
  )
}

pub fn new_test() {
  trie.new()
  |> trie.to_list
  |> should.equal([])
}

pub fn paths_test() {
  trie.new()
  |> trie.paths
  |> should.equal([])

  test_list
  |> trie.from_list
  |> trie.paths
  |> same_elements(of: list.map(test_list, pair.first))
}

pub fn singleton_test() {
  trie.singleton([1, 2], "a")
  |> trie.to_list
  |> should.equal([#([1, 2], "a")])
}

pub fn size_test() {
  trie.new()
  |> trie.size
  |> should.equal(0)

  trie.singleton([1, 2], "a")
  |> trie.size
  |> should.equal(1)

  test_list
  |> trie.from_list
  |> trie.size
  |> should.equal(list.length(test_list))
}

pub fn update_test() {
  trie.singleton([1, 2], "a")
  |> trie.update(at: [1, 2], with: fn(n) { option.map(n, fn(_) { "b" }) })
  |> should.equal(trie.singleton([1, 2], "b"))

  trie.singleton([1, 2], "a")
  |> trie.update(at: [1, 2], with: fn(_) { None })
  |> should.equal(trie.new())

  trie.singleton([1, 2], "a")
  |> trie.update(at: [1], with: fn(_) { Some("b") })
  |> should.equal(trie.from_list([#([1, 2], "a"), #([1], "b")]))
}

pub fn values_test() {
  trie.new()
  |> trie.values
  |> should.equal([])

  test_list
  |> trie.from_list
  |> trie.values
  |> same_elements(of: list.map(test_list, pair.second))
}
