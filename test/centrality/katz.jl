@testset "Katz" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
    for g in (g5, DiGraph{UInt8}(g5), DiGraph{Int16}(g5))
        z = katz_centrality(g, 0.4)
        @test round(z, 2) == [0.32, 0.44, 0.62, 0.56]
    end
end
