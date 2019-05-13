"Draw a grpahic representaion of a tree using [graphivz](http://www.graphviz.org/) and its [Python
Interface](https://github.com/xflr6/graphviz)"
function drawtree end

"""
    drawtree(tree_digraph::FixedGraph, show_label=false)

Draw a graphic representation of `tree_digraph`
"""
function drawtree(tree_digraph::FixedGraph, show_label=false)
    graphviz = pyimport("graphviz")
    digraph = graphviz.Graph()

    [digraph.node("$i") for i in nodes(tree_digraph)]

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

"""
    drawtree(deg_seq::Vector{Int}, show_label=false)

Draw a graphic representation of tree with DFS degree sequence `deg_seq`
"""
function drawtree(deg_seq::Vector{Int}, show_label=false)
    tree_digraph = treegraph(deg_seq)
    drawtree(tree_digraph , show_label)
end

"""
    drawtree(tree::FiniteTree, show_label=false)

Draw a graphic representation of the random/fixed tree `tree`.
"""
function drawtree(tree::FiniteTree, show_label=false)
    tree_digraph = treegraph(tree)
    drawtree(tree_digraph , show_label)
end
