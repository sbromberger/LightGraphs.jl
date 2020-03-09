@testset "Random Vertex Cover" begin

    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        @test isempty(c)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        @test isempty(c)
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        @test c == [1,]
    end

    g3 = star_graph(5)
    for g in testgraphs(g3)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        @test (length(c)== 2 && (c[1] == 1 || c[2] == 1))
    end

    g4 = complete_graph(5)
    for g in testgraphs(g4)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        @test length(c)== 4 #All except one vertex
    end

    g5 = path_graph(5)
    for g in testgraphs(g5)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        c = @inferred(vertex_cover(g, RandomVertexCover(); seed=3))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 3, 4, 5] || c == [2, 3, 4] || c == [2, 3, 4, 5])
    end
end
