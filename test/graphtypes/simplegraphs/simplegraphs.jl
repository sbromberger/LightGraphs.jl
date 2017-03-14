type DummySimpleGraph <: AbstractSimpleGraph end
@testset "SimpleGraphs" begin
    dsg = DummySimpleGraph()

    @test_throws ErrorException badj(dsg)

    e1 = SimpleEdge(1,2)
    e2 = SimpleEdge(1,3)
    e3 = SimpleEdge(1,4)
    e4 = SimpleEdge(2,5)
    e5 = SimpleEdge(3,5)

    re1 = Edge(2, 1)
    pdict = load(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    g2 = smallgraph(:tutte)

    h1 = Graph(5)
    h2 = Graph(3)

    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph

    @test e1.src == src(e1) == 1
    @test e1.dst == dst(e1) == 2
    @test reverse(e1) == re1
    @test sprint(show, e1) == "Edge 1 => 2"
    @test Pair(e1) == Pair(1,2)
    @test Tuple(e1) == (1,2)

    @test LightGraphs.is_ordered(e5)
    @test !LightGraphs.is_ordered(reverse(e5))

    @test !is_directed(SimpleGraph)
    @test is_directed(SimpleDiGraph)

    @test sprint(show, SimpleGraph()) == "empty undirected simple graph"

    g = SimpleGraph(5)
    @test sprint(show, g) == "{5, 0} undirected simple graph"
    @test add_edge!(g, 1, 2)
    @test add_edge!(g, e2)
    @test add_edge!(g, e3)
    @test add_edge!(g, e4)
    @test add_edge!(g, e5)

    @test Graph(DiGraph(g)) == g

    h = SimpleDiGraph(5)
    @test add_edge!(h, 1, 2)
    @test add_edge!(h, e2)
    @test add_edge!(h, e3)
    @test add_edge!(h, e4)
    @test add_edge!(h, e5)

    @test vertices(g) == 1:5
    i = 0
    for e in edges(g)
        i+=1
    end
    @test i == 5
    @test has_edge(g, 3, 5)
    # @test edges(g) == Set([e1, e2, e3, e4, e5])
    # @test Set{Edge}(edges(g)) == Set([e1, e2, e3, e4, e5])
    # fadj, badj, and adj tested in graphdigraph.jl

    @test degree(g) == [3, 2, 2, 1, 2]
    @test degree(g, 1) == 3
    @test indegree(g) == [3, 2, 2, 1, 2]
    @test indegree(g, 1) == 3
    @test outdegree(g) == [3, 2, 2, 1, 2]
    @test outdegree(g, 1) == 3
    @test in_neighbors(g, 5) == [2, 3]
    @test out_neighbors(g, 1) == [2, 3, 4]

    @test density(g) == 0.5

    @test degree(h) == [3, 2, 2, 1, 2]
    @test degree(h, 1) == 3
    @test indegree(h) == [0, 1, 1, 1, 2]
    @test indegree(h, 1) == 0
    @test outdegree(h) == [3, 1, 1, 0, 0]
    @test outdegree(h, 1) == 3
    @test in_neighbors(h, 5) == [2, 3]
    @test out_neighbors(h, 1) == [2, 3, 4]
    @test all_neighbors(h, 1) == union(in_neighbors(h, 1), out_neighbors(h, 1))
    @test density(h) == 0.25

    @test p1 == g2
    @test issubset(h2, h1)

    @test has_edge(g, 1, 2)

    @test add_vertex!(g) && nv(g) == 6
    @test add_vertices!(g,5) && nv(g) == 11
    @test has_vertex(g, 11)
    @test ne(g) == 5
    @test !is_directed(g)
    @test is_directed(h)

    @test δ(g) == δin(g) == δout(g) == 0
    @test Δ(g) == Δout(g) == 3
    @test Δin(h) == 2
    @test δ(h) == 1
    @test δin(h) == 0
    @test δout(h) == 0
    @test CompleteGraph(4) == CompleteGraph(4)
    @test CompleteGraph(4) != PathGraph(4)
    @test CompleteDiGraph(4) != PathDiGraph(4)
    @test CompleteDiGraph(4) == CompleteDiGraph(4)

    @test degree_histogram(CompleteDiGraph(10)).weights == [10]
    @test degree_histogram(CompleteGraph(10)).weights == [10]

    @test neighbors(g, 1) == [2, 3, 4]
    @test common_neighbors(g, 2, 3) == [1, 5]
    @test common_neighbors(h, 2, 3) == [5]

    @test add_edge!(g, 1, 1)
    @test has_self_loops(g)
    @test num_self_loops(g) == 1
    @test !add_edge!(g, 1, 1)
    @test rem_edge!(g, 1, 1)
    @test !rem_edge!(g, 1, 1)
    @test ne(g) == 5
    @test rem_edge!(g, 1, 2)
    @test ne(g) == 4
    @test !rem_edge!(g, 2, 1)
    add_edge!(g, 1, 2)
    @test ne(g) == 5

    @test has_edge(g,2,1)
    @test has_edge(g,1,2)
    @test rem_edge!(g, 2, 1)
    @test add_edge!(h, 1, 1)
    @test rem_edge!(h, 1, 1)
    @test rem_edge!(h, 1, 2)
    @test !rem_edge!(h, 1, 2)

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

    g = CompleteGraph(5)
    @test rem_vertex!(g, 1)
    @test g == CompleteGraph(4)
    @test rem_vertex!(g, 4)
    @test g == CompleteGraph(3)
    @test !rem_vertex!(g, 9)

    g = CompleteDiGraph(5)
    @test rem_vertex!(g, 1)
    @test g == CompleteDiGraph(4)
    rem_vertex!(g, 4)
    @test g == CompleteDiGraph(3)
    @test !rem_vertex!(g, 9)
    g = PathGraph(5)
    @test rem_vertex!(g, 5)
    @test g == PathGraph(4)
    @test rem_vertex!(g, 4)
    @test g == PathGraph(3)

    g = PathDiGraph(5)
    @test rem_vertex!(g, 5)
    @test g == PathDiGraph(4)
    @test rem_vertex!(g, 4)
    @test g == PathDiGraph(3)

    g = PathDiGraph(5)
    @test rem_vertex!(g, 1)
    h10 = PathDiGraph(6)
    @test rem_vertex!(h10, 1)
    @test rem_vertex!(h10, 1)
    @test g == h10

    g = CycleGraph(5)
    @test rem_vertex!(g, 5)
    @test g == PathGraph(4)

    g = PathGraph(3)
    @test rem_vertex!(g, 2)
    @test g == SimpleGraph(2)

    g = PathGraph(4)
    @test rem_vertex!(g, 3)
    h10 =Graph(3)
    @test add_edge!(h10,1,2)
    @test g == h10

    g = CompleteGraph(5)
    @test rem_vertex!(g, 3)
    @test g == CompleteGraph(4)


    badadjmx = [ 0 1 0; 1 0 1]
    @test_throws ErrorException SimpleGraph(badadjmx)
    @test_throws ErrorException SimpleGraph(sparse(badadjmx))
    @test_throws ErrorException SimpleDiGraph(badadjmx)
    @test_throws ErrorException SimpleDiGraph(sparse(badadjmx))
    @test_throws ErrorException SimpleGraph([1 0; 1 1])

    g = CompleteGraph(5)
    @test !add_edge!(g, 100, 100)
    h = CompleteDiGraph(5)
    @test !add_edge!(h, 100, 100)

    @test_throws ErrorException Graph(sparse(adjmx2))

    g = Graph(sparse(adjmx1))
    h = DiGraph(sparse(adjmx1))
    @test !is_directed(g)
    @test is_directed(h)
end
