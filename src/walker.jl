abstract type AbstractTreeWalker end

"""
A `DFSWalker` does DFS walk on a tree to compute some property of the tree.  It should implement at least
one of the two functions.

    visitfirst(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)
    visitsecond(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)

The first is called when the DFS walk first enters a node. The second is call when the walk finally
leaves the node.
"""
abstract type DFSWalker <: AbstractTreeWalker end

"""
A DFS walker that only needed to be called when the walk enters a node.
"""
abstract type FirstOnlyDFSWalker <: DFSWalker end

"""
    visitfirst(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)

The function is called when the `walker` first enters a node.
"""
function visitfirst(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)
end

"""
    visitsecond(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)

The function is called when the `walker` finally leaves a node.
"""
function visitsecond(walker::AbstractTreeWalker, degree_sequence, node_index, parent_index)
end

"""
    result(walker::AbstractTreeWalker)

Return of the result of the walk on the tree.
"""
function result(walker::AbstractTreeWalker)
    error("Please implement this function")
end

# DFS walk

function walk(degree_sequence, walker::AbstractTreeWalker, first_only=false::Bool)
    # initialize the stack
    cur_index::Int = 1
    deg, state = iterate(degree_sequence)

    stack = Stack{Tuple{Int, Int, Int}}()
    push!(stack, (deg, cur_index, 0))
    visitfirst(walker, degree_sequence, cur_index, 0)

    # while the stack is not empty
    while length(stack)> 0
        #print stack
        child_left, node_index, parent_index = pop!(stack)

        if child_left > 0
            # If we go down wards
            # put this back node in stack

            # no need to put in the stack if we do not need it anymore
            if (child_left != 1) || (!first_only)
                push!(stack, (child_left - 1, node_index, parent_index))
            end

            # put the child node in the stack
            cur_index += 1
            deg, state = iterate(degree_sequence, state)
            push!(stack, (deg, cur_index, node_index))
            visitfirst(walker, degree_sequence, cur_index, node_index)
        else
            if !first_only
                visitsecond(walker, degree_sequence, node_index, parent_index)
            end
        end
    end
    degree_sequence
end

function walk(tree::FiniteTree, walker::FirstOnlyDFSWalker)
    degree_sequence = degrees(tree)
    walk(degree_sequence, walker, true)
end

"""
    walk(tree::FiniteTree, walker::DFSWalker)

Make `walker` do a DFS walk on `tree`.
"""
function walk(tree::FiniteTree, walker::DFSWalker)
    degree_sequence = degrees(tree)
    walk(degree_sequence, walker)
end

# DepthWalker
"A walker computes the depths of all nodes in a tree."
struct DepthWalker <: FirstOnlyDFSWalker
    depth_seq::Vector{Int}
end

DepthWalker(tree::FiniteTree) = DepthWalker(zeros(size(tree)))

result(walker::DepthWalker) = walker.depth_seq

function visitfirst(walker::DepthWalker, degree_sequence, node_index, parent_index)
    if (node_index > 1)
        walker.depth_seq[node_index] = walker.depth_seq[parent_index] + 1
    end
end

# SubtreeSizeWalker

"A walker computes the size of all subtrees of a tree."
struct SubtreeSizeWalker <: DFSWalker
    subtree_size_seq::Vector{Int}
end

SubtreeSizeWalker(tree::FiniteTree) = SubtreeSizeWalker(ones(size(tree)))

result(walker::SubtreeSizeWalker) = walker.subtree_size_seq

function visitsecond(walker::SubtreeSizeWalker, degree_sequence, node_index, parent_index)
    if parent_index >= 1
        walker.subtree_size_seq[parent_index] += walker.subtree_size_seq[node_index]
    end
end

# KcutWalker 

"A walker computes the (random) k-cut number of a tree."
mutable struct KcutWalker <: FirstOnlyDFSWalker
    k::Int
    record_num::Vector{Int}
    record::Float64
end
"""
    KcutWalker(k::Integer)

Construct a `KcutWalker` to compute the `k`-cut number of a tree.
"""
KcutWalker(k::Integer) = KcutWalker(k, zeros(Int, k), Inf)

result(walker::KcutWalker) = walker.record_num

function visitfirst(walker::KcutWalker, degree_sequence, node_index, parent_index)
    t::Float64 = 0.0
    for i in 1:walker.k
        t += randexp()
        if t < walker.record
            walker.record_num[i]+=1.0
        end
    end
    if t < walker.record
        walker.record = t
    end
end

# GraphWalker

"A walker that converts a tree represented in DFS degree sequence to a `FixedTreeGraph`."
mutable struct GraphWalker <: FirstOnlyDFSWalker
    tree_digraph::FixedTreeGraph
end

result(walker::GraphWalker) = walker.tree_digraph

GraphWalker(size::Int) = GraphWalker(FixedTreeGraph(size))
GraphWalker(tree::FiniteTree) = GraphWalker(size(tree))

function visitfirst(walker::GraphWalker, degree_sequence, node_index, parent_index)
    if parent_index >= 1
        addedge!(walker.tree_digraph, parent_index, node_index)
    end
end
