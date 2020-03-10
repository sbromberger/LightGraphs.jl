@testset "Bipartiteness" begin
    g6 = smallgraph(:house)
    @testset "$g" for g in testgraphs(g6)
        @test @inferred(!LT.is_bipartite(g))
    end

    gx = SimpleGraph(5)
    add_edge!(gx, 1, 2)
    add_edge!(gx, 1, 4)
    add_edge!(gx, 2, 3)
    add_edge!(gx, 2, 5)
    add_edge!(gx, 3, 4)

    for g in testgraphs(gx)
        @test @inferred(LT.is_bipartite(g))
    end
    g10 = SimpleDiGraph(4)
    add_edge!(g10, 1, 3)
    add_edge!(g10, 2, 4)
    @testset "$g" for g in testdigraphs(g10)
        @test @inferred(LT.is_bipartite(g))
    end

    add_edge!(g10, 1, 4)
    @testset "$g" for g in testdigraphs(g10)
        @test @inferred(LT.is_bipartite(g))
    end

    g10 = SimpleDiGraph(20)
    @testset "$g" for g in testdigraphs(g10)
        gc = copy(g)
        for m = 1:50
            i = rand(1:10)
            j = rand(11:20)
            if rand() < 0.5
                i, j = j, i
            end
            if !has_edge(gc, i, j)
                add_edge!(gc, i, j)
                @test @inferred(LT.is_bipartite(gc))
            end
        end
    end

    g10 = complete_graph(10)
    for g in testgraphs(g10)
        @test @inferred(LT.bipartite_map(g)) == Vector{eltype(g)}()
    end

    g10 = complete_bipartite_graph(10, 10)
    for g in testgraphs(g10)
        T = eltype(g)
        @test @inferred(LT.bipartite_map(g)) == Vector{T}([ones(T, 10); 2 * ones(T, 10)])

        h = blockdiag(g, g)
        @test @inferred(LT.bipartite_map(h)) ==
              Vector{T}([ones(T, 10); 2 * ones(T, 10); ones(T, 10); 2 * ones(T, 10)])
    end

    g2 = complete_graph(2)
    for g in testgraphs(g2)
        @test @inferred(LT.bipartite_map(g)) == Vector{eltype(g)}([1, 2])
    end

    g2 = Graph(2)
    for g in testgraphs(g2)
        @test @inferred(LT.bipartite_map(g)) == Vector{eltype(g)}([1, 1])
    end

    g2 = DiGraph(2)
    for g in testdigraphs(g2)
        @test @inferred(LT.bipartite_map(g)) == Vector{eltype(g)}([1, 1])
    end

    g2 = path_digraph(2)
    for g in testdigraphs(g2)
        @test @inferred(LT.bipartite_map(g)) == Vector{eltype(g)}([1, 2])
    end
end
