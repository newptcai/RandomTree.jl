# RandomTree.jl

[![Travis status](https://travis-ci.org/newptcai/RandomTree.jl.svg?branch=master)](https://travis-ci.org/newptcai/RandomTree.jl)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://newptcai.github.io/RandomTree.jl/latest/)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://newptcai.github.io/RandomTree.jl/stable/)

`RandomTree.jl` is a Julia package for simulations on random trees, in particular Conditional
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
can also run as a stand-alone script.

The generation of conditional Galton-Watson trees uses [a very efficient
algorithm](https://search.proquest.com/openview/8fe4ed7479bf9d0df48152a6b91e6191/1?cbl=666313&pq-origsite=gscholar)
introduced by [Luc Devroye](http://luc.devroye.org). Generating a Galton-Watson tree of 1 million
nodes takes about 20-30 ms.

## Installation

Start [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) and enter the package mode by pressing `]`. You should see the prompt
```julia
(v1.1) pkg>
```
Type
```julia
(v1.1) pkg> dev https://github.com/newptcai/RandomTree.jl
```
should add `RandomTree.jl` to your default Julia environment. Then you can just use it as any other
Julia package. You can also find the source code of the package at `~/.julia/dev/RandomTree`.

## Usage

### Use `RandomTree.jl` In interactive environment

In Julia REPL, load `RandomTree.jl` by
```julia
julia> using RandomTree
```
To get the degree sequence of a (random) Cayley tree of size 5 in depth-search-first order, type
```julia
julia> tree = CayleyTree(5)
Cayley Tree of size 5

julia> degrees(tree)
5-element Array{Int32,1}:
 3
 1
 0
 0
 0
```
Note that since we are simulating a random tree, each time `degrees(tree)` is called, a random
degree sequence is returned.

Simulations on random trees usually need to compute a property of trees from its degree sequence.
Several such simulations has been implemented in `src/simulator.jl`. For example,
to generate 1000 Cayley Trees and calculate their height, type
```
julia> sim = HeightSimulator(tree)
height simulation of Cayley Tree of size 5

julia> sim_result = simulation(sim, 1000)
1000-element Array{Any,1}:
 4
 3
 ⋮
 5
 4
 4
```

See [`example.ipynb`](https://nbviewer.jupyter.org/github/newptcai/RandomTree.jl/blob/master/notebook/demonstration.ipynb) in the notebook directory for more demonstrations.

### Use `RandomTree.jl` as a script

In a terminal, change directory to the `~/.julia/dev/RandomTree/src` and run the command
```
julia simtree.jl -l 5 -n 10000 -t Cayley height
```
will generate 10000 Cayley trees of size 10^5 and print out their heights.
Run
```
julia simtree.jl --help
```
to see the other options.

The simulations can made parallel. For example
```
julia -p 4 simtree.jl -l 5 -n 10000 -t Cayley height
```
will start 4 local processes on your local machine to run the simulation.
You can also run simulations across several nodes of a cluster by using
```
julia --machine-file machines.txt simtree.jl -l 5 -n 10000 -t Cayley height
```
where `machines.txt` contains the information for finding remote nodes.
See Julia's [documentats](https://docs.julialang.org/en/v1/manual/getting-started/) for details.

## Future plan

Several random trees will be added in the future
* [ ] binary search trees
* [ ] split trees in general
* [ ] preferential attachment
