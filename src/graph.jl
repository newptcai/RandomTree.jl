# DirectedGraph

abstract type FixedGraph end

size(graph::FixedGraph) = graph.size
edges(graph::FixedGraph) = graph.edges

struct FixedDirectedGraph <: FixedGraph
    size::Int
    edges::Array{Tuple{Int, Int}}
end
