@testset "Degree" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    for g in testdigraphs(g5)
        @test @inferred(centrality(g, Degree())) == [0.6666666666666666, 0.6666666666666666, 1.0, 0.3333333333333333]
        @test @inferred(centrality(g, Degree(degreefn=indegree, normalize=false))) == [0.0, 1.0, 2.0, 1.0]
        @test @inferred(centrality(g, Degree(degreefn=outdegree, normalize=false))) == [2.0, 1.0, 1.0, 0.0]
    end
end
