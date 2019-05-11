function drawtree(tree_digraph::FixedGraph, show_label=false)
    graphviz = pyimport("graphviz")
    digraph = graphviz.Graph()

    [digraph.node("$i") for i in 1:size(tree_digraph)]

    for next = edges(tree_digraph)
        parent, child = next
        digraph.edge("$parent", "$child")
    end

    digraph.graph_attr = PyDict(Dict("size" => "12,12"))

    node_attr = Dict("shape" => "circle",
                                    "color"=>"red",
                                    "fillcolor"=>"orange",
                                    "style" => "filled",
                                    "fixedsize" => "true", 
                                    "nodesep" => "0.3",
                                    "ranksep" => "0.3",
                                    "width" => "0.3")
    if !show_label
        node_attr["label"] = ""
    end
    digraph.node_attr = PyDict(node_attr)

    digraph
end

function drawtree(deg_seq::Vector{Int}, show_label=false)
    tree_digraph = treegraph(deg_seq)
    drawtree(tree_digraph , show_label)
end

function drawtree(tree::FiniteTree, show_label=false)
    tree_digraph = treegraph(tree)
    drawtree(tree_digraph , show_label)
end
