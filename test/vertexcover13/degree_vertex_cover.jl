@testset "Degree Vertex Cover" begin

    g3 = star_graph(5)
    for g in testgraphs(g3)
        c = @inferred(vertex_cover(g, DegreeVertexCover()))
        @test c == [1]
    end

    g4 = complete_graph(5)
    for g in testgraphs(g4)
        c = @inferred(vertex_cover(g, DegreeVertexCover()))
        @test length(c) == 4 #All except one vertex
    end

    #path_graph(5) with additional edge 2-5
    g5 = Graph([0 1 0 0 0; 1 0 1 0 1; 0 1 0 1 0; 0 0 1 0 1; 0 1 0 1 0])
    for g in testgraphs(g5)
        c = @inferred(vertex_cover(g, DegreeVertexCover()))
        @test sort(c) == [2, 4]
    end
end
