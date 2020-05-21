@testset "Katz" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    @testset "$g" for g in testdigraphs(g5)
        z = @inferred(LCENT.centrality(g, LCENT.Katz(α=0.4)))
        @test round.(z, digits=2) == [0.32, 0.44, 0.62, 0.56]
    end
    
    A = [
            0.00 0.24 0.44 0.64 0.84;
            0.08 0.00 0.48 0.68 0.88;
            0.12 0.32 0.00 0.72 0.92;
            0.16 0.36 0.56 0.00 0.96;
            0.20 0.40 0.60 0.80 0.00;
        ]

    @testset "weighted Katz" begin
        g = SimpleDiGraph(A)

        results = [
                   [1.075051 1.172686 1.265867 1.354891 1.440030],
                   [1.213834 1.481742 1.726354 1.950582 2.156872],
                   [1.517035 2.143117 2.691209 3.175030 3.605258],
                   [2.552494 4.374501 5.906917 7.213701 8.341269]
                  ]
        for (i, α) in enumerate(0.1:0.1:0.4)
            z = @inferred(LCENT.centrality(g, A, LCENT.Katz(α=α, normalize=false)))
            @test isapprox(z, results[i]', atol=1e-4)
        end
    end
end
