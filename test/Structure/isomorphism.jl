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
cubic_graphs = [SG.SimpleGraph(SG.SimpleEdge.([(1,2), (1,3), (1,8), (2,3), (2,4), (3,4),
                                   (4,5), (5,6), (5,7), (6,7), (6,8), (7,8)])),
                SG.SimpleGraph(SG.SimpleEdge.([(1,2), (1,3), (1,8), (2,3), (2,5), (3,4),
                                   (4,5), (4,7), (5,6), (6,7), (6,8), (7,8)])),
                SG.SimpleGraph(SG.SimpleEdge.([(1,2), (1,3), (1,8), (2,3), (2,6), (3,4),
                                   (4,5), (4,7), (5,6), (5,8), (6,7), (7,8)])),
                SG.SimpleGraph(LGGEN.Grid([2,2,2])),
                SG.SimpleGraph(SG.SimpleEdge.([(1,2), (1,5), (1,8), (2,3), (2,6), (3,4),
                                   (3,7), (4,5), (4,8), (5,6), (6,7), (7,8)]))
               ]
# vertex permutated versions of cubic_graphs
cubic_graphs_perm = []
_rng = MersenneTwister(1)
for i = 1:length(cubic_graphs)
    push!(cubic_graphs_perm, shuffle_vertices(cubic_graphs[i], randperm(_rng, 8)))
end

@testset "Isomorphism" begin
    @test LGST.has_isomorph(SG.SimpleGraph(LGGEN.Grid([2,3])), SG.SimpleGraph(LGGEN.Grid([3,2])), LGST.FullGraph())

    # the cubic graphs should only be isomorph to themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs)
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs[j], LGST.FullGraph())
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs[j], LGST.Subgraph())
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs[j], LGST.InducedSubgraph())
    end

    # the cubic graphs should only be isomorph a permutation of themself
    # the same holds for subgraph isomorphism and induced subgraph isomorphism
    for i in 1:length(cubic_graphs), j in 1:length(cubic_graphs_perm)
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs_perm[j], LGST.FullGraph())
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs_perm[j], LGST.Subgraph())
        @test (i == j) == LGST.has_isomorph(cubic_graphs[i], cubic_graphs_perm[j], LGST.InducedSubgraph())
    end

    # LGST.count_isomorph, count_subgraphisomorph and count_induced_subgraphisomorph are commutative
    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        @test LGST.count_isomorph(g1, g1, LGST.FullGraph()) == LGST.count_isomorph(g1, g2, LGST.FullGraph()) ==
            LGST.count_isomorph(g2, g1, LGST.FullGraph()) == LGST.count_isomorph(g2, g2, LGST.FullGraph())
        @test LGST.count_isomorph(g1, g1, LGST.Subgraph()) == LGST.count_isomorph(g1, g2, LGST.Subgraph()) ==
            LGST.count_isomorph(g2, g1, LGST.Subgraph()) == LGST.count_isomorph(g2, g2, LGST.Subgraph())
        @test LGST.count_isomorph(g1, g1, LGST.InducedSubgraph()) == LGST.count_isomorph(g1, g2, LGST.Subgraph()) ==
            LGST.count_isomorph(g2, g1, LGST.Subgraph()) == LGST.count_isomorph(g2, g2, LGST.Subgraph())
    end

    for i in 1:length(cubic_graphs)
        g1 = cubic_graphs[i]
        g2 = cubic_graphs_perm[i]
        length(collect(LGST.all_isomorph(g1, g1, LGST.FullGraph()))) == LGST.count_isomorph(g1, g2, LGST.FullGraph())
        length(collect(LGST.all_isomorph(g1, g1, LGST.Subgraph()))) == LGST.count_isomorph(g1, g2, LGST.FullGraph())
        length(collect(LGST.all_isomorph(g1, g1, LGST.InducedSubgraph()))) == LGST.count_isomorph(g1, g2, LGST.FullGraph())
    end

    # The frucht-graph is a 3-regular graph that has only one automorphism
    g = SG.SimpleGraph(LGGEN.Frucht())
    perm = randperm(_rng, 12)
    g2 = shuffle_vertices(g, perm)
    perm_reconstructed = map(uv -> first(uv), first(LGST.all_isomorph(g2, g, LGST.FullGraph())))
    @test perm == perm_reconstructed

    # TODO better tests for vertex_relation and edge_relation
    vrel(u, v) = false
    erel(e1, e2) = false
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(vertex_relation=vrel))
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(edge_relation=erel))
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(vertex_relation=vrel))
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(edge_relation=erel))
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(vertex_relation=vrel))
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(edge_relation=erel))

    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(vertex_relation=vrel)) == 0
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(edge_relation=erel)) == 0
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(vertex_relation=vrel)) == 0
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(edge_relation=erel)) == 0
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(vertex_relation=vrel)) == 0
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(edge_relation=erel)) == 0

    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(vertex_relation=vrel)))
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph(), LGST.VF2(edge_relation=erel)))
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(vertex_relation=vrel)))
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.Subgraph(), LGST.VF2(edge_relation=erel)))
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(vertex_relation=vrel)))
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SimpleGraph(LGGEN.Complete(3)), LGST.InducedSubgraph(), LGST.VF2(edge_relation=erel)))

    # some test for early returns if there is no isomorphism
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(4)), SG.SimpleGraph(LGGEN.Cycle(4)), LGST.FullGraph()) == 0
    @test isempty(LGST.all_isomorph(SimpleGraph(LGGEN.Complete(4)), SG.SimpleGraph(LGGEN.Cycle(4)), LGST.FullGraph()))
    @test LGST.count_isomorph(SimpleGraph(LGGEN.Complete(3)), SimpleGraph(LGGEN.Complete(4)), LGST.Subgraph()) == 0


    # this tests triggers the shortcut in the vf2 algorithm if the first graph is smaller than the second one
    @test !LGST.has_isomorph(SimpleGraph(LGGEN.Complete(3)), SimpleGraph(LGGEN.Complete(4)), LGST.FullGraph())

    # this test is mainly to cover a certain branch of vf2
    # TODO cover directed graphs better
    gd = SimpleDiGraph(SG.SimpleEdge.([(2,1)]))
    @test LGST.has_isomorph(gd, gd, LGST.FullGraph(), LGST.VF2())

    # Test for correct handling of self-loops
    g1 = SG.SimpleGraph(1)
    add_edge!(g1, 1, 1)
    g2 = SG.SimpleGraph(1)
    @test LGST.has_isomorph(g1, g1, LGST.FullGraph())
    @test !LGST.has_isomorph(g1, g2, LGST.FullGraph())
    @test !LGST.has_isomorph(g2, g1, LGST.FullGraph())
    @test LGST.has_isomorph(g1, g1, LGST.FullGraph())

    @test LGST.has_isomorph(g1, g1, LGST.InducedSubgraph())
    @test !LGST.has_isomorph(g1, g2, LGST.InducedSubgraph())
    @test !LGST.has_isomorph(g2, g1, LGST.InducedSubgraph())
    @test LGST.has_isomorph(g2, g2, LGST.InducedSubgraph())

    @test LGST.has_isomorph(g1, g1, LGST.Subgraph())
    @test LGST.has_isomorph(g1, g2, LGST.Subgraph())
    @test !LGST.has_isomorph(g2, g1, LGST.Subgraph())
    @test LGST.has_isomorph(g2, g2, LGST.Subgraph())
end
