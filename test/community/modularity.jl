@testset "Modularity" begin
    n = 10
    m = n*(n-1)/2
    c = ones(Int, n)
    gint = CompleteGraph(n)
    for g in (gint, Graph{UInt8}(gint), Graph{Int16}(gint))
      @test  modularity(g, c) == 0
    end

    gint = Graph(n)
    for g in (gint, Graph{UInt8}(gint), Graph{Int16}(gint))
      @test modularity(g, c) == 0
    end
end
