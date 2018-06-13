@testset "SimpleEdgeIter" begin
    ga = @inferred(SimpleGraph(10, 20; seed=1))
    gb = @inferred(SimpleGraph(10, 20; seed=1))
    @test sprint(show, edges(ga)) == "SimpleEdgeIter 20"
    @test sprint(show, iterate(edges(ga))[2]) == "SimpleEdgeIterState [1, 1]"

    @test length(collect(edges(Graph(0, 0)))) == 0

    @test @inferred(edges(ga)) == edges(gb)
    @test @inferred(edges(ga)) == collect(Edge, edges(gb))
    @test edges(ga) != collect(Edge, Base.Iterators.take(edges(gb), 5))

    @test collect(Edge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
    @test @inferred(edges(ga)) == Set{Edge}(collect(Edge, edges(gb)))

    @test @inferred(eltype(edges(ga))) == eltype(typeof(edges(ga))) == edgetype(ga)
    @test eltype(collect(edges(ga))) == edgetype(ga)

    ga = @inferred(SimpleDiGraph(10, 20; seed=1))
    gb = @inferred(SimpleDiGraph(10, 20; seed=1))
    @test @inferred(edges(ga)) == edges(gb)
    @test @inferred(edges(ga)) == collect(SimpleEdge, edges(gb))
    @test collect(SimpleEdge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(SimpleEdge, edges(gb))) == edges(ga)
    @test @inferred(edges(ga)) == Set{SimpleEdge}(collect(SimpleEdge, edges(gb)))
    @test eltype(collect(edges(ga))) == edgetype(ga)

    ga = SimpleGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    e1 = Edge(3, 10)
    e2 = (3, 10)
    @test e1 ∈ edges(ga)
    @test e2 ∈ edges(ga)
    @test (3, 9) ∉ edges(ga)

    for u in 1:20, v in 1:20
      b = has_edge(ga, u, v)
      @test b == @inferred (u, v) ∈ edges(ga)
      @test b == @inferred (u => v) ∈ edges(ga)
      @test b == @inferred Edge(u, v) ∈ edges(ga)
    end

    eit = edges(ga)
    es = @inferred(iterate(eit)[2])

    @test es.s == 2
    @test es.di == 1

    @test [e for e in eit] == [Edge(2, 3), Edge(3, 10), Edge(5, 10)]

    gb = copy(ga)
    add_vertex!(gb)
    @test edges(ga) == edges(gb)
    @test edges(gb) == edges(ga)


    ga = SimpleDiGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    for u in 1:20, v in 1:20
      b = has_edge(ga, u, v)
      @test b == @inferred (u, v) ∈ edges(ga)
      @test b == @inferred (u => v) ∈ edges(ga)
      @test b == @inferred Edge(u, v) ∈ edges(ga)
    end

    eit = @inferred(edges(ga))
    es = @inferred(iterate(eit)[2])

    @test es.s == 3
    @test es.di == 1

    @test [e for e in eit] == [
      SimpleEdge(3, 2), SimpleEdge(3, 10),
      SimpleEdge(5, 10), SimpleEdge(10, 3)
    ]

    gb = copy(ga)
    add_vertex!(gb)
    @test edges(ga) == edges(gb)
    @test edges(gb) == edges(ga)
end
