@testset "Edgeiter" begin
    ga = Graph(10,20; seed=1)
    gb = Graph(10,20; seed=1)
    @test sprint(show,edges(ga)) == "EdgeIter 20"
    @test sprint(show, start(edges(ga))) == "EdgeIterState [1, 1, false]"

    @test length(collect(edges(Graph(0,0)))) == 0

    @test edges(ga) == edges(gb)
    @test edges(ga) == collect(Edge, edges(gb))
    @test collect(Edge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
    @test edges(ga) == Set{Edge}(collect(Edge, edges(gb)))

    @test eltype(edges(ga)) == Edge

    ga = DiGraph(10,20; seed=1)
    gb = DiGraph(10,20; seed=1)
    @test edges(ga) == edges(gb)
    @test edges(ga) == collect(Edge, edges(gb))
    @test collect(Edge, edges(gb)) == edges(ga)
    @test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
    @test edges(ga) == Set{Edge}(collect(Edge, edges(gb)))

    ga = Graph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test es.s == 2
    @test es.di == 1

    @test [e for e in eit] == [Edge(2, 3), Edge(3, 10), Edge(5,10)]

    ga = DiGraph(10)
    add_edge!(ga, 3, 2)
    add_edge!(ga, 3, 10)
    add_edge!(ga, 5, 10)
    add_edge!(ga, 10, 3)

    eit = edges(ga)
    es = start(eit)

    @test es.s == 3
    @test es.di == 1

    @test [e for e in eit] == [Edge(3, 2), Edge(3, 10), Edge(5,10), Edge(10,3)]
end
