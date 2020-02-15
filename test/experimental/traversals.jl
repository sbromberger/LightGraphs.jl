using LightGraphs.Experimental.Traversals
const LET = LightGraphs.Experimental.Traversals
@testset "Traversals" begin
    g1= smallgraph(:house)

    dg1 = path_digraph(6)
    add_edge!(dg1, 2, 6)

    b1 = LET.BFS()
    @test b1 == LET.BFS(LET.NOOPSort)

    b2 = LET.BFS(QuickSort)

    @testset "BFS" begin
        for g in testgraphs(g1)
            v1 = @inferred LET.visited_vertices(g, 3, b1)
            v2 = @inferred LET.visited_vertices(g, 3, b2)
            v3 = @inferred LET.visited_vertices(g, [3], b1)
            @test v1 == v2 == v3 == [3, 1, 4, 5, 2]
            @test (@inferred LET.parents(g, 2, b1)) == LET.parents(g, 2, b2) == [2, 0, 1, 2, 4]
            @test (@inferred LET.distances(g, 1, b1)) == LET.distances(g, 1, b2) == 
                LET.distances(g, [1], b1) == [0, 1, 1, 2, 2]
        end
        for dg in testgraphs(dg1)
            v1 = @inferred LET.visited_vertices(dg, 1, b1)
            v2 = @inferred LET.visited_vertices(dg, 1, b2)
            v3 = @inferred LET.visited_vertices(dg, [1], b1)
            @test v1 == v2 == v3 == [1, 2, 3, 6, 4, 5]
            @test (@inferred LET.parents(dg, 2, b1)) == LET.parents(dg, 2, b2) == [0, 0, 2, 3, 4, 2]
            @test (@inferred LET.distances(dg, 1, b1)) == LET.distances(dg, 1, b2) ==
                LET.distances(dg, [1], b1) == [0, 1, 2, 3, 4, 2]
        end
    end
end

