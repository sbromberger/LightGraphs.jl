@testset "Eigenvector" begin
    @testset "house graph" begin
        g1 = smallgraph(:house)
        @testset "$g" for g in testgraphs(g1)
            y = @inferred(eigenvector_centrality(g))
            @test round.(y, digits = 3) ==
                  round.(
                [
                    0.3577513877490464,
                    0.3577513877490464,
                    0.5298987782873977,
                    0.5298987782873977,
                    0.4271328349194304,
                ],
                digits = 3,
            )
        end
    end

    @testset "cycle digraph" begin
        g2 = cycle_digraph(4)
        @testset "$g" for g in testdigraphs(g2)
            y = @inferred(eigenvector_centrality(g))
            @test round.(y, digits = 3) == round.([0.5, 0.5, 0.5, 0.5], digits = 3)
        end
    end
end
