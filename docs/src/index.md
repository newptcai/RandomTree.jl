# Introduction

`RandomTree.jl` is a [Julia](https://julialang.org/) package for simulations on random trees, in particular Conditional
Galton-Watson trees. It can efficiently generate several types of random trees up to size 10^8,
including

* [Conditional Galton Watson](https://arxiv.org/abs/1112.0510) tree
    * Cayley
    * Binary
    * Catalan
    * DAry
    * Motzkin
* [Random Recursive Trees](https://en.wikipedia.org/wiki/Recursive_tree) (up to size 10^7)

as well as carry out these simulations

* [k-cut](https://arxiv.org/abs/1804.03069)
* sum of log(subtree sizes) over all fringe subtrees
* height
* total path length
* leaf number count

The package also provides a simply function for drawing trees.

You can use `RandomTree.jl` as a library in your code, in Julia REPL, or in a Jupyter notebook. It
can also run as a standalone script.

The generation of conditional Galton-Watson trees uses [a very efficient
algorithm](https://search.proquest.com/openview/8fe4ed7479bf9d0df48152a6b91e6191/1?cbl=666313&pq-origsite=gscholar)
introduced by [Luc Devroye](http://luc.devroye.org). Generating a Galton-Watson tree of 1 million
nodes takes about 20-30 ms.

