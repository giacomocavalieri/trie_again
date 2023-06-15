# trie_again

[![Package Version](https://img.shields.io/hexpm/v/trie_again)](https://hex.pm/packages/trie_again)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/trie_again/)
![CI](https://github.com/giacomocavalieri/trie_again/workflows/CI/badge.svg?branch=main)

Tries in Gleam 🌳

> ⚙️ This package supports the Erlang and Javascript targets!

A [trie](https://en.wikipedia.org/wiki/Trie), also known as prefix tree, is a data structure that stores values associated with a key that is made of a list of elements.

By taking advantage of the structure of the keys, a trie can allow to efficiently perform operations like looking for elements whose keys share a common prefix.

## Installation

To add this package to your Gleam project:

```sh
gleam add trie_again
```

## Usage

Import the `trie` module and write some code! You can find many examples of how the different functions work in the [project documentation](https://hexdocs.pm/trie_again/).

```gleam
import trie

trie.new()
|> trie.insert(at: ["c", "a", "r"], value: 1)
|> trie.insert(at: ["c", "a", "t"], value: 10)
|> trie.get(at: ["c", "a", "t"])
// -> Ok(10)
```

## Contributing

If you think there's any way to improve this package, or if you spot a bug don't be afraid to open PRs, issues or requests of any kind! Any contribution is welcome 💜
