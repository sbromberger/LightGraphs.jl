@testset "Edit distance" begin

    gtri = random_regular_graph(3, 2)
    gquad = random_regular_graph(4, 2)
    gpent = random_regular_graph(5, 2)

    for triangle in testgraphs(gtri), quadrangle in testgraphs(gquad), pentagon in testgraphs(gpent)
        d, λ = @inferred(edit_distance(triangle, quadrangle, subst_cost=MinkowskiCost(1:3, 1:4)))
        @test d == 1.0
        @test λ == Tuple[(1, 1), (2, 2), (3, 3), (0, 4)]

        d, λ = @inferred(edit_distance(quadrangle, triangle, subst_cost=MinkowskiCost(1:4, 1:3)))
        @test d == 1.0
        @test λ == Tuple[(1, 1), (2, 2), (3, 3), (4, 0)]

        d, λ = @inferred(edit_distance(triangle, pentagon, subst_cost=MinkowskiCost(1:3, 1:5)))
        @test d == 2.0
        @test λ == Tuple[(1, 1), (2, 2), (3, 3), (0, 4), (0, 5)]

        d, λ = @inferred(edit_distance(pentagon, triangle, subst_cost=MinkowskiCost(1:5, 1:3)))
        @test d == 2.0
        @test λ == Tuple[(1, 1), (2, 2), (3, 3), (4, 0), (5, 0)]
    end
    cost = @inferred(MinkowskiCost(1:3, 1:3))
    bcost = @inferred(BoundedMinkowskiCost(1:3, 1:3))
    for i = 1:3
      @test cost(i, i) == 0.
      @test bcost(i, i) == 2 / 3
    end

    g1c = CompleteGraph(4)
    g2c = CompleteGraph(4)
    rem_edge!(g2c, 1, 2)
    for g1 in testgraphs(g1c), g2 in testgraphs(g2c)
        d, λ = @inferred(edit_distance(g1, g2))
        @test d == 2.0
        @test λ == Tuple[(1, 1), (2, 2), (3, 3), (4, 4)]
    end
end
