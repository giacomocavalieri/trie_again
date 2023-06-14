# trie_again

[![Package Version](https://img.shields.io/hexpm/v/prefix_tree)](https://hex.pm/packages/prefix_tree)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/prefix_tree/)
![CI](https://github.com/giacomocavalieri/trie_again/workflows/CI/badge.svg?branch=main)

Tries in Gleam 🌳

> ⚙️ This package supports the Erlang and Javascript targets!

## Installation

To add this package to your Gleam project:

```sh
gleam add trie_again
```

## Usage

Import the `trie` module and write some code! You can find many examples of how the different functions work in the [project documentation]().

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
