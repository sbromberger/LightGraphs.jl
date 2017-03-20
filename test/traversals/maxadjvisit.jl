
@testset "Max adj visit" begin
    gx = Graph(8)

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
    eweights = spzeros(nv(gx),nv(gx))

    for (s, d, w) in wedges
        add_edge!(gx, s, d)
        eweights[s, d] = w
        eweights[d, s] = w
    end
    for g in testgraphs(gx)
      @test @inferred(nv(g)) == 8
      @test @inferred(ne(g)) == m

      parity, bestcut = mincut(g, eweights)

      @test @inferred(length(parity)) == 8
      @test @inferred(parity) == [2, 2, 1, 1, 2, 2, 1, 1]
      @test @inferred(bestcut) == 4.0

      parity, bestcut = mincut(g)

      @test @inferred(length(parity)) == 8
      @test @inferred(parity) == [2, 1, 1, 1, 1, 1, 1, 1]
      @test @inferred(bestcut) == 2.0

      v = maximum_adjacency_visit(g)

      @test v == Vector{Int64}([1, 2, 5, 6, 3, 7, 4, 8])
    end
end
