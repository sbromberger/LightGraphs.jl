ga = Graph(10,20; seed=1)
gb = Graph(10,20; seed=1)
@test sprint(show,edges(ga)) == "EdgeIter 20"
@test sprint(show, start(edges(ga))) == "EdgeIterState [1, 1, false]"

@test edges(ga) == edges(gb)
@test edges(ga) == collect(Edge, edges(gb))
@test collect(Edge, edges(gb)) == edges(ga)
@test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
@test edges(ga) == Set{Edge}(collect(Edge, edges(gb)))

ga = DiGraph(10,20; seed=1)
gb = DiGraph(10,20; seed=1)
@test edges(ga) == edges(gb)
@test edges(ga) == collect(Edge, edges(gb))
@test collect(Edge, edges(gb)) == edges(ga)
@test Set{Edge}(collect(Edge, edges(gb))) == edges(ga)
@test edges(ga) == Set{Edge}(collect(Edge, edges(gb)))

ga = Graph(10)
add_edge!(ga, 3, 4)
ei = edges(ga)
es = start(ei)
@test es.s == 3
@test es.di == 1
