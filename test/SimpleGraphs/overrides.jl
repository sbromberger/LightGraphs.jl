pgen = SGGEN.Path(5)
g4 = SimpleDiGraph(pgen)
@testset "overrides: reverse!" begin
    re1 = SG.SimpleEdge(2, 1)
    gr = @inferred(reverse(g4))
    @testset "Reverse $g" for g in testdigraphs(gr)
        T = eltype(g)
        @test re1 in edges(g)
        @inferred(reverse!(g))
        @test g == SimpleDiGraph{T}(g4)
    end
end
