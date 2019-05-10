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

function drawtree(deg_seq, show_label=false)
    walker = GraphWalker(length(deg_seq))
    walk(deg_seq, walker, true)
    drawtree(walker.tree_digraph, show_label)
end

function drawtree(tree::FiniteTree, show_label=false)
    deg_seq = degrees(tree)
    drawtree(deg_seq, show_label)
end
