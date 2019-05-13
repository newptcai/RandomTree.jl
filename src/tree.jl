"Type of all trees represented by DFS degree sequences"
abstract type AbstractTree end
"Type of fintie trees represented by DFS degree sequences"
abstract type FiniteTree <: AbstractTree end
"Type of fintie random trees represented by DFS degree sequences"
abstract type FiniteRandomTree <: FiniteTree end
"Type of fintie fixed trees represented by DFS degree sequences"
abstract type FiniteFixedTree <: FiniteTree end
"Type of conditional Galton-Watson trees represented by DFS degree sequences"
abstract type CondGWTree <: FiniteRandomTree end

"""
    size(t::FiniteTree)

Return the size of the tree `t`
"""
size(t::FiniteTree) = t.spec.size


"""
    name(t::FiniteTree)

Return the name of the tree `t`
"""
name(t::FiniteTree) = t.spec.name

"""
    maxdegree(t::FiniteTree)

Return the maximum degree of the tree `t`
"""
maxdegree(t::FiniteTree) = t.spec.maxdegree


show(io::IO, t::FiniteTree) where T = printfmt(io, "{} of size {}", name(t), size(t))

"The specification of a tree."
struct TreeSpec
    size::Int
    name::String
    maxdegree::Int
end

"""
    TreeSpec(size::Int, name::String)

Construct a [`TreeSpec`](@ref) of size `size` and name `name`.
"""
TreeSpec(size::Int, name::String) = TreeSpec(size, name, size)

include("tree/randtree.jl")
include("tree/fixedtree.jl")

TREE_DICT = Dict("Cayley" => CayleyTree,
                 "Binary" => BinaryTree, 
                 "Catalan" => CatalanTree, 
                 "DAry" => DAryTree,
                 "Motzkin" => MotzkinTree,
                 "RRT" => RandomRecursiveTree,
                 "FullDAry" => FullDAryTree,
                )

