"""
A Julia package for simulating random trees.
"""
module RandomTree

using Random, DataStructures, Formatting, ArgParse, Distributions, Distributed, PyCall

# For extending these methods
import Base: show, size, iterate, eltype, length

export 
    # Types of trees
    AbstractTree, 
    FiniteTree, 
    ## Conditional Galton Watson trees
    CondGWTree, 
    CayleyTree, 
    BinaryTree, 
    CatalanTree, 
    GeneralCondGWTree, 
    DAryTree, 
    MotzkinTree, 
    ## Other random trees
    RandomRecursiveTree,
    ## Fixed trees
    FullDAryTree,

    # Functions applicable to trees
    size, 
    name, 
    distribution,
    maxdegree,
    degrees,
    treegraph,

    # Graph representations of trees
    FixedGraph,
    FixedDirectedGraph,
    FixedTreeGraph,

    # Functions applicable to FixedGraph
    positions,
    edges,
    nodes,
    sortedge!,
    addedge!,

    # Tree walkers
    AbstractTreeWalker,
    DFSWalker,
    FirstOnlyDFSWalker,
    DepthWalker,
    KcutWalker,
    SubtreeSizeWalker,
    GraphWalker,

    # Functions applicable to AbstractTreeWalker
    walk,
    result,

    # Simulations
    AbstractSimulator,
    KcutSimulator,
    LogProductSimulator,
    HeightSimulator,
    TotalPathSimulator,
    LeafSimulator,

    # Simulations functions
    simulation, 
    print_simulation,
    drawtree, 

    # Command-line script entry point
    main

include("graph.jl")
include("tree.jl")
include("walker.jl")
include("simulator.jl")
include("graphic.jl")
include("args.jl")
include("main.jl")

end # module
