importall LightGraphs.SimpleGraphs
import LightGraphs.SimpleGraphs: fadj, badj, adj
type DummySimpleGraph <: AbstractSimpleGraph end
@testset "SimpleGraphs" begin
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    # specific concrete generators - no need for loop
    @test eltype(SimpleGraph()) == Int
    @test eltype(SimpleGraph(adjmx1)) == Int
    @test_throws ErrorException SimpleGraph(adjmx2)

    @test ne(SimpleGraph(PathDiGraph(5))) == 4
    @test !is_directed(SimpleGraph)

    @test eltype(SimpleDiGraph()) == Int
    @test eltype(SimpleDiGraph(adjmx2)) == Int
    @test ne(SimpleDiGraph(PathGraph(5))) == 8
    @test is_directed(SimpleDiGraph)

    gdx = PathDiGraph(4)
    gx = SimpleGraph()

    for g in testgraphs(gx)
        @test sprint(show, g) == "empty undirected simple graph"
        add_vertices!(g, 5)
        @test sprint(show, g) == "{5, 0} undirected simple graph"

    end
    gx = SimpleDiGraph()
    for g in testdigraphs(gx)
        @test sprint(show, g) == "empty directed simple graph"
        add_vertices!(g, 5)
        @test sprint(show, g) == "{5, 0} directed simple graph"
    end

    gx = PathGraph(4)
    for g in testgraphs(gx)
        @test vertices(g) == 1:4
        @test Edge(2,3) in edges(g)
        @test nv(g) == 4
        @test fadj(g) == badj(g) == adj(g) == g.fadjlist
        @test fadj(g,2) == badj(g,2) == adj(g,2) == g.fadjlist[2]

        @test has_edge(g, 2, 3)
        @test has_edge(g, 3, 2)
        gc = copy(g)
        @test add_edge!(gc, 4, 1) && gc == CycleGraph(4)

        @test in_neighbors(g, 2) == out_neighbors(g, 2) == neighbors(g,2) == [1,3]
        @test add_vertex!(gc)   # out of order, but we want it for issubset
        @test g ⊆ gc
        @test has_vertex(gc, 5)

        @test ne(g) == 3

        @test rem_edge!(gc, 1, 2) && !has_edge(gc, 1, 2)
        ga = copy(g)
        @test rem_vertex!(ga, 2) && ne(ga) == 1
        @test !rem_vertex!(ga, 10)

        @test empty(g) == SimpleGraph{eltype(g)}()

        # concrete tests below

        @test eltype(g) == eltype(fadj(g,1)) == eltype(nv(g))
        T = eltype(g)
        @test nv(SimpleGraph{T}(6)) == 6

        @test eltype(SimpleGraph(T)) == T
        @test eltype(SimpleGraph{T}(adjmx1)) == T

        ga = SimpleGraph(10)
        @test eltype(SimpleGraph{T}(ga)) == T

        for gd in testdigraphs(gdx)
            U = eltype(gd)
            @test eltype(SimpleGraph(gd)) == U
        end

        @test edgetype(g) == SimpleGraphEdge{T}
        @test copy(g) == g
        @test !is_directed(g)

        e = first(edges(g))
        @test has_edge(g, e)
    end

    gdx = PathDiGraph(4)
    for g in testdigraphs(gdx)
        @test vertices(g) == 1:4
        @test Edge(2,3) in edges(g)
        @test !(Edge(3,2) in edges(g))
        @test nv(g) == 4
        @test fadj(g)[2] == fadj(g, 2) == [3]
        @test badj(g)[2] == badj(g, 2) == [1]
        @test_throws MethodError adj(g)

        @test has_edge(g, 2, 3)
        @test !has_edge(g, 3, 2)
        gc = copy(g)
        @test add_edge!(gc, 4, 1) && gc == CycleDiGraph(4)

        @test in_neighbors(g, 2) == [1]
        @test out_neighbors(g, 2) == neighbors(g,2) == [3]
        @test add_vertex!(gc)   # out of order, but we want it for issubset
        @test g ⊆ gc
        @test has_vertex(gc, 5)

        @test ne(g) == 3

        @test !rem_edge!(gc, 2, 1)
        @test rem_edge!(gc, 1, 2) && !has_edge(gc, 1, 2)
        ga = copy(g)
        @test rem_vertex!(ga, 2) && ne(ga) == 1
        @test !rem_vertex!(ga, 10)

        @test empty(g) == SimpleDiGraph{eltype(g)}()

        # concrete tests below

        @test eltype(g) == eltype(fadj(g,1)) == eltype(nv(g))
        T = eltype(g)
        @test nv(SimpleDiGraph{T}(6)) == 6

        @test eltype(SimpleDiGraph(T)) == T
        @test eltype(SimpleDiGraph{T}(adjmx2)) == T

        ga = SimpleDiGraph(10)
        @test eltype(SimpleDiGraph{T}(ga)) == T

        for gu in testgraphs(gx)
            U = eltype(gu)
            @test eltype(SimpleDiGraph(gu)) == U
        end

        @test edgetype(g) == SimpleDiGraphEdge{T}
        @test copy(g) == g
        @test is_directed(g)

        e = first(edges(g))
        @test has_edge(g, e)
    end
end
