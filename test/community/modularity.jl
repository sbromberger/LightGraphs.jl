@testset "Modularity" begin
    
    # 1. undirected test cases 
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
        Q2 = @inferred(modularity(g, c, γ=0.5))
        @test isapprox(Q2, 0.6071428571428571, atol=1e-3)
    end

    # 2. directed test cases 
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

        Q2 = @inferred(modularity(barbell, c, γ=0.5))
        @test isapprox(Q2, 0.6122448979591837, atol=1e-3)
    end

    add_edge!(barbell, 4, 1)
    for g in testdigraphs(barbell)
        @test @inferred(modularity(g, c)) == 0.25
    end

    # 3. weighted test cases 
    # 3.1. undirected and weighted test cases
    triangle = SimpleGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4) # this edge has a weight of 5
    c = [1, 1, 1, 2, 2, 2]
    d = [[0  1  1  5  0  0]
         [1  0  1  0  0  0]
         [1  1  0  0  0  0]
         [5  0  0  0  1  1]
         [0  0  0  1  0  1]
         [0  0  0  1  1  0]]
    for g in testgraphs(barbell)
        Q = @inferred(modularity(g, c, distmx=d))
        @test isapprox(Q, 0.045454545454545456, atol=1e-3)
    end

    # 3.2. directed and weighted test cases
    triangle = SimpleDiGraph(3)
    add_edge!(triangle, 1, 2)
    add_edge!(triangle, 2, 3)
    add_edge!(triangle, 3, 1)

    barbell = blockdiag(triangle, triangle)
    add_edge!(barbell, 1, 4) # this edge has a weight of 5
    c = [1, 1, 1, 2, 2, 2]
    d = [[0  1  0  5  0  0]
         [0  0  1  0  0  0]
         [1  0  0  0  0  0]
         [0  0  0  0  1  0]
         [0  0  0  0  0  1]
         [0  0  0  1  0  0]]
    for g in testdigraphs(barbell)
        Q = @inferred(modularity(g, c, distmx=d))
        @test isapprox(Q, 0.1487603305785124, atol=1e-3)
    end
end
