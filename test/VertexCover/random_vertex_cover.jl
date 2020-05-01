@testset "Random Vertex Cover" begin

    rng = MersenneTwister(3)
    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover(rng=rng)))
        @test isempty(c)
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        @test isempty(c)
    end

    add_edge!(g1, 1, 1)
    for g in testgraphs(g1)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        @test c == [1,]
    end

    g3 = SimpleGraph(LGGEN.Star(5))
    for g in testgraphs(g3)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        @test (length(c)== 2 && (c[1] == 1 || c[2] == 1))
    end

    g4 = SimpleGraph(LGGEN.Complete(5))
    for g in testgraphs(g4)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        @test length(c)== 4 #All except one vertex
    end

    g5 = SimpleGraph(LGGEN.Path(5))
    for g in testgraphs(g5)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for g in testgraphs(g5)
        c = @inferred(LGVC.vertex_cover(g, LGVC.RandomVertexCover()))
        sort!(c)
        @test (c == [1, 2, 3, 4] || c == [1, 2, 3, 4, 5] || c == [2, 3, 4] || c == [2, 3, 4, 5])
    end
end
