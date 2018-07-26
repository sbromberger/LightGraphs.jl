using Random: MersenneTwister, randperm


# helper function that permutates the vertices of a graph
function shuffle_vertices(g::AbstractGraph, σ)
    G = typeof(g)
    gperm = G(nv(g))
    n = nv(g)
    for e in edges(g)
        add_edge!(gperm, σ[src(e)], σ[dst(e)])
    end
    return gperm
end

# all (up to isomorphism) 3-regular, connected graphs on 8 vertices
# list taken from https://en.wikipedia.org/wiki/Table_of_simple_cubic_graphs#4_vertices
cubic_graphs = [SimpleGraph(Edge.([(1,2), (1,3), (1,8), (2,3), (2,4), (3,4),
                                   (4,5), (5,6), (5,7), (6,7), (6,8), (7,8)])),
                SimpleGraph(Edge.([(1,2), (1,3), (1,8), (2,3), (2,5), (3,4),
                                   (4,5), (4,7), (5,6), (6,7), (6,8), (7,8)])),
                SimpleGraph(Edge.([(1,2), (1,3), (1,8), (2,3), (2,6), (3,4),
                                   (4,5), (4,7), (5,6), (5,8), (6,7), (7,8)])),
                Grid([2,2,2]),
                SimpleGraph(Edge.([(1,2), (1,5), (1,8), (2,3), (2,6), (3,4),
                                   (3,7), (4,5), (4,8), (5,6), (6,7), (7,8)]))
               ]
# vertex permutated versions of cubic_graphs
cubic_graphs_perm = []
global rng = MersenneTwister(1)
for i = 1:length(cubic_graphs)
    push!(cubic_graphs_perm, shuffle_vertices(cubic_graphs[i], randperm(rng, 8)))
end

@testset "Isomorphism" begin
    @test has_iso(Grid([2,3]), Grid([3,2]))

    # the cubic graphs should only be isomorph to themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs)
        @test (i == j) == has_iso(cubic_graphs[i], cubic_graphs[j])
        @test (i == j) == has_subgraphiso(cubic_graphs[i], cubic_graphs[j])
        @test (i == j) == has_induced_subgraphiso(cubic_graphs[i], cubic_graphs[j])
    end

    # the cubic graphs should only be isomorph a permutation of themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs_perm)
        @test (i == j) == has_iso(cubic_graphs[i], cubic_graphs_perm[j])
        @test (i == j) == has_subgraphiso(cubic_graphs[i], cubic_graphs_perm[j])
        @test (i == j) == has_induced_subgraphiso(cubic_graphs[i], cubic_graphs_perm[j])
    end

    # count_iso, count_subgraphiso and count_induced_subgraphiso are commutative
    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        @test count_iso(g1, g1) == count_iso(g1, g2) == count_iso(g2, g1) == count_iso(g2,g2)
        @test count_subgraphiso(g1, g1) == count_subgraphiso(g1, g2) == 
                   count_subgraphiso(g2, g1) == count_subgraphiso(g2,g2)
        @test count_induced_subgraphiso(g1, g1) == count_subgraphiso(g1, g2) == 
                   count_subgraphiso(g2, g1) == count_subgraphiso(g2,g2)
    end

    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        length(collect(all_iso(g1, g1))) == count_iso(g1, g2)
        length(collect(all_subgraphiso(g1, g1))) == count_iso(g1, g2)
        length(collect(all_induced_subgraphiso(g1, g1))) == count_iso(g1, g2)
    end

    # The frucht-graph is a 3-regular graph that has only one automorphism
    g = smallgraph(:frucht)
    rng = MersenneTwister(1)
    perm = randperm(rng, 12)
    g2 = shuffle_vertices(g, perm)
    perm_reconstructed = map(uv -> first(uv), first(all_iso(g2, g))) 
    @test perm == perm_reconstructed

    # TODO better tests for vertex_relation and edge_relation
    vrel(u, v) = false
    erel(e1, e2) = false
    @test has_iso(CompleteGraph(4), CompleteGraph(4), vertex_relation=vrel) == false
    @test has_iso(CompleteGraph(4), CompleteGraph(4), edge_relation=erel) == false
    @test has_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel) == false
    @test has_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel) == false
    @test has_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel) == false
    @test has_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel) == false

    @test count_iso(CompleteGraph(4), CompleteGraph(4), vertex_relation=vrel) == 0
    @test count_iso(CompleteGraph(4), CompleteGraph(4), edge_relation=erel) == 0
    @test count_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel) == 0
    @test count_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel) == 0
    @test count_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel) == 0
    @test count_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel) == 0

    @test isempty(all_iso(CompleteGraph(4), CompleteGraph(4), vertex_relation=vrel))
    @test isempty(all_iso(CompleteGraph(4), CompleteGraph(4), edge_relation=erel))
    @test isempty(all_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel))
    @test isempty(all_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel))
    @test isempty(all_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), vertex_relation=vrel))
    @test isempty(all_induced_subgraphiso(CompleteGraph(4), CompleteGraph(3), edge_relation=erel))

    # this tests triggers the shortcut in the vf2 algorithm if the first graph is smaller than the second one
    @test has_iso(CompleteGraph(3), CompleteGraph(4)) == false

    # this test is mainly to cover a certain branch of vf2
    # TODO cover directed graphs better
    gd = SimpleDiGraph(Edge.([(2,1)]))
    @test has_iso(gd, gd, alg=:vf2) == true

    # Tests for when the argument alg is not some valid value
    @test_throws ArgumentError has_iso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError count_iso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError all_iso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError has_subgraphiso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError count_subgraphiso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError all_subgraphiso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError has_induced_subgraphiso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError count_induced_subgraphiso(g, g, alg=:some_nonsense)
    @test_throws ArgumentError all_induced_subgraphiso(g, g, alg=:some_nonsense)

    # Test if vf2 returns an error if a graph has self-loops
    # TODO remove when vf2 can handle self-loops
    gs = SimpleGraph(1)
    add_edge!(gs, 1, 1)
    @test_throws ArgumentError has_iso(gs, gs, alg=:vf2)

end
