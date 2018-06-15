@testset "Bipartiteness" begin
    g6 = smallgraph(:house)
    for g in testgraphs(g6)
        @test @inferred(!is_bipartite(g))
    end

    gx = SimpleGraph(5)
    add_edge!(gx, 1, 2); add_edge!(gx, 1, 4)
    add_edge!(gx, 2, 3); add_edge!(gx, 2, 5)
    add_edge!(gx, 3, 4)

    for g in testgraphs(gx)
        @test @inferred(is_bipartite(g))
    end

    g10 = CompleteGraph(10)
    for g in testgraphs(g10)
        @test @inferred(bipartite_map(g)) == Vector{eltype(g)}()
    end

    g10 = CompleteBipartiteGraph(10, 10)
    for g in testgraphs(g10)
        T = eltype(g)
        @test @inferred(bipartite_map(g)) == Vector{T}([ones(T, 10); 2 * ones(T, 10)])

        h = blockdiag(g, g)
        @test @inferred(bipartite_map(h)) == Vector{T}([ones(T, 10); 2 * ones(T, 10); ones(T, 10); 2 * ones(T, 10)])
    end

    g2 = CompleteGraph(2)
    for g in testgraphs(g2)
        @test @inferred(bipartite_map(g)) == Vector{eltype(g)}([1, 2])
    end

    g2 = Graph(2)
    for g in testgraphs(g2)
        @test @inferred(bipartite_map(g)) == Vector{eltype(g)}([1, 1])
    end

    g2 = DiGraph(2)
    for g in testdigraphs(g2)
        @test @inferred(bipartite_map(g)) == Vector{eltype(g)}([1, 1])
    end

    g2 = PathDiGraph(2)
    for g in testdigraphs(g2)
        @test @inferred(bipartite_map(g)) == Vector{eltype(g)}([1, 2])
    end
end
