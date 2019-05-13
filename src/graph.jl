# DirectedGraph

abstract type FixedGraph end
abstract type FixedDirectedGraph <: FixedGraph end

size(graph::FixedGraph) = graph.size
edges(graph::FixedGraph) = graph.edges
nodes(graph::FixedGraph) = 1:graph.size

mutable struct FixedTreeGraph <: FixedDirectedGraph
    size::Int
    edges::Vector{Tuple{Int, Int}}
end

FixedTreeGraph(size::Int) = FixedTreeGraph(size, [])

function addedge!(tree::FixedGraph, from, to)
    push!(edges(tree), (from, to))
end

#function sortedge!(tree::FixedTreeGraph)
#    sort!(edges(tree), by=x->x[1])
#end

function positions(graph::FixedTreeGraph)
    # Sort the edges by starting node
    sortedge!(graph)

    # The first number indicates where the segment belonging to a node starts.
    # The second number is how many edges this node has.
    position_arr = zeros(Int, (size(graph),2))
    current_node = 0
    for i in 1:(size(graph)-1)
        u, v = graph.edges[i]
        if u!= current_node
            current_node = u
            position_arr[current_node,1]=i
        end
        position_arr[current_node, 2]+=1
    end
    position_arr
end

function sortedge!(tree::FixedTreeGraph)
    vertex_count = zeros(Int, size(tree))

    edge_array = edges(tree)

    # Count the number of edges
    for edge in edge_array
        vertex_count[edge[1]] += 1
    end

    # Transform to cumulative sum
    for node in 2:size(tree)
        vertex_count[node] += vertex_count[node-1]
    end

    # copy edges to the right position
    edge_sorted = Vector{Tuple{Int, Int}}(undef, length(edge_array))
    for edge in edge_array
        from = edge[1]
        position = vertex_count[from]
        edge_sorted[position] = edge
        vertex_count[from] -= 1
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


    next_edge = edges(tree)[position_array[parent_node]+child_visited]
    next_node = next_edge[2]

    # Do we need to put parent back to the stack?
    parent_degree = position_array[parent_node, 2]
    child_visited += 1
    if child_visited < parent_degree
        push!(stack, (parent_node, child_visited))
    end

    # Put the new node in the stack
    current_degree = position_array[next_node, 2]
    if current_degree >= 1
        push!(stack, (next_node, 0))
    end

    return (current_degree, (position_array, stack))
end

degrees(tree::FixedTreeGraph) = tree

length(tree::FixedTreeGraph) = size(tree)
eltype(tree::FixedTreeGraph) = Int
