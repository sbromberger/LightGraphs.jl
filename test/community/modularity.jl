@testset "Modularity" begin
    n = 10
    m = n*(n-1)/2
    c = ones(Int, n)
    gint = CompleteGraph(n)
    for g in testgraphs(gint)
      @test @inferred(modularity(g, c)) == 0
    end

    gint = Graph(n)
    for g in testgraphs(gint)
      @test @inferred(modularity(g, c)) == 0
    end
end
