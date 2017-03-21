importall LightGraphs.SimpleGraphs
import LightGraphs.SimpleGraphs: fadj, badj, adj
struct DummySimpleGraph <: AbstractSimpleGraph end
@testset "SimpleGraphs" begin
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    # specific concrete generators - no need for loop
    @test @inferred(eltype(SimpleGraph())) == Int
    @test @inferred(eltype(SimpleGraph(adjmx1))) == Int
    @test_throws ErrorException SimpleGraph(adjmx2)

    @test @inferred(ne(SimpleGraph(PathDiGraph(5)))) == 4
    @test @inferred(!is_directed(SimpleGraph))

    @test @inferred(eltype(SimpleDiGraph())) == Int
    @test @inferred(eltype(SimpleDiGraph(adjmx2))) == Int
    @test @inferred(ne(SimpleDiGraph(PathGraph(5)))) == 8
    @test @inferred(is_directed(SimpleDiGraph))


    for gbig in [Graph(0xff), DiGraph(0xff)]
        @test @inferred(!add_vertex!(gbig))    # overflow
        @test @inferred(!add_vertices!(gbig, 10))
    end

    gdx = PathDiGraph(4)
    gx = SimpleGraph()
    for g in testgraphs(gx)
        T = eltype(g)
        @test sprint(show, g) == "empty undirected simple $T graph"
        @inferred(add_vertices!(g, 5))
        @test sprint(show, g) == "{5, 0} undirected simple $T graph"
    end
    gx = SimpleDiGraph()
    for g in testdigraphs(gx)
        T = eltype(g)
        @test sprint(show, g) == "empty directed simple $T graph"
        @inferred(add_vertices!(g, 5))
        @test sprint(show, g) == "{5, 0} directed simple $T graph"
    end

    gx = PathGraph(4)
    for g in testgraphs(gx)
        @test @inferred(vertices(g)) == 1:4
        @test Edge(2,3) in edges(g)
        @test @inferred(nv(g)) == 4
        @test @inferred(fadj(g)) == badj(g) == adj(g) == g.fadjlist
        @test @inferred(fadj(g,2)) == badj(g,2) == adj(g,2) == g.fadjlist[2]

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(has_edge(g, 3, 2))
        gc = copy(g)
        @test add_edge!(gc, 4, 1) && gc == CycleGraph(4)

        @test @inferred(in_neighbors(g, 2)) == @inferred(out_neighbors(g, 2)) == @inferred(neighbors(g,2)) == [1,3]
        @test @inferred(add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!rem_vertex!(ga, 10))

        @test @inferred(empty(g)) == SimpleGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(fadj(g,1)) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SimpleGraph{T}(6))) == 6

        @test @inferred(eltype(SimpleGraph(T))) == T
        @test @inferred(eltype(SimpleGraph{T}(adjmx1))) == T

        ga = SimpleGraph(10)
        @test @inferred(eltype(SimpleGraph{T}(ga))) == T

        for gd in testdigraphs(gdx)
            U = eltype(gd)
            @test @inferred(eltype(SimpleGraph(gd))) == U
        end

        @test @inferred(edgetype(g)) == SimpleGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(!is_directed(g))

        e = first(edges(g))
        @test @inferred(has_edge(g, e))
    end

    gdx = PathDiGraph(4)
    for g in testdigraphs(gdx)
        @test @inferred(vertices(g)) == 1:4
        @test Edge(2,3) in edges(g)
        @test !(Edge(3,2) in edges(g))
        @test @inferred(nv(g)) == 4
        @test @inferred(fadj(g)[2]) == fadj(g, 2) == [3]
        @test @inferred(badj(g)[2]) == badj(g, 2) == [1]
        @test_throws MethodError adj(g)

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(!has_edge(g, 3, 2))
        gc = @inferred(copy(g))
        @test @inferred(add_edge!(gc, 4, 1)) && gc == CycleDiGraph(4)

        @test @inferred(in_neighbors(g, 2)) == [1]
        @test @inferred(out_neighbors(g, 2)) == @inferred(neighbors(g,2)) == [3]
        @test @inferred(add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(!rem_edge!(gc, 2, 1))
        @test @inferred(rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!rem_vertex!(ga, 10))

        @test @inferred(empty(g)) == SimpleDiGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(@inferred(fadj(g,1))) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SimpleDiGraph{T}(6))) == 6

        @test @inferred(eltype(SimpleDiGraph(T))) == T
        @test @inferred(eltype(SimpleDiGraph{T}(adjmx2))) == T

        ga = SimpleDiGraph(10)
        @test @inferred(eltype(SimpleDiGraph{T}(ga))) == T

        for gu in testgraphs(gx)
            U = @inferred(eltype(gu))
            @test @inferred(eltype(SimpleDiGraph(gu))) == U
        end

        @test @inferred(edgetype(g)) == SimpleDiGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(is_directed(g))

        e = first(@inferred(edges(g)))
        @test @inferred(has_edge(g, e))
    end
end
