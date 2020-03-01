@testset "Parallel.Random Vertex Cover" begin

    g0 = SimpleGraph(0)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g0)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test isempty(c)
        end
    end

    g1 = SimpleGraph(1)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g1)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test isempty(c)
        end
    end

    add_edge!(g1, 1, 1)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g1)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test c == [1,]
        end
    end

    g3 = star_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g3)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test (length(c)== 2 && (c[1] == 1 || c[2] == 1))
        end
    end
    
    g4 = complete_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g4)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            @test length(c)== 4 #All except one vertex 
        end
    end

    g5 = path_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            sort!(c)
            @test (c == [1, 2, 3, 4] || c == [1, 2, 4, 5] || c == [2, 3, 4, 5])
        end
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            c = @inferred(Parallel.vertex_cover(g, 4, RandomVertexCover(); parallel=parallel))
            sort!(c)
            @test (c == [1, 2, 3, 4] || c == [1, 2, 3, 4, 5] || c == [2, 3, 4] || c == [2, 3, 4, 5])
        end
    end
end
