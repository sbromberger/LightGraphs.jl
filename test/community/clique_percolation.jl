@testset "Clique percolation" begin
    function setofsets(array_of_arrays)
        Set(map(Set, array_of_arrays))
    end

    function test_cliques(graph, expected)
        # Make test results insensitive to ordering
        Set(clique_percolation(graph)) == setofsets(expected)
    end

    g = Graph(5)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 1)
    add_edge!(g, 1, 4)
    add_edge!(g, 4, 5)
    add_edge!(g, 5, 1)
    @test test_cliques(g, Array[[1, 2, 3], [1, 4, 5]])
end
