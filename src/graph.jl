# DirectedGraph

abstract type FixedGraph end
abstract type FixedDirectedGraph <: FixedGraph end

size(graph::FixedGraph) = graph.size
edges(graph::FixedGraph) = graph.edges
nodes(graph::FixedGraph) = 1:graph.size

struct FixedTreeGraph <: FixedDirectedGraph
    size::Int
    edges::Array{Tuple{Int, Int}}
end

FixedTreeGraph(size::Int) = FixedTreeGraph(size, Array{Tuple{Int, Int}}([]))

function positions(graph::FixedTreeGraph)
    # Sort the edges by starting node
    sort!(graph.edges, by=x->x[1])
  
    # The first number indicates where the segment belonging to a node starts.
    # The second number is how many edges this node has.
    position_arr = zeros(Int, (size(graph),2))
    current_node = 0
    for i in 1:length(graph.edges)
        u, v = graph.edges[i]
        if u!= current_node
            current_node = u
            position_arr[current_node,1]=i
        end
        position_arr[current_node, 2]+=1
    end
    position_arr
end

function iterate(tree::FixedTreeGraph)
    position_array = positions(tree)
    print(position_array)

    root_degree = position_array[1, 2]

    stack = Stack{Tuple{Int, Int}}()
    push!(stack, (1, 0))

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
