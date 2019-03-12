@testset "MatrixOrdering" begin
    g = SimpleGraph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 1, 3)
    add_edge!(g, 5, 6)
    add_edge!(g, 4, 6)
    resultant_perm = [5, 6, 4, 3, 1, 2]
    for gx in testgraphs(g)
        z = @inferred(rcm_vertex_permutation(g))
        @test z == resultant_perm
    end
end
