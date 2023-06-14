import gleeunit/should
import trie
import gleam/set

pub fn new_test() {
  trie.new()
  |> trie.is_empty
  |> should.equal(True)

  trie.new()
  |> trie.size
  |> should.equal(0)

  trie.new()
  |> trie.values
  |> should.equal([])
}

// Property based testing would be great for this kind of functions!

pub fn insert_single_value_test() {
  let t = trie.insert(trie.new(), [1, 2, 3], "foo")

  t
  |> trie.size
  |> should.equal(1)

  t
  |> trie.values
  |> should.equal(["foo"])

  t
  |> trie.get([1, 2, 3])
  |> should.equal(Ok("foo"))
}

pub fn insert_multiple_values_with_no_matching_prefix_test() {
  let t =
    trie.new()
    |> trie.insert([1, 2, 3], "foo")
    |> trie.insert([4], "bar")
    |> trie.insert([7, 8], "baz")

  t
  |> trie.size
  |> should.equal(3)

  t
  |> trie.values
  |> set.from_list
  |> should.equal(set.from_list(["foo", "bar", "baz"]))

  t
  |> trie.get([1, 2, 3])
  |> should.equal(Ok("foo"))

  t
  |> trie.get([4])
  |> should.equal(Ok("bar"))

  t
  |> trie.get([7, 8])
  |> should.equal(Ok("baz"))
}

pub fn insert_multiple_values_with_common_prefixes_test() {
  let t =
    trie.new()
    |> trie.insert([1, 2, 3], "a")
    |> trie.insert([1], "b")
    |> trie.insert([1, 2], "c")
    |> trie.insert([3, 4, 5], "d")

  t
  |> trie.size
  |> should.equal(4)

  t
  |> trie.values
  |> set.from_list
  |> should.equal(set.from_list(["a", "b", "c", "d"]))

  t
  |> trie.get([1, 2, 3])
  |> should.equal(Ok("a"))

  t
  |> trie.get([1])
  |> should.equal(Ok("b"))

  t
  |> trie.get([1, 2])
  |> should.equal(Ok("c"))

  t
  |> trie.get([3, 4, 5])
  |> should.equal(Ok("d"))
}

pub fn insert_duplicate_values_test() {
  let t =
    trie.new()
    |> trie.insert([1, 2, 3], "a")
    |> trie.insert([1, 2, 3], "b")
    |> trie.insert([1, 2], "c")
    |> trie.insert([1, 2], "d")

  t
  |> trie.size
  |> should.equal(2)

  t
  |> trie.values
  |> set.from_list
  |> should.equal(set.from_list(["b", "d"]))

  t
  |> trie.get([1, 2, 3])
  |> should.equal(Ok("b"))

  t
  |> trie.get([1, 2])
  |> should.equal(Ok("d"))
}
