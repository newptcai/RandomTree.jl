### FixedDAryTree

"""
A fixed full-d-ary tree, i.e., in a tree each node has either d or 0 children and each level is
full.
"""
struct FullDAryTree <: FiniteFixedTree
    spec::TreeSpec
    height::Int
end

"""
    FullDAryTree(height::Int, d::Int) 

Construct a `FullDAryTree` of height `height` and maximum degree `d`.
"""
function FullDAryTree(height::Int, d::Int) 
    if d > 1
        return FullDAryTree(TreeSpec((d^(height+1)-1)//(d-1), "Full $d-arry tree (height $height)", d), height)
    else
        return FullDAryTree(TreeSpec(height+1, "Full $d-arry tree (height $height)", d), height)
    end
end

# FixedDAryTree

degrees(tree::FullDAryTree) = tree
eltype(tree::FullDAryTree) = Int
length(tree::FullDAryTree) = size(tree)

function iterate(tree::FullDAryTree)
    stack = Stack{Tuple{Int, Int}}()
    if tree.height == 0
        return (0, stack)
    else
        push!(stack, (0, maxdegree(tree)))
        return (maxdegree(tree), stack)
    end
end

# We have to do a DFS to work out the degrees
function iterate(tree::FullDAryTree, stack)
    if isempty(stack)
        return nothing
    end

    d = maxdegree(tree)

    parent_height, child_left = pop!(stack)

    if child_left > 1
        push!(stack, (parent_height, child_left - 1))
    end

    current_height = parent_height += 1
    current_degree = 0

    if current_height < tree.height
        current_degree = d
        push!(stack, (current_height, d))
    end

    return (current_degree, stack)
end
