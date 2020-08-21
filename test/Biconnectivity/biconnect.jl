@testset "Biconnect" begin
    gint = SimpleGraph(12)
    add_edge!(gint, 1, 2)
    add_edge!(gint, 2, 3)
    add_edge!(gint, 2, 4)
    add_edge!(gint, 3, 4)
    add_edge!(gint, 3, 5)
    add_edge!(gint, 4, 5)
    add_edge!(gint, 2, 6)
    add_edge!(gint, 1, 7)
    add_edge!(gint, 6, 7)
    add_edge!(gint, 6, 8)
    add_edge!(gint, 6, 9)
    add_edge!(gint, 8, 9)
    add_edge!(gint, 9, 10)
    add_edge!(gint, 11, 12)

    a = [[SimpleEdge(3, 5), SimpleEdge(4, 5), SimpleEdge(2, 4), SimpleEdge(3, 4), SimpleEdge(2, 3)],
         [SimpleEdge(9, 10)],
         [SimpleEdge(6, 9), SimpleEdge(8, 9), SimpleEdge(6, 8)],
         [SimpleEdge(1, 7), SimpleEdge(6, 7), SimpleEdge(2, 6), SimpleEdge(1, 2)],
         [SimpleEdge(11, 12)]]

    for g in testgraphs(gint)
        bcc = @inferred(LBC.biconnected_components(g))
        @test bcc == a
        @test typeof(bcc) === Vector{Vector{SimpleEdge{eltype(g)}}}
    end

    g = SimpleGraph(4)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 1, 4)

    h = SimpleGraph(4)
    add_edge!(h, 1, 2)
    add_edge!(h, 2, 3)
    add_edge!(h, 3, 4)
    add_edge!(h, 1, 4)

    gint = blockdiag(g, h)
    add_edge!(gint, 4, 5)

    a = [[SimpleEdge(5, 8), SimpleEdge(7, 8), SimpleEdge(6, 7), SimpleEdge(5, 6)], [SimpleEdge(4, 5)], [SimpleEdge(1, 4), SimpleEdge(3, 4), SimpleEdge(2, 3), SimpleEdge(1, 2)]]

    for g in testgraphs(gint)
        bcc = @inferred(LBC.biconnected_components(g))
        @test bcc == a
        @test typeof(bcc) === Vector{Vector{SimpleEdge{eltype(g)}}}
    end

    gx = Graph(4)
    add_edge!(gx, 1, 2)
    add_edge!(gx, 2, 3)
    add_edge!(gx, 3, 4)
    add_edge!(gx, 1, 4)
    add_edge!(gx, 2, 4)
    a = [[SimpleEdge(2, 4), SimpleEdge(1, 4), SimpleEdge(3, 4), SimpleEdge(2, 3), SimpleEdge(1, 2)]]
    for g in testgraphs(gx)
        bcc = @inferred(LBC.biconnected_components(g))
        @test bcc == a
        @test typeof(bcc) === Vector{Vector{SimpleEdge{eltype(g)}}}
    end
end
