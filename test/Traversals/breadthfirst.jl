import LightGraphs.Traversals: preinitfn!, TraversalState
@testset "BreadthFirst" begin

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    g6 = smallgraph(:house)
    struct DummyState <: LT.TraversalState end

    @testset "default traverse_graph!" begin
        for g in testdigraphs(g5)
            @test LT.traverse_graph!(g, 1, LT.BreadthFirst(), DummyState())
        end
    end

    @testset "bfs tree and bfs parents" begin
        for g in testdigraphs(g5)
            z = @inferred(LT.tree(g, 1, LT.BreadthFirst()))
            t = LT.parents(g, 1, LT.BreadthFirst())
            @test t == [0, 1, 1, 3]
            @test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
        end

        for g in testgraphs(g6)
            n = nv(g)
            p = LT.parents(g, 1, LT.BreadthFirst())
            @test length(p) == n
            t1 = @inferred LT.tree(g, 1, LT.BreadthFirst())
            t2 = LT.tree(p)
            @test t1 == t2
            @test is_directed(t2)
            @test typeof(t2) <: AbstractGraph
            @test ne(t2) < nv(t2)
        end
    end

    function test_traversal_error(g::AbstractGraph, s, state::TraversalState)
        LT.traverse_graph!(g, s, LT.BreadthFirst(), state) || throw(LT.TraversalError())
        return true
    end

    @testset "distances" begin
        LT.preinitfn!(::DummyState, u) = false

        for g in testgraphs(g6)
            @test @inferred(LT.distances(g, 2)) == @inferred(LT.distances(g, 2, LT.BreadthFirst(sort_alg=MergeSort))) == [1, 0, 2, 1, 2]

            @test @inferred(LT.distances(g, [1, 2])) == [0, 0, 1, 1, 2]
            @test @inferred(LT.distances(g, [])) == fill(typemax(eltype(g)), 5)

            @test_throws LT.TraversalError test_traversal_error(g, 1, DummyState())
        end
    end

    @testset "is_bipartite" begin
        gx = SimpleGraph(5)
        add_edge!(gx, 1, 2); add_edge!(gx, 1, 4)
        add_edge!(gx, 2, 3); add_edge!(gx, 2, 5)
        add_edge!(gx, 3, 4)

        for g in testgraphs(gx)
            @test @inferred(LT.is_bipartite(g))
        end
    end

    @testset "has_path" begin
        gx = SimpleGraph(6)
        d = nv(gx)
        for (i, j) in [(1, 2), (2, 3), (2, 4), (4, 5), (3, 5)]
            add_edge!(gx, i, j)
        end

        for g in testgraphs(gx)
            @test has_path(g, 1, 5)
            @test has_path(g, 1, 2)
            @test has_path(g, 1, 5; exclude_vertices=[3])
            @test has_path(g, 1, 5; exclude_vertices=[4])
            @test !has_path(g, 1, 5; exclude_vertices=[3, 4])
            @test has_path(g, 5, 1)
            @test has_path(g, 5, 1; exclude_vertices=[3])
            @test has_path(g, 5, 1; exclude_vertices=[4])
            @test !has_path(g, 5, 1; exclude_vertices=[3, 4])

            # Edge cases
            @test !has_path(g, 1, 6)
            @test !has_path(g, 6, 1)
            @test has_path(g, 1, 1) # inseparable
            @test !has_path(g, 1, 2; exclude_vertices=[2])
            @test !has_path(g, 1, 2; exclude_vertices=[1])
        end
    end
    @testset "visited_vertices" begin
        gt = binary_tree(3)
        for g in testgraphs(gt)
            @test LT.visited_vertices(g, 1, LT.BreadthFirst()) == 1:7
        end
    end
end
