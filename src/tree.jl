abstract type AbstractTree end
abstract type FiniteTree <: AbstractTree end
abstract type FiniteRandomTree <: FiniteTree end
abstract type FiniteFixedTree <: FiniteTree end
abstract type CondGWTree <: FiniteRandomTree end

size(t::FiniteTree) = t.spec.size
name(t::FiniteTree) = t.spec.name
maxdegree(t::FiniteTree) = t.spec.maxdegree
show(io::IO, t::FiniteTree) where T = printfmt(io, "{} of size {}", name(t), size(t))

struct TreeSpec
    size::Int
    name::String
    maxdegree::Int
end

TreeSpec(size::Int, name::String) = TreeSpec(size, name, size)

### Degree sequence functions

function find_startindex(degseq_rotated::Vector{<:Integer})
    min_value = Inf64
    min_index = 0
    current_sum = 0
    size = length(degseq_rotated)
    for i = 1:length(degseq_rotated)
        current_sum += degseq_rotated[i]-1
        if current_sum < min_value
            min_value = current_sum
            min_index = i
        end
    end
    return (min_index+1) % size
end

function fix_degseq(degseq_rotated::Vector{<:Integer})
    start_index = find_startindex(degseq_rotated)
    return circshift(degseq_rotated, -(start_index-1))
end

function degrees_count(size::Int, dist::DiscreteUnivariateDistribution, maxdegree::Int)
    buf = 16 # This is enough for almost all real applications
    degcount = Vector{Int}(undef, buf)
    
    while true
        cur = 0
        total_node = 0
        total_deg = 0
        p_cum = 0.0
        p_cur = 0.0
        p_para::Float64 = 0.0
        current_degcount = 0
        deg = 0

        while total_deg < size - 1 && total_node < size && deg <= maxdegree
            p_cur = pdf(dist, deg)
            p_para = p_cur/(1-p_cum)
            # This happens at the boundary
            if p_para > 1.0 || p_para < 0.0
                p_para = 1.0
            end
            current_degcount = rand(Binomial(size-total_node, p_para))
            total_node += current_degcount
            total_deg += deg*current_degcount
            if deg < length(degcount)
                degcount[deg+1] = current_degcount
            else
                push!(degcount, current_degcount)
            end
            p_cum += p_cur
            deg += 1
        end
        
        if total_deg == size - 1 && total_node == size
            return degcount[1:deg]
        end
    end
end

function degrees(size::Int, degcount::AbstractArray{T, 1}) where T <: Integer
    degseq = Array{Int, 1}(undef, size)
    pos = 1
    for deg in 0:length(degcount)-1
        n = degcount[deg+1]
        degseq[pos:pos+n-1] .= deg
        pos = pos + n
    end
    degseq
end

# Cayley Tree

struct CayleyTree <: CondGWTree
    spec::TreeSpec
    CayleyTree(size::Int) = new(TreeSpec(size, "Cayley Tree"))
end

function degrees_rotate(tree::CayleyTree, nbatch=2048)
    # See Svante Example 12.1 and Luc's simulation paper
    treesize = size(tree)
    degseq = zeros(Int32, treesize)
    batch = Vector{Int}(undef, nbatch)
    i = 0
    while i + nbatch < treesize
        rand!(batch, 1:treesize)
        for j = 1:nbatch
            @inbounds degseq[batch[j]] += 1
        end
        i += nbatch
    end
    for j = i+1:treesize-1
        box = rand(1:treesize)
        degseq[box] += 1
    end
    degseq
end

function degrees(tree::CondGWTree)
    degseq = degrees_rotate(tree)
    fix_degseq(degseq)
end

# Binary Tree

struct BinaryTree <: CondGWTree
    spec::TreeSpec
    function BinaryTree(size::Int)
        if iseven(size)
            size += 1
        end
        new(TreeSpec(size, "Binary Tree"))
    end
end

function degrees_rotate(tree::BinaryTree)
    treesize = size(tree)
    degseq = Array{Int32}(undef, treesize)
    lefanum = convert(Int, (treesize + 1)/2)

    # initialize the array
    degseq[1:lefanum] .= 0
    degseq[lefanum+1:end] .= 2

    shuffle!(degseq)
end

# General conditioned Galton-Watson tree

struct GenCondGWTree <: CondGWTree
    spec::TreeSpec
    dist::DiscreteUnivariateDistribution
end

distribution(tree::GenCondGWTree) = tree.dist

function GenCondGWTree(size::Int, maxdegree::Int, dist::DiscreteUnivariateDistribution) 
    GenCondGWTree(TreeSpec(size, "Conditional Galton-Watson Tree with offspring distribution $dist", maxdegree), dist)
end

function GenCondGWTree(size::Int, dist::DiscreteUnivariateDistribution) 
    GenCondGWTree(size, size, dist)
end

CatalanTree(size::Int) = GenCondGWTree(TreeSpec(size, "Catalan Tree"), Geometric(0.5))

DAryTree(size::Int, d::Int) = GenCondGWTree(TreeSpec(size, "$d-ary Tree", d), Binomial(d, 1/d))

MotzkinTree(size::Int) = GenCondGWTree(TreeSpec(size, "Motzkin Tree", 2), DiscreteUniform(0, 2))

function degrees_rotate(tree::GenCondGWTree)
    degcount = degrees_count(size(tree), distribution(tree), maxdegree(tree))
    degseq = degrees(size(tree), degcount)
    shuffle!(degseq)
end

function treegraph(tree::CondGWTree)
    degseq = degrees(tree)
    walker = GraphWalker(size(tree))
    walk(degseq, walker, true)
    walker.tree_digraph
end

# RandomdRecursiveTree

struct RandomdRecursiveTree <: FiniteRandomTree
    spec::TreeSpec
end
RandomdRecursiveTree(size::Int) = RandomdRecursiveTree(TreeSpec(size, "Random Recursive Tree"))

function degrees(tree::RandomdRecursiveTree)
    # The code below is incorrect. It does not give the DFS degree seq. This is very different from
    # Galton-Watson trees.
    throw("unimplemented")
    #treesize = size(tree)
    #degseq = zeros(Int, treesize)

    #for current_node in 2:treesize
    #    parent_node = rand(1:current_node-1)
    #    degseq[parent_node] += 1
    #end

    #degseq
end

function treegraph(tree::RandomdRecursiveTree)::FixedGraph
    treesize = size(tree)
    graph = FixedDirectedGraph(treesize)

    for current_node in 2:treesize
        parent_node = rand(1:current_node-1)
        push!(graph.edges, (parent_node, current_node))
    end

    graph
end

TREE_DICT = Dict("Cayley" => CayleyTree,
                 "Binary" => BinaryTree, 
                 "Catalan" => CatalanTree, 
                 "DAry" => DAryTree,
                 "Motzkin" => MotzkinTree,
                 "RRT" => RandomdRecursiveTree,
                )

