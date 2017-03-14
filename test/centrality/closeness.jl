@testset "Closeness" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
    y = closeness_centrality(g5; normalize=false)
    z = closeness_centrality(g5)

    @test y == [0.75, 0.6666666666666666, 1.0, 0.0]
    @test z == [0.75, 0.4444444444444444, 0.3333333333333333, 0.0]

    g = Graph(5)
    add_edge!(g,1,2)
    z = closeness_centrality(g)
    @test z[1] == z[2] == 0.25
    @test z[3] == z[4] == z[5] == 0.0
end
