# Usage

## Use `RandomTree.jl` In interactive environment

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

See [`example.ipynb`](https://nbviewer.jupyter.org/github/newptcai/RandomTree.jl/blob/master/notebook/demonstration.ipynb) in the notebook directory for more demonstrations.

## Use `RandomTree.jl` as a script

In a terminal, change folder to the `~/.julia/dev/RandomTree/src` and run the command
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

