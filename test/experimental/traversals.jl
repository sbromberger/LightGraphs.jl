using LightGraphs.Experimental.Traversals
const LET = LightGraphs.Experimental.Traversals
struct DummyTraversalState <: LET.AbstractTraversalState end

@testset "Traversals" begin
    d = DummyTraversalState()
    @test LET.initfn!(d, 1) == true
    @test LET.previsitfn!(d, 1) == true
    @test LET.visitfn!(d, 1, 2) == true
    @test LET.newvisitfn!(d, 1, 2) == true
    @test LET.postvisitfn!(d, 1) == true
    @test LET.postlevelfn!(d) == true

    x = [3,1,2]
    @test sort!(x, 3, 1, LET.NOOPSort, Base.Sort.ForwardOrdering()) == x

    @testset "BFS" begin
        g1= smallgraph(:house)
        dg1 = path_digraph(6); add_edge!(dg1, 2, 6)

        b1 = LET.BFS()
        @test b1 == LET.BFS(LET.NOOPSort)

        b2 = LET.BFS(QuickSort)

        @testset "undirected" begin
            for g in testgraphs(g1)
                v1 = @inferred LET.visited_vertices(g, 3, b1)
                v2 = @inferred LET.visited_vertices(g, 3, b2)
                v3 = @inferred LET.visited_vertices(g, [3], b1)
                @test v1 == v2 == v3 == [3, 1, 4, 5, 2]
                p1 = @inferred LET.parents(g, 2, b1)
                p2 = @inferred LET.parents(g, 2, b2)
                @test p1 == p2 == [2, 0, 1, 2, 4]
                d1 = @inferred LET.distances(g, 1, b1)
                d2 = @inferred LET.distances(g, 1 ,b2)
                d3 = @inferred LET.distances(g, [1], b1)
                @test d1 == d2 == d3 == [0, 1, 1, 2, 2]
                t1 = @inferred LET.tree(g, 2, b1)
                t2 = @inferred LET.tree(g, 2, b2)
                t3 = @inferred LET.tree(p1)
                t4 = @inferred LET.tree(p2)
                @test t1 == t2 == t3 == t4

            end
        end
        @testset "directed" begin
            for dg in testgraphs(dg1)
                v1 = @inferred LET.visited_vertices(dg, 1, b1)
                v2 = @inferred LET.visited_vertices(dg, 1, b2)
                v3 = @inferred LET.visited_vertices(dg, [1], b1)
                @test v1 == v2 == v3 == [1, 2, 3, 6, 4, 5]
                @test (@inferred LET.parents(dg, 2, b1)) == LET.parents(dg, 2, b2) == [0, 0, 2, 3, 4, 2]
                p1 = @inferred LET.parents(dg, 2, b1)
                p2 = @inferred LET.parents(dg, 2, b2)
                p3 = @inferred LET.parents(dg, 6, b1, inneighbors)
                p4 = @inferred LET.parents(dg, 6, b2, inneighbors)
                @test p1 == p2 == [0, 0, 2, 3, 4, 2]
                @test p3 == p4 == [2, 6, 4, 5, 6, 0]
                d1 = @inferred LET.distances(dg, 1, b1)
                d2 = @inferred LET.distances(dg, 1, b2)
                d3 = @inferred LET.distances(dg, [1], b1)
                @test d1 == d2 == d3 == [0, 1, 2, 3, 4, 2]
                t1 = @inferred LET.tree(dg, 2, b1)
                t2 = @inferred LET.tree(dg, 2, b2)
                t3 = @inferred LET.tree(p1)
                t4 = @inferred LET.tree(p2)
                @test t1 == t2 == t3 == t4
                t5 = @inferred LET.tree(dg, 6, b1, inneighbors)
                t6 = @inferred LET.tree(dg, 6, b2, inneighbors)
                t7 = @inferred LET.tree(p3)
                t8 = @inferred LET.tree(p4)
                @test t5 == t6 == t7 == t8
            end
        end
    end
    @testset "DFS" begin
        g1 = binary_tree(3)
        dg1 = DiGraph(g1)
        for e in edges(dg1)
            if src(e) > dst(e)
                rem_edge!(dg1, e)
            end
        end

        d = LET.DFS()
        @testset "undirected" begin
            for g in testgraphs(g1)
                v1 = @inferred LET.visited_vertices(g, 1, d)
                v2 = @inferred LET.visited_vertices(g, [1], d)
                @test v1 == v2 == [1, 3, 7, 6, 2, 5, 4]
                p1 = @inferred LET.parents(g, 2, d)
                @test p1 == [2, 0, 1, 2, 2, 3, 3]

                t1 = @inferred LET.tree(g, 2, d)
                t2 = @inferred LET.tree(p1)
                @test t1 == t2
            end
        end
        @testset "directed" begin
            for dg in testgraphs(dg1)
                dg2 = copy(dg)
                add_edge!(dg2, 6, 1)
                v1 = @inferred LET.visited_vertices(dg, 1, d)
                v2 = @inferred LET.visited_vertices(dg, [1], d)
                @test v1 == v2 == [1, 3, 7, 6, 2, 5, 4]

                p1 = @inferred LET.parents(dg, 2, d)
                @test p1 == [0, 0, 0, 2, 2, 0, 0]

                ts1 = @inferred LET.topological_sort(dg)
                @test ts1 == [1, 2, 4, 5, 3, 6, 7]
                @test_throws LET.CycleError topological_sort(dg2)

                t1 = @inferred LET.tree(dg, 2, d)
                t2 = @inferred LET.tree(p1)
                @test t1 == t2

                @test !LET.is_cyclic(dg1)
                @test LET.is_cyclic(dg2)
            end
        end
    end
end

