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
                grid([2,2,2]),
                SimpleGraph(Edge.([(1,2), (1,5), (1,8), (2,3), (2,6), (3,4),
                                   (3,7), (4,5), (4,8), (5,6), (6,7), (7,8)]))
               ]
# vertex permutated versions of cubic_graphs
cubic_graphs_perm = []
_rng = MersenneTwister(1)
for i = 1:length(cubic_graphs)
    push!(cubic_graphs_perm, shuffle_vertices(cubic_graphs[i], randperm(_rng, 8)))
end

@testset "Isomorphism" begin
    @test has_isomorph(grid([2,3]), grid([3,2]))

    # the cubic graphs should only be isomorph to themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs)
        @test (i == j) == has_isomorph(cubic_graphs[i], cubic_graphs[j])
        @test (i == j) == has_subgraphisomorph(cubic_graphs[i], cubic_graphs[j])
        @test (i == j) == has_induced_subgraphisomorph(cubic_graphs[i], cubic_graphs[j])
    end

    # the cubic graphs should only be isomorph a permutation of themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs_perm)
        @test (i == j) == has_isomorph(cubic_graphs[i], cubic_graphs_perm[j])
        @test (i == j) == has_subgraphisomorph(cubic_graphs[i], cubic_graphs_perm[j])
        @test (i == j) == has_induced_subgraphisomorph(cubic_graphs[i], cubic_graphs_perm[j])
    end

    # count_isomorph, count_subgraphisomorph and count_induced_subgraphisomorph are commutative
    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        @test count_isomorph(g1, g1) == count_isomorph(g1, g2) == count_isomorph(g2, g1) == count_isomorph(g2,g2)
        @test count_subgraphisomorph(g1, g1) == count_subgraphisomorph(g1, g2) ==
                   count_subgraphisomorph(g2, g1) == count_subgraphisomorph(g2,g2)
        @test count_induced_subgraphisomorph(g1, g1) == count_subgraphisomorph(g1, g2) ==
                   count_subgraphisomorph(g2, g1) == count_subgraphisomorph(g2,g2)
    end

    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        length(collect(all_isomorph(g1, g1))) == count_isomorph(g1, g2)
        length(collect(all_subgraphisomorph(g1, g1))) == count_isomorph(g1, g2)
        length(collect(all_induced_subgraphisomorph(g1, g1))) == count_isomorph(g1, g2)
    end

    # The frucht-graph is a 3-regular graph that has only one automorphism
    g = smallgraph(:frucht)
    perm = randperm(_rng, 12)
    g2 = shuffle_vertices(g, perm)
    perm_reconstructed = map(uv -> first(uv), first(all_isomorph(g2, g)))
    @test perm == perm_reconstructed

    # TODO better tests for vertex_relation and edge_relation
    vrel(u, v) = false
    erel(e1, e2) = false
    @test has_isomorph(complete_graph(4), complete_graph(4), vertex_relation=vrel) == false
    @test has_isomorph(complete_graph(4), complete_graph(4), edge_relation=erel) == false
    @test has_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel) == false
    @test has_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel) == false
    @test has_induced_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel) == false
    @test has_induced_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel) == false

    @test count_isomorph(complete_graph(4), complete_graph(4), vertex_relation=vrel) == 0
    @test count_isomorph(complete_graph(4), complete_graph(4), edge_relation=erel) == 0
    @test count_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel) == 0
    @test count_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel) == 0
    @test count_induced_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel) == 0
    @test count_induced_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel) == 0

    @test isempty(all_isomorph(complete_graph(4), complete_graph(4), vertex_relation=vrel))
    @test isempty(all_isomorph(complete_graph(4), complete_graph(4), edge_relation=erel))
    @test isempty(all_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel))
    @test isempty(all_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel))
    @test isempty(all_induced_subgraphisomorph(complete_graph(4), complete_graph(3), vertex_relation=vrel))
    @test isempty(all_induced_subgraphisomorph(complete_graph(4), complete_graph(3), edge_relation=erel))

    # some test for early returns if there is no isomorphism
    @test count_isomorph(complete_graph(4), cycle_graph(4)) == 0
    @test isempty(all_isomorph(complete_graph(4), cycle_graph(4)))
    @test count_subgraphisomorph(complete_graph(3), complete_graph(4)) == 0
    

    # this tests triggers the shortcut in the vf2 algorithm if the first graph is smaller than the second one
    @test has_isomorph(complete_graph(3), complete_graph(4)) == false

    # this test is mainly to cover a certain branch of vf2
    # TODO cover directed graphs better
    gd = SimpleDiGraph(Edge.([(2,1)]))
    @test has_isomorph(gd, gd, VF2()) == true

    # Test for correct handling of self-loops
    g1 = SimpleGraph(1)
    add_edge!(g1, 1, 1)
    g2 = SimpleGraph(1)
    @test has_isomorph(g1, g1) == true
    @test has_isomorph(g1, g2) == false
    @test has_isomorph(g2, g1) == false
    @test has_isomorph(g1, g1) == true

    @test has_induced_subgraphisomorph(g1, g1) == true
    @test has_induced_subgraphisomorph(g1, g2) == false
    @test has_induced_subgraphisomorph(g2, g1) == false
    @test has_induced_subgraphisomorph(g2, g2) == true

    @test has_subgraphisomorph(g1, g1) == true
    @test has_subgraphisomorph(g1, g2) == true
    @test has_subgraphisomorph(g2, g1) == false
    @test has_subgraphisomorph(g2, g2) == true
end
