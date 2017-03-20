@testset "SimpleEdgeIter" begin
    ga = SimpleGraph(10,20; seed=1)
    gb = SimpleGraph(10,20; seed=1)
    @test @inferred(sprint(show,edges(ga))) == "SimpleEdgeIter 20"
    @test sprint(show, start(edges(ga))) == "SimpleEdgeIterState [1, 1, false]"

    @test @inferred(length(collect(edges(Graph(0,0))))) == 0

    @test @inferred(edges(ga)) == edges(gb)
    @test @inferred(edges(ga)) == collect(Edge, edges(gb))
    @test collect(Edge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
    @test @inferred(edges(ga)) == Set{Edge}(collect(Edge, edges(gb)))

    @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == SimpleEdge

    ga = SimpleDiGraph(10,20; seed=1)
    gb = SimpleDiGraph(10,20; seed=1)
    @test @inferred(edges(ga)) == edges(gb)
    @test @inferred(edges(ga)) == collect(SimpleEdge, edges(gb))
    @test collect(SimpleEdge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(SimpleEdge, edges(gb))) == edges(ga)
    @test @inferred(edges(ga)) == Set{SimpleEdge}(collect(SimpleEdge, edges(gb)))

    ga = SimpleGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test @inferred(es.s) == 2
    @test @inferred(es.di) == 1

    @test [e for e in eit] == [Edge(2, 3), Edge(3, 10), Edge(5,10)]

    ga = SimpleDiGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test @inferred(es.s) == 3
    @test @inferred(es.di) == 1

    @test [e for e in eit] == [
      SimpleEdge(3, 2), SimpleEdge(3, 10),
      SimpleEdge(5,10), SimpleEdge(10,3)
    ]
end
