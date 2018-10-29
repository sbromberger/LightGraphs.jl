@testset "Modularity" begin
    #
    # undirected test cases 
    #
    n = 10
    m = n * (n - 1) / 2
    c = ones(Int, n)
    gint = CompleteGraph(n)
    for g in testgraphs(gint)
      @test @inferred(modularity(g, c)) == 0
    end

    gint = SimpleGraph(n)
    for g in testgraphs(gint)
      @test @inferred(modularity(g, c)) == 0
    end

    barbell = blockdiag(CompleteGraph(3), CompleteGraph(3))
    add_edge!(barbell, 1, 4)
    c = [1, 1, 1, 2, 2, 2]

    for g in testgraphs(barbell)
        Q1 = @inferred(modularity(g, c))
        @test isapprox(Q1, 0.35714285714285715, atol=1e-3)
        Q2 = @inferred(modularity(g, c, 0.5))
        @test isapprox(Q2, 0.6071428571428571, atol=1e-3)
    end

    #
    # directed test cases 
    #
    triangle = SimpleDiGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4)
    c = [1, 1, 1, 2, 2, 2]

    for g in testdigraphs(barbell)
        Q1 = @inferred(modularity(g, c))
        @test isapprox(Q1, 0.3673469387755103, atol=1e-3)

        Q2 = @inferred(modularity(barbell, c, 0.5))
        @test isapprox(Q2, 0.6122448979591837, atol=1e-3)
    end

    add_edge!(barbell, 4, 1)
    for g in testdigraphs(barbell)
        @test @inferred(modularity(g, c)) == 0.25
    end
end
