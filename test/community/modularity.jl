@testset "Modularity" begin
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

    n = 6
    gint = SimpleGraph(n)
    add_edge!(gint, 1, 2)
    add_edge!(gint, 2, 3)
    add_edge!(gint, 3, 1)
    add_edge!(gint, 3, 4)
    add_edge!(gint, 4, 5)
    add_edge!(gint, 5, 6)
    add_edge!(gint, 6, 4)
    c = [1, 1, 1, 2, 2, 2]

    for g in testgraphs(gint)
        @test isapprox(modularity(g, c), 0.35714285714285715, atol=1e-3)
        @test isapprox(modularity(g, c, 0.5), 0.6071428571428571, atol=1e-3)
    end
end
