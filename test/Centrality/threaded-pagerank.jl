@testset "ThreadedPagerank" begin
    function dense_pagerank_solver(g::AbstractGraph, α=0.85::Real)
        p = fill(1 / nv(g), nv(g))
        danglingnodes = outdegree(g) .== 0
        M = Matrix{Float64}(adjacency_matrix(g))
        M = M'
        M[:, danglingnodes] .= sum(danglingnodes) ./ nv(g)
        M = M * Diagonal(1 ./ sum(M, dims=1)[:])
        @assert all(1.01 .>= sum(M, dims=1) .>= 0.999)
       # v = inv(I-β*M) * ((1-β)/nv(g) * ones(nv(g), 1))
        v = inv(I - α * M) * ((1 - α) / nv(g) * ones(nv(g), 1))
        return v
    end

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    g6 = SimpleGraph(4)
    add_edge!(g6, 1, 2); add_edge!(g6, 2, 3); add_edge!(g6, 1, 3); add_edge!(g6, 3, 4)
    for α in [0.75, 0.85]

        for g in testdigraphs(g5)
            @test LCENT.centrality(g, LCENT.ThreadedPageRank())[3] ≈ 0.318 atol = 0.001
            @test length(@inferred(LCENT.centrality(g, LCENT.ThreadedPageRank()))) == nv(g)
            @test_throws LCENT.ConvergenceError LCENT.centrality(g, LCENT.ThreadedPageRank(α=2))
            @test_throws LCENT.ConvergenceError LCENT.centrality(g, LCENT.ThreadedPageRank(α=α, n=2))
            @test isapprox(LCENT.centrality(g, LCENT.ThreadedPageRank(α=α)), dense_pagerank_solver(g, α), atol=0.001)
        end

        for g in testgraphs(g6)
            @test length(@inferred(LCENT.centrality(g, LCENT.ThreadedPageRank()))) == nv(g)
            @test_throws LCENT.ConvergenceError LCENT.centrality(g, LCENT.ThreadedPageRank(α=2))
            @test_throws LCENT.ConvergenceError LCENT.centrality(g, LCENT.ThreadedPageRank(α=α, n=2))
            @test isapprox(LCENT.centrality(g, LCENT.ThreadedPageRank(α=α)), dense_pagerank_solver(g, α), atol=0.001)
        end
    end
end
