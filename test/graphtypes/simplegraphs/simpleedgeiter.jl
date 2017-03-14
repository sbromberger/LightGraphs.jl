@testset "SimpleEdgeIter" begin
    ga = SimpleGraph(10,20; seed=1)
    gb = SimpleGraph(10,20; seed=1)
    @test sprint(show,edges(ga)) == "SimpleEdgeIter 20"
    @test sprint(show, start(edges(ga))) == "SimpleEdgeIterState [1, 1, false]"

    @test length(collect(edges(Graph(0,0)))) == 0

    @test edges(ga) == edges(gb)
    @test edges(ga) == collect(Edge, edges(gb))
    @test collect(Edge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
    @test edges(ga) == Set{Edge}(collect(Edge, edges(gb)))

    @test eltype(edges(ga)) == SimpleEdge

    ga = SimpleDiGraph(10,20; seed=1)
    gb = SimpleDiGraph(10,20; seed=1)
    @test edges(ga) == edges(gb)
    @test edges(ga) == collect(SimpleEdge, edges(gb))
    @test collect(SimpleEdge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(SimpleEdge, edges(gb))) == edges(ga)
    @test edges(ga) == Set{SimpleEdge}(collect(SimpleEdge, edges(gb)))

    ga = SimpleGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test es.s == 2
    @test es.di == 1

    @test [e for e in eit] == [Edge(2, 3), Edge(3, 10), Edge(5,10)]

    ga = SimpleDiGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test es.s == 3
    @test es.di == 1

    @test [e for e in eit] == [
      SimpleEdge(3, 2), SimpleEdge(3, 10),
      SimpleEdge(5,10), SimpleEdge(10,3)
    ]
end
