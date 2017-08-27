@testset "Normalized Cut" begin

    g = SimpleWeightedGraph(4)
    add_edge!(g, 1, 2, 1)
    add_edge!(g, 3, 4, 1)

    labels = ncut(g.weights, 0.1)

    @test labels == [1, 1, 2, 2] || labels == [2, 2, 1, 1]

    g = SimpleWeightedGraph(6)
    add_edge!(g, 1, 2, 1)
    add_edge!(g, 2, 3, 1)
    add_edge!(g, 1, 3, 1)
    add_edge!(g, 4, 5, 1)
    add_edge!(g, 4, 6, 1)
    add_edge!(g, 5, 6, 1)
    add_edge!(g, 1, 6, 0.1)
    add_edge!(g, 3, 4, 0.2)

    labels = ncut(g.weights, 0.1)

    @test labels == [1, 1, 1, 2, 2, 2] || labels == [2, 2, 2, 1, 1, 1]
end