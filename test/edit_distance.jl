@testset "Edit distance" begin

    triangle = random_regular_graph(3,2)
    quadrangle = random_regular_graph(4,2)
    pentagon = random_regular_graph(5,2)

    d, λ = edit_distance(triangle, quadrangle, subst_cost=MinkowskiCost(1:3,1:4))
    @test d == 1.0
    @test λ == Tuple[(1,1),(2,2),(3,3),(0,4)]

    d, λ = edit_distance(quadrangle, triangle, subst_cost=MinkowskiCost(1:4,1:3))
    @test d == 1.0
    @test λ == Tuple[(1,1),(2,2),(3,3),(4,0)]

    d, λ = edit_distance(triangle, pentagon, subst_cost=MinkowskiCost(1:3,1:5))
    @test d == 2.0
    @test λ == Tuple[(1,1),(2,2),(3,3),(0,4),(0,5)]

    d, λ = edit_distance(pentagon, triangle, subst_cost=MinkowskiCost(1:5,1:3))
    @test d == 2.0
    @test λ == Tuple[(1,1),(2,2),(3,3),(4,0),(5,0)]

    cost = MinkowskiCost(1:3,1:3)
    bcost = BoundedMinkowskiCost(1:3,1:3)
    for i=1:3
      @test cost(i,i) == 0.
      @test bcost(i,i) == 2/3
    end

    g1 = CompleteGraph(4)
    g2 = CompleteGraph(4)
    rem_edge!(g2, 1, 2)
    d, λ = edit_distance(g1, g2)
    @test d == 2.0
    @test λ == Tuple[(1,1),(2,2),(3,3),(4,4)]
    
end
