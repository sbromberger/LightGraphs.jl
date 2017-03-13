using LightGraphs
using Base.Test

g = Graph(8)

@testset "Max adj visit" begin
    # Test of Min-Cut and maximum adjacency visit
    # Original example by Stoer

    wedges = [
        (1, 2, 2.),
        (1, 5, 3.),
        (2, 3, 3.),
        (2, 5, 2.),
        (2, 6, 2.),
        (3, 4, 4.),
        (3, 7, 2.),
        (4, 7, 2.),
        (4, 8, 2.),
        (5, 6, 3.),
        (6, 7, 1.),
        (7, 8, 3.) ]


    m = length(wedges)
    eweights = spzeros(nv(g),nv(g))

    for (s, d, w) in wedges
        add_edge!(g, s, d)
        eweights[s, d] = w
        eweights[d, s] = w
    end

    @test nv(g) == 8
    @test ne(g) == m

    parity, bestcut = mincut(g, eweights)

    @test length(parity) == 8
    @test parity == [2, 2, 1, 1, 2, 2, 1, 1]
    @test bestcut == 4.0

    parity, bestcut = mincut(g)

    @test length(parity) == 8
    @test parity == [2, 1, 1, 1, 1, 1, 1, 1]
    @test bestcut == 2.0

    v = maximum_adjacency_visit(g)

    @test v == Vector{Int64}([1, 2, 5, 6, 3, 7, 4, 8])
end
