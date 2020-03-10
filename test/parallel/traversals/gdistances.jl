@testset "Parallel.BFS" begin


    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2)
    add_edge!(g5, 2, 3)
    add_edge!(g5, 1, 3)
    add_edge!(g5, 3, 4)

    for g in testdigraphs(g5)
        vert_level = zeros(eltype(g), nv(g))
        @test @inferred(Parallel.gdistances(g, 1)) ==
        Parallel.gdistances!(g, 1, vert_level) ==
        gdistances(g, 1)
        vert_level = zeros(eltype(g), nv(g))
        @test @inferred(Parallel.gdistances(g, [1, 3])) ==
        Parallel.gdistances!(g, [1, 3], vert_level) ==
        gdistances(g, [1, 3])
    end

    g6 = smallgraph(:house)

    for g in testgraphs(g6)
        @test @inferred(Parallel.gdistances(g, 2)) == gdistances(g, 2)
        @test @inferred(Parallel.gdistances(g, [1, 2])) == gdistances(g, [1, 2])
    end

end
