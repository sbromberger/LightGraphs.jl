import LightGraphs: tree
@testset "BFS" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    g6 = smallgraph(:house)

    for g in testdigraphs(g5)
        z = @inferred(bfs_tree(g, 1))
        t = bfs_parents(g, 1)
        @test t == [1, 1, 1, 3]
        @test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
    end
    for g in testgraphs(g6)
        @test @inferred(gdistances(g, 2)) == @inferred(gdistances(g, 2; sort_alg = MergeSort)) == [1, 0, 2, 1, 2]
        @test @inferred(gdistances(g, [1, 2])) == [0, 0, 1, 1, 2]
        @test @inferred(gdistances(g, [])) == fill(typemax(eltype(g)), 5)
    end

    gx = SimpleGraph(5)
    add_edge!(gx, 1, 2); add_edge!(gx, 1, 4)
    add_edge!(gx, 2, 3); add_edge!(gx, 2, 5)
    add_edge!(gx, 3, 4)

    for g in testgraphs(gx)
        @test @inferred(is_bipartite(g))
    end


    # import LightGraphs: TreeBFSVisitorVector, bfs_tree!, tree

    function istree(parents::Vector{T}, maxdepth, n::T) where T<:Integer
        flag = true
        for i in one(T):n
            s = i
            depth = 0
            while parents[s] > 0 && parents[s] != s
                s = parents[s]
                depth += 1
                if depth > maxdepth
                    return false
                end
            end
        end
        return flag
    end

    for g in testgraphs(g6)
        n = nv(g)
        parents = bfs_parents(g, 1)
        @test length(parents) == n
        t1 = @inferred(bfs_tree(g, 1))
        t2 = tree(parents)
        @test t1 == t2
        @test is_directed(t2)
        @test typeof(t2) <: AbstractGraph
        @test ne(t2) < nv(t2)
    end


    gx = SimpleGraph(6)
    d = nv(gx)
    for (i, j) in [(1, 2), (2, 3), (2, 4), (4, 5), (3, 5)]
        add_edge!(gx, i, j)
    end
    for g in testgraphs(gx)  
        @test has_path(g, 1, 5)
        @test has_path(g, 1, 2)
        @test has_path(g, 1, 5; exclude_vertices=[3])
        @test has_path(g, 1, 5; exclude_vertices=[4])
        @test !has_path(g, 1, 5; exclude_vertices=[3, 4])
        @test has_path(g, 5, 1)
        @test has_path(g, 5, 1; exclude_vertices=[3])
        @test has_path(g, 5, 1; exclude_vertices=[4])
        @test !has_path(g, 5, 1; exclude_vertices=[3, 4])
        
        # Edge cases
        @test !has_path(g, 1, 6)
        @test !has_path(g, 6, 1)  
        @test !has_path(g, 1, 1) # inseparable 
        @test !has_path(g, 1, 2; exclude_vertices=[2])
        @test !has_path(g, 1, 2; exclude_vertices=[1])

	add_edge!(g, 1, 1)
	@test has_path(g, 1, 1)
    end
    for g in testgraphs(CycleGraph(3))
        @test has_path(g, 1, 1)
    end
end
