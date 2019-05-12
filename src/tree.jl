abstract type AbstractTree end
abstract type FiniteTree <: AbstractTree end
abstract type FiniteRandomTree <: FiniteTree end
abstract type FiniteFixedTree <: FiniteTree end
abstract type CondGWTree <: FiniteRandomTree end

size(t::FiniteTree) = t.spec.size
name(t::FiniteTree) = t.spec.name
maxdegree(t::FiniteTree) = t.spec.maxdegree
show(io::IO, t::FiniteTree) where T = printfmt(io, "{} of size {}", name(t), size(t))

struct TreeSpec
    size::Int
    name::String
    maxdegree::Int
end

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

