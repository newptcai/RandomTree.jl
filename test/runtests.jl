using Test
using Random
using Distributions
using RandomTree

Random.seed!(0)

function treetest(tree)
    @test typeof(tree) <: FiniteTree
    @test isa(tree, FiniteTree)

    mdeg = maxdegree(tree)

    for i in 1:20
        degseq = RandomTree.degrees(tree)
        walk_seq = cumsum(broadcast(-, degseq, 1))
        @test all(x-> x>=0 && x <= mdeg, degseq)
        @test all(x-> x>=0, walk_seq[1:end-1])
        @test walk_seq[end] == -1
    end
end

@testset "RandomTree.jl" begin
@testset "tree.jl" begin
    @testset "CayleyTree" begin
        tree = CayleyTree(50)
        treetest(tree)
    end

    @testset "BinaryTree" begin
        tree = BinaryTree(50)
        treetest(tree)
    end

    @testset "CatalanTree" begin
        tree = CatalanTree(50)
        treetest(tree)
    end

    @testset "MotzkinTree" begin
        tree = MotzkinTree(50)
        treetest(tree)
    end

    @testset "DAryTree" begin
        for d in 2:5
            tree = DAryTree(50, d)
            treetest(tree)
        end
    end

    @testset "RandomRecursiveTree" begin
        tree = RandomRecursiveTree(50)
        treetest(tree)
    end
    
    @testset "FullDAryTree" begin
        tree = FullDAryTree(5, 1)
        @test length(tree) == 6
        @test collect(degrees(tree)) == [1, 1, 1, 1, 1, 0]
        tree = FullDAryTree(3, 2)
        @test length(tree) == 2^4-1
        @test collect(degrees(tree)) == [2, 2, 2, 0, 0, 2, 0, 0, 2, 2, 0, 0, 2, 0, 0]
        treetest(tree)
    end

    @testset "Degree sequence" begin
        testseq = [ 
                    [[0, 0, 1, 2, 1], 3, [1, 2, 1, 0, 0]], 
                    [[0, 0, 0, 2, 2], 4, [2, 2, 0, 0, 0]], 
                    [[1, 1, 1, 1, 0], 1, [1, 1, 1, 1, 0]], 
                    ]

        for case in testseq
            @test RandomTree.find_startindex(case[1]) == case[2]
        end

        for case in testseq
            @test RandomTree.fix_degseq(case[1]) == case[3]
        end

        dist = Geometric(1/2)
        n = 100
        for i in 1:200
            degcount = RandomTree.degrees_count(n, dist, n)
            @test all(x-> x>= 0, degcount)
            @test sum((i-1)*degcount[i] for i in 1:length(degcount)) == n-1
        end

        for d in 2:5
            dist = Binomial(d, 1/d)
            n = 100
            for i in 1:200
                degcount = RandomTree.degrees_count(n, dist, d)
                @test length(degcount) <= d+1
                @test all(x-> x>= 0, degcount)
                @test sum((i-1)*degcount[i] for i in 1:length(degcount)) == n-1
            end
        end

        @test RandomTree.degrees(10, [4,4,1,1]) == vec([0 0 0 0 1 1 1 1 2 3])
        @test RandomTree.degrees(10, [4,3,3]) == vec([0 0 0 0 1 1 1 2 2 2])
    end
end

@testset "walker.jl" begin
    tree = CayleyTree(5)

    @testset "DepthWalker" begin
        walker = DepthWalker(tree)
        @test walk(tree, walker) == [2, 1, 1, 0, 0]
        @test result(walker) ==  [0, 1, 2, 3, 1]
        
        testseq= [ 
                    [[1, 2, 1, 0, 0], [0, 1, 2, 3, 2]], 
                    [[2, 1, 0, 1, 0], [0, 1, 2, 1, 2]],
                    [[2, 1, 1, 0, 0], [0, 1, 2, 3, 1]],
                    ]

        for (degseq, depth_seq) in testseq
            walker = DepthWalker(tree)
            @test degseq == walk(degseq, walker)
            @test result(walker) == depth_seq
        end
    end

    @testset "SubtreeSizeWalker" begin
        walker = SubtreeSizeWalker(tree)
        @test walk(tree, walker) == [2, 1, 1, 0, 0]
        @test result(walker) ==  [5, 3, 2, 1, 1]
        
        testseq= [ 
                    [[1, 2, 1, 0, 0], [5, 4, 2, 1, 1]], 
                    [[2, 1, 0, 1, 0], [5, 2, 1, 2, 1]],
                    [[2, 1, 1, 0, 0], [5, 3, 2, 1, 1]],
                    ]

        for (degseq, subtree_size_seq) in testseq
            walker = SubtreeSizeWalker(tree)
            @test degseq == walk(degseq, walker)
            @test result(walker) == subtree_size_seq
        end
    end

    @testset "GraphWalker" begin
        testseq= [ 
                    [[1, 1, 2, 0, 0], [(1, 2), (2, 3), (3, 4), (3, 5)]], 
                    [[2, 1, 1, 0, 0], [(1, 2), (2, 3), (3, 4), (1, 5)]],
                    ]
        for (degseq, ret_edges) in testseq
            walker = GraphWalker(tree)
            @test size(walker.tree_digraph) == size(tree)
            @test degseq == walk(degseq, walker)
            @test RandomTree.edges(result(walker)) == ret_edges
        end
    end
end

@testset "simulator" begin
    SIZE = 101

    trees = [CayleyTree(SIZE), BinaryTree(SIZE)]

    @testset "KcutSimulator" begin
        for tree = trees
            k = 2
            sim = KcutSimulator(tree, k)

            @test repr(sim) != ""

            @test sim.tree === tree
            @test sim.k == k

            r1, r2 = simulation(sim)
            @test  SIZE >= r1 >= r2 >0

            for ret = simulation(sim, 20)
                r1, r2 = ret
                @test  SIZE >= r1 >= r2 >0
            end
        end
    end

    @testset "LogProductSimulator" begin
        # For binary tree of size 5, this is always log(15)
        sim = LogProductSimulator(BinaryTree(5))
        @test simulation(sim) ≈ log(5)+log(3)

        for tree = trees
            for pow = 1:3
                sim = LogProductSimulator(tree, pow)

                @test repr(sim) != ""

                @test sim.tree === tree

                ret = simulation(sim)
                @test ret isa Real
                @test ret > log(SIZE)^pow
            end
        end
    end

    @testset "HeightSimulator" begin
        for tree = trees
            sim = HeightSimulator(tree)

            @test repr(sim) != ""

            ret = simulation(sim)
            @test ret >= 1 && ret <= size(tree)

            for ret = simulation(sim, 20)
                ret = simulation(sim)
                @test ret >= 1 && ret <= size(tree)
            end
        end
    end

    @testset "TotalPathSimulator" begin
        for tree = trees
            sim = TotalPathSimulator(tree)

            @test repr(sim) != ""

            ret = simulation(sim)
            @test ret >= size(tree)-1 && ret <= size(tree)^2

            for ret = simulation(sim, 20)
                ret = simulation(sim)
                @test ret >= 1 && ret <= size(tree)^2
            end
        end
    end
end

@testset "FixedGraph" begin
    tgraph = RandomTree.FixedTreeGraph(6, [(1, 2); (2, 3); (3, 4); (1, 5); (4, 6)])
    
    sortedge!(tgraph)
    @test edges(tgraph) == [(1, 5), (1, 2), (2, 3), (3, 4), (4, 6)]


    position_array = RandomTree.positions(tgraph)

    @test position_array == [1 2; 3 1; 4 1; 5 1; 0 0; 0 0]
    @test collect(degrees(tgraph)) == [2, 1, 1, 1, 0, 0]
end
end

