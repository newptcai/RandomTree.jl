# AbstractSimulator

"Simulator on random/fixed trees"
abstract type AbstractSimulator end

"""
    print_simulation(sim::AbstractSimulator, nsample)

Print `nsample` samples in simulation `sim`.
"""
function print_simulation(sim::AbstractSimulator, nsample)
    printfmtln("# {} -- {} sample(s)", sim, nsample)
    #printfmtln("# Seed of random number generator {}", Random.GLOBAL_RNG.seed)

    @sync @distributed for i = 1:nsample
        #host = gethostname()

        #print("$host ")
        for r = simulation(sim)
            printfmt("{} ", r)
        end
        println()
        if i % 10 == 0
            flush(stdout)
        end
    end
end

"""
    simulation(sim::AbstractSimulator, nsample)

Return `nsample` samples in simulation `sim`.
"""
function simulation(sim::AbstractSimulator, nsample)
    results = Vector{Any}(undef, nsample)
    for i in 1:nsample
        results[i] = simulation(sim)
    end
    results
end

# KcutSimulator

"""
Simulation of the [k-cut number](https://arxiv.org/abs/1804.03069) of trees.
"""
struct KcutSimulator <: AbstractSimulator
    tree::FiniteTree
    k::Int
end

function simulation(sim::KcutSimulator)
    walker = KcutWalker(sim.k)
    walk(sim.tree, walker)
    result(walker)
end

show(io::IO, sim::KcutSimulator) = printfmt(io, "{}-cut simulation on {}", sim.k, sim.tree)

# SubtreeSizeSimulator

"""
Simulation of the additive function in the form of sum of func(subtree size) applied to random trees.
"""
struct SubtreeSizeSimulator{F<:Function} <: AbstractSimulator
    tree::FiniteTree
    func::F
    funcname::String
end

"""
    simulation(sim::SubtreeSizeSimulator)

Return one sample in simulation `sim`.
"""
function simulation(sim::SubtreeSizeSimulator)
    # simulate the random tree and get subtree sizes
    walker = SubtreeSizeWalker(sim.tree)
    walk(sim.tree, walker)
    subtree_sizes = result(walker)

    # sum over log of subtree sizes
    ret = 0
    for size in subtree_sizes
        @fastmath ret += sim.func(size)
        #@fastmath ret += log(size)
    end
    ret
end

show(io::IO, sim::SubtreeSizeSimulator) = printfmt(io, "sum of {} simulation on {}", 
                                                   sim.funcname, sim.tree)
# LogProductSimulator

"""
    LogProductSimulator(tree)

Construct a `SubtreeSizeSimulator` that simulate the sum of log(subtree size) of trees.
"""
LogProductSimulator(tree) = LogProductSimulator(tree, 1)

"""
    LogProductSimulator(tree, power)

Construct a `SubtreeSizeSimulator` that simulate the sum of log(subtree size)^`power` of trees.
"""
function LogProductSimulator(tree::FiniteTree, power::Int) 
    function func(size::Int)
        @fastmath log(size)^power
    end
    return SubtreeSizeSimulator(tree, func, format("log(subtree size)^{}", power))
end

#"""
#    simulation(sim::AbstractSimulator)
#
#Return one sample in simulation `sim`.
#"""
#function simulation(sim::LogProductSimulator)
#    # simulate the tree and count subtree sizes
#    walker = SubtreeSizeWalker(sim.tree)
#    walk(sim.tree, walker)
#    subtree_sizes = result(walker)
#
#    # do the log-product computation
#    ret = 0
#    for size in subtree_sizes
#        @fastmath ret += log(size)^sim.power
#    end
#    ret
#end
#
#show(io::IO, sim::LogProductSimulator) = printfmt(io, "sum of the log(subtree_size)^{} simulation on {}", 
#                                                  sim.power, sim.tree)

# TotalPathSimulator

"""
Simulation of the [total path length](https://arxiv.org/abs/1102.2541) of trees.
"""
struct TotalPathSimulator <: AbstractSimulator
    tree::FiniteTree
end

function simulation(sim::TotalPathSimulator)
    # simulate the tree and count subtree sizes
    walker = SubtreeSizeWalker(sim.tree)
    walk(sim.tree, walker)

    sum(result(walker)[2:end])
end

show(io::IO, sim::TotalPathSimulator) = printfmt(io, "total path length simulation of {}", sim.tree)

# HeightSimulator

"""
Simulation of height of trees.
"""
struct HeightSimulator <: AbstractSimulator
    tree::FiniteTree
end

function simulation(sim::HeightSimulator)
    walker = DepthWalker(sim.tree)
    walk(sim.tree, walker)
    maximum(result(walker))
end

show(io::IO, sim::HeightSimulator) = printfmt(io, "height simulation of {}", sim.tree)

# LeafSimulator

"""
Simulation of the number of leafs.
"""
struct LeafSimulator <: AbstractSimulator
    tree::FiniteTree
end

function simulation(sim::LeafSimulator )
    degseq = degrees(sim.tree)
    leafnum = 0
    for degree in degseq
        if degree == 0
            leafnum += 1
        end
    end
    leafnum
end

show(io::IO, sim::LeafSimulator) = printfmt(io, "leaf number simulation of {}", sim.tree)
