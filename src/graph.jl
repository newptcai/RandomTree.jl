# DirectedGraph

"Representing a fixed graph with edges stored in an array"
abstract type FixedGraph end

"Representing a fixed directed graph with directed edges stored in an array"
abstract type FixedDirectedGraph <: FixedGraph end

"""
    size(graph::FixedGraph)

Return the size of the graph `graph`
"""
size(graph::FixedGraph) = graph.size

"Return the array of edges of the graph"
edges(graph::FixedGraph) = graph.edges

"Return the nodes of the graph as an iterator"
nodes(graph::FixedGraph) = 1:graph.size

"Representing a fixed tree with directed edges stored in an array"
mutable struct FixedTreeGraph <: FixedDirectedGraph
    size::Int
    edges::Vector{Tuple{Int, Int}}
    positions::Union{Array{Int, 2}, Nothing}
end

"""
    FixedTreeGraph(size::Int)

Construct a `FixedTreeGraph` with no edges of `size`.
"""
FixedTreeGraph(size::Int) = FixedTreeGraph(size, [], nothing)

"""
    FixedTreeGraph(size::Int, edges::Array{Tuple{Int, Int}})

Construct a `FixedTreeGraph` with edges `edges` of size `size`.
"""
FixedTreeGraph(size::Int, edges::Array{Tuple{Int, Int}}) = FixedTreeGraph(size, edges, nothing)

"""
    addedge!(tree::FixedGraph, from, to)

Add an edge  `(from, to)` in `tree`.
"""
function addedge!(tree::FixedGraph, from, to)
    push!(edges(tree), (from, to))
end

"""
    positions(tree::FixedTreeGraph)::Array{Int, 2}

First sort the edges in the tree and then return an array containing the position and length of the
segment in the edge array corresponding to each node.
"""
function positions(tree::FixedTreeGraph)::Array{Int, 2}
    # Do not repeat computing this
    if tree.positions !== nothing
        return tree.positions
    end

    # Sort the edges by starting node
    sortedge!(tree)

    # The first number indicates where the segment belonging to a node starts.
    # The second number is how many edges this node has.
    position_arr = zeros(Int, (size(tree),2))
    current_node = 0
    for i in 1:(size(tree)-1)
        u, v = tree.edges[i]
        if u!= current_node
            current_node = u
            position_arr[current_node,1]=i
        end
        position_arr[current_node, 2]+=1
    end
    tree.positions = position_arr
end

"""
    sortedge!(tree::FixedTreeGraph)

Sort the edges in `tree` according to starting nodes.
"""
function sortedge!(tree::FixedTreeGraph)
    vertex_count = zeros(Int, size(tree))

    edge_array = edges(tree)

    # Count the number of edges
    for edge in edge_array
        @inbounds vertex_count[edge[1]] += 1
    end

    # Transform to cumulative sum
    for node in 2:size(tree)
        @inbounds vertex_count[node] += vertex_count[node-1]
    end

    # copy edges to the right position
    edge_sorted = Vector{Tuple{Int, Int}}(undef, length(edge_array))
    for edge in edge_array
        @inbounds from = edge[1]
        @inbounds position = vertex_count[from]
        @inbounds edge_sorted[position] = edge
        @inbounds vertex_count[from] -= 1
    end

    tree.edges = edge_sorted
end

function iterate(tree::FixedTreeGraph)
    position_array = positions(tree)

    root_degree = position_array[1, 2]

    stack = Stack{Tuple{Int, Int}}()
    if root_degree > 0
        push!(stack, (1, 0))
    end

    return (root_degree, (position_array, stack))
end

function iterate(tree::FixedTreeGraph, state)
    position_array, stack = state

    if isempty(stack)
        return nothing
    end

    parent_node, child_visited = pop!(stack)


    @inbounds next_edge = edges(tree)[position_array[parent_node]+child_visited]
    @inbounds next_node = next_edge[2]

    # Do we need to put parent back to the stack?
    @inbounds parent_degree = position_array[parent_node, 2]
    child_visited += 1
    if child_visited < parent_degree
        push!(stack, (parent_node, child_visited))
    end

    # Put the new node in the stack
    @inbounds current_degree = position_array[next_node, 2]
    if current_degree >= 1
        push!(stack, (next_node, 0))
    end

    return (current_degree, (position_array, stack))
end

degrees(tree::FixedTreeGraph) = tree

length(tree::FixedTreeGraph) = size(tree)
eltype(tree::FixedTreeGraph) = Int
