@test e1.first == src(e1) == 1
@test e1.second == dst(e1) == 2
@test reverse(e1) == re1
@test sprint(show, e1) == "edge 1 - 2"

g = Graph(5)
add_edge!(g, 1, 2)
e2 = add_edge!(g, 1, 3)
e3 = add_edge!(g, 1, 4)
e4 = add_edge!(g, 2, 5)
e5 = add_edge!(g, 3, 5)

h = DiGraph(5)
add_edge!(h, 1, 2)
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 3, 5)


@test vertices(g) == 1:5
@test edges(g) == Set([e1, e2, e3, e4, e5])

# fadj, badj, and adj tested in graphdigraph.jl

@test degree(g) == [3, 2, 2, 1, 2]
@test indegree(g) == [3, 2, 2, 1, 2]
@test indegree(g,1) == 3
@test outdegree(g) == [3, 2, 2, 1, 2]
@test outdegree(g,1) == 3
@test degree(h) == [3, 2, 2, 1, 2]
@test indegree(h) == [0, 1, 1, 1, 2]
@test indegree(h,1) == 0
@test outdegree(h) == [3, 1, 1, 0, 0]
@test outdegree(h,1) == 3
@test in_neighbors(h,5) == LightGraphs.badj(h)[5] == LightGraphs.badj(h,5) == [2, 3]
@test out_neighbors(h,1) == LightGraphs.fadj(h)[1] == LightGraphs.fadj(h,1) == [2, 3, 4]

@test p1 == g2
@test issubset(h2, h1)

@test has_edge(g, 1, 2)
@test in_edges(g, 2) == [e1, reverse(e4)]
@test out_edges(g, 1) == [e1, e2, e3]

@test add_vertex!(g) == 6
@test add_vertices!(g,5) == 11
@test has_vertex(g, 11)
@test nv(g) == 11
@test ne(g) == 5
@test !is_directed(g)
@test is_directed(h)

@test δ(g) == δin(g) == δout(g) == 0
@test Δ(g) == Δout(g) == 3
@test Δin(h) == 2
@test δ(h) == 1
@test δin(h) == 0
@test δout(h) == 0


@test degree_histogram(g)[1:4] == [1, 3, 1, 0]
@test neighbors(g, 1) == [2, 3, 4]
@test common_neighbors(g, 2, 3) == [1, 5]
@test common_neighbors(h, 2, 3) == [5]

add_edge!(g, 1, 1)
@test rem_edge!(g, 1, 1) == Edge(1, 1)
@test rem_edge!(g, 1, 2) == e1
@test_throws ErrorException rem_edge!(g, 2, 1)
add_edge!(g, 1, 2)
@test rem_edge!(g, 2, 1) == e1

add_edge!(h, 1, 1)
@test rem_edge!(h, 1, 1) == Edge(1, 1)
@test rem_edge!(h, 1, 2) == e1
@test_throws ErrorException rem_edge!(h, 1, 2)

function test_rem_edge(g, srcv)
    srcv = 2
    for dstv in collect(neighbors(g, srcv))
        rem_edge!(g, srcv, dstv)
    end
    @test length(neighbors(g,srcv)) == 0
end
for v in vertices(g)
    test_rem_edge(copy(g),v)
end
for v in vertices(h)
    test_rem_edge(copy(h),v)
end

@test g == copy(g)
@test !(g === copy(g))
g10 = CompleteGraph(5)
rem_vertex!(g10, 1)
@test g10 == CompleteGraph(4)
rem_vertex!(g10, 4)
@test g10 == CompleteGraph(3)
@test_throws BoundsError rem_vertex!(g10, 9)

g10 = CompleteDiGraph(5)
rem_vertex!(g10, 1)
@test g10 == CompleteDiGraph(4)
rem_vertex!(g10, 4)
@test g10 == CompleteDiGraph(3)
@test_throws BoundsError rem_vertex!(g10, 9)

g10 = PathGraph(5)
rem_vertex!(g10, 5)
@test g10 == PathGraph(4)
rem_vertex!(g10, 4)
@test g10 == PathGraph(3)

g10 = PathDiGraph(5)
rem_vertex!(g10, 5)
@test g10 == PathDiGraph(4)
rem_vertex!(g10, 4)
@test g10 == PathDiGraph(3)

g10 = PathDiGraph(5)
rem_vertex!(g10, 1)
h10 = PathDiGraph(6)
rem_vertex!(h10, 1)
rem_vertex!(h10, 1)
@test g10 == h10

g10 = CycleGraph(5)
rem_vertex!(g10, 5)
@test g10 == PathGraph(4)

g10 = PathGraph(3)
rem_vertex!(g10, 2)
@test g10 == Graph(2)

g10 = PathGraph(4)
rem_vertex!(g10, 3)
h10 =Graph(3)
add_edge!(h10,1,2)
@test g10 == h10

g10 = CompleteGraph(5)
rem_vertex!(g10, 3)
@test g10 == CompleteGraph(4)
