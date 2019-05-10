module RandomTree

using Random, DataStructures, Formatting, ArgParse, Distributions, Distributed, PyCall

# For extending these methods
import Base: show, size

export 
    # Types of trees
    AbstractTree, 
    FiniteTree, 
    ## Conditional Galton Watson trees
    CondGWTree, 
    CayleyTree, 
    BinaryTree, 
    CatalanTree, 
    GenCondGWTree, 
    DAryTree, 
    MotzkinTree, 
    ## Other random trees
    RandomdRecursiveTree,

    # Functions applicable to trees
    size, name, 
    distribution,
    maxdegree,
    degrees,

    # DFS Tree walker
    AbstractTreeWalker,
    DepthWalker,
    KcutWalker,
    SubtreeSizeWalker,
    GraphWalker,

    # Tree traversing functions
    walk,

    # Simulations
    AbstractSimulator,
    KcutSimulator,
    LogProductSimulator,
    HeightSimulator,
    TotalPathSimulator,

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
