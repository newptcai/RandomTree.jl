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

### Cayley Tree

"A conditional Galton-Watson tree with Poission(1) offspring distrbiution."
struct CayleyTree <: CondGWTree
    spec::TreeSpec
end
"""
    CayleyTree(size::Int)

Construct a `CayleyTree` of size `size`.
"""
CayleyTree(size::Int) = CayleyTree(TreeSpec(size, "Cayley Tree"))

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

### Binary Tree

"A conditional Galton-Watson tree with `2 Bernoulli(1/2)` offspring distrbiution."
struct BinaryTree <: CondGWTree
    spec::TreeSpec
end

"""
    BinaryTree(size::Int)

Construct a `BinaryTree` of size `size`.
"""
function BinaryTree(size::Int)
    if iseven(size)
        size += 1
    end
    BinaryTree(TreeSpec(size, "Binary Tree"))
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

### General conditioned Galton-Watson tree

"A conditional Galton-Watson tree."
struct GeneralCondGWTree <: CondGWTree
    "Specification"
    spec::TreeSpec
    "Offspring distribution"
    dist::DiscreteUnivariateDistribution
end

distribution(tree::GeneralCondGWTree) = tree.dist

"""
    GeneralCondGWTree(size::Int, maxdegree::Int, dist::DiscreteUnivariateDistribution) 

Construct a `GeneralCondGWTree` of size `size` and offspring distribution `dist`.
"""
function GeneralCondGWTree(size::Int, maxdegree::Int, dist::DiscreteUnivariateDistribution) 
    GeneralCondGWTree(TreeSpec(size, "Conditional Galton-Watson Tree with offspring distribution $dist", maxdegree), dist)
end

"""
    GeneralCondGWTree(size::Int, maxdegree::Int, dist::DiscreteUnivariateDistribution) 

Construct a `GeneralCondGWTree` of size `size`, maximum degree `maxdegree`, and offspring
distribution `dist`.
"""
function GeneralCondGWTree(size::Int, dist::DiscreteUnivariateDistribution) 
    GeneralCondGWTree(size, size, dist)
end

"""
    CatalanTree(size::Int) 

Construct a `GeneralCondGWTree` with `Geometric(1/2)` offspring distribution of size `size`.
"""
CatalanTree(size::Int) = GeneralCondGWTree(TreeSpec(size, "Catalan Tree"), Geometric(0.5))

"""
    DAryTree(size::Int, d::Int) 

Construct a `GeneralCondGWTree` with `Binomial(d, 1/d)` offspring distribution of size `size`.
"""
DAryTree(size::Int, d::Int) = GeneralCondGWTree(TreeSpec(size, "$d-ary Tree", d), Binomial(d, 1/d))

"""
    MotzkinTree(size::Int)

Construct a `GeneralCondGWTree` with `DiscreteUniform(0, 2)` offspring distribution of size `size`.
"""
MotzkinTree(size::Int) = GeneralCondGWTree(TreeSpec(size, "Motzkin Tree", 2), DiscreteUniform(0, 2))

function degrees_rotate(tree::GeneralCondGWTree)
    degcount = degrees_count(size(tree), distribution(tree), maxdegree(tree))
    degseq = degrees(size(tree), degcount)
    shuffle!(degseq)
end

"""
    treegraph(tree)::FixedTreeGraph

Either convert a fixed `tree` to a `FixedTreeGraph`, or generate a random `FixedTreeGraph` according
to `tree`.
"""
function treegraph end

function treegraph(tree::FiniteTree)::FixedTreeGraph
    degseq = degrees(tree)
    walker = GraphWalker(size(tree))
    walk(degseq, walker, true)
    walker.tree_digraph
end

function treegraph(degseq::Vector{Int})::FixedTreeGraph
    walker = GraphWalker(length(degseq))
    walk(degseq, walker, true)
    walker.tree_digraph
end

### RandomRecursiveTree

"""
A random recursive tree.
"""
struct RandomRecursiveTree <: FiniteRandomTree
    spec::TreeSpec
end

"""
    RandomRecursiveTree(size::Int) 

Construct a `RandomRecursiveTree` of size `size`.
"""
RandomRecursiveTree(size::Int) = RandomRecursiveTree(TreeSpec(size, "Random Recursive Tree"))

"""
    degrees(tree)

Return an iterator that traverses the degree sequence of `tree` in DFS order.
"""
function degrees end

function degrees(tree::RandomRecursiveTree)
    return treegraph(tree)
end

function treegraph(tree::RandomRecursiveTree)::FixedTreeGraph
    treesize = size(tree)
    graph = FixedTreeGraph(treesize)

    for current_node in 2:treesize
        parent_node = rand(1:current_node-1)
        addedge!(graph, parent_node, current_node)
    end

    graph
end
