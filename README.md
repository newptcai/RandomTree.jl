# RandomTree.jl

A Julia package for random trees and related simulations. It currently supports generating the
following types of random trees

* [Conditional Galton Watson](https://arxiv.org/abs/1112.0510) tree, including
    * Cayley Tree
    * Binary Tree
    * Catalan Tree
    * DAry Tree
    * Motzkin Tree
* [Random Recursive Tree](https://en.wikipedia.org/wiki/Recursive_tree)
and these simulations
* k-cut
* sum of log(subtree sizes) over all fringe subtrees
* height
* total path length
It also provides a simply function for drawing trees.

The package can be used as a library in your code or in a Jupyter notebook. It can also run as a
standalone script.

## Installation

The package is in development and is not in Julia's official registry yet. Thus to use it, just
clone this repository to your computer. Then change directory to the root of this repository, and
start Julia REPL. Then enter the package mode by pressing `]`. You should see the prompt
```julia
(v1.1) pkg>
```
Type
```julia
(v1.1) pkg> dev .
```
should add `RandomTree.jl` to your default Julia environment. Then you can just use it as any other
Julia package.


## Usage

### Use `RandomTree.jl` In interactive environment

In Julia REPL, load `RandomTree.jl` by
```julia
julia> using RandomTree
```
To get the degree sequence of a Cayley tree of size 5 in depth-search-first order, type
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

To generate 1000 Cayley Trees and record their height, type
```
julia> sim = HeightSimulator(tree)
height simulation of Cayley Tree of size 5

julia> sim_result = simulation(sim, 1000)
1000-element Array{Any,1}:
 4
 3
 4
 5
 4
 3
 4
 4
 3
 3
 ⋮
 4
 3
 4
 4
 4
 3
 5
 4
 4
```

See `example.ipynb` in the notebook directory for more demonstrations.

### Use `RandomTree.jl` as a script

Change folder to the `src` directory and run
```
julia gwsim.jl -l 5 -n 10000 -t Cayley height
```
will generate 10000 Cayley trees of size 10^5 and print out their heights.
Run
```
julia gwsim.jl --help
```
to see the other options.

Note that the simulations can made parallel. For example
```
julia -p 4 gwsim.jl -l 5 -n 10000 -t Cayley height
```
will start 4 local processes on your machine to run the simulation.
You can also run simulations across several nodes of a cluster by using
```
julia --machine-file machines.txt gwsim.jl -l 5 -n 10000 -t Cayley height
```
where `machines.txt` contains the information of finding other machines.
See Julia's [documentats](https://docs.julialang.org/en/v1/manual/getting-started/) for details.
