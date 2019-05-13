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

# LogProductSimulator

"""
Simulation of the sum of log(subtree size)^`power` of trees.
"""
struct LogProductSimulator <: AbstractSimulator
    tree::FiniteTree
    power::Int
end

"""
    LogProductSimulator(tree)

Construct a `LogProductSimulator` that simulate the sum of log(subtree size) of trees.
"""
LogProductSimulator(tree) = LogProductSimulator(tree, 1)

"""
    simulation(sim::AbstractSimulator)

Return one sample in simulation `sim`.
"""
function simulation(sim::LogProductSimulator)
    # simulate the tree and count subtree sizes
    walker = SubtreeSizeWalker(sim.tree)
    walk(sim.tree, walker)
    subtree_sizes = result(walker)

    # do the log-product computation
    ret = zeros(Float64, sim.power)
    pow_range = Vector(1:sim.power)
    log_size::Float64 = 0
    for size in subtree_sizes
        @fastmath log_size = log(size)
        @fastmath @. ret += log_size^pow_range
    end
    ret
end

show(io::IO, sim::LogProductSimulator) = printfmt(io, "sum of the log(subtree_size)^(1:{})
                                                  simulation on {}", sim.power, sim.tree)

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
