import LightGraphs: TreeBFSVisitorVector, bfs_tree!, tree
@testset "BFS" begin
    g5 = DiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    g6 = smallgraph(:house)

    for g in testdigraphs(g5)
      z = @inferred(bfs_tree(g, 1))
      visitor = LightGraphs.TreeBFSVisitorVector(zeros(eltype(g), nv(g)))
      LightGraphs.bfs_tree!(visitor, g, 1)
      t = visitor.tree
      @test t == [1, 1, 1, 3]
      @test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
    end
    for g in testgraphs(g6)
      @test @inferred(gdistances(g, 2)) == [1, 0, 2, 1, 2]
      @test @inferred(gdistances(g, [1, 2])) == [0, 0, 1, 1, 2]
      @test @inferred(gdistances(g, [])) == [-1, -1, -1, -1, -1]
      @test @inferred(!is_bipartite(g))
      @test @inferred(!is_bipartite(g, 2))
    end

    gx = Graph(5)
    add_edge!(gx, 1, 2); add_edge!(gx, 1, 4)
    add_edge!(gx, 2, 3); add_edge!(gx, 2, 5)
    add_edge!(gx, 3, 4)

    for g in testgraphs(gx)
      @test @inferred(is_bipartite(g))
      @test @inferred(is_bipartite(g, 2))
    end


    # import LightGraphs: TreeBFSVisitorVector, bfs_tree!, tree

    function istree{T<:Integer}(parents::Vector{T}, maxdepth, n::T)
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
      visitor = @inferred(TreeBFSVisitorVector(n))
      @test length(visitor.tree) == n
      parents = visitor.tree
      @inferred(bfs_tree!(visitor, g, 1))

      @test istree(parents, n, n)
      t = tree(parents)
      @test is_directed(t)
      @test typeof(t) <: AbstractGraph
      @test ne(t) < nv(t)

    # test Dict{Int,Int}() colormap

      visitor = @inferred(TreeBFSVisitorVector(n))
      @test length(visitor.tree) == n
      parents = visitor.tree
      @inferred(bfs_tree!(visitor, g, 1, vertexcolormap = Dict{Int,Int}()))

      @test @inferred(istree(parents, n, n))
      t = tree(parents)
      @test is_directed(t)
      @test typeof(t) <: AbstractGraph
      @test ne(t) < nv(t)
    end

    g10 = CompleteGraph(10)
    for g in testgraphs(g10)
      @test @inferred(bipartite_map(g)) == Vector{eltype(g)}()
    end

    g10 = CompleteBipartiteGraph(10, 10)
    for g in testgraphs(g10)
      T = eltype(g)
      @test @inferred(bipartite_map(g10)) == Vector{T}([ones(T, 10); 2 * ones(T, 10)])

      h = blkdiag(g, g)
      @test @inferred(bipartite_map(h)) == Vector{T}([ones(T, 10); 2 * ones(T, 10); ones(T, 10); 2 * ones(T, 10)])
    end

    let g = Graph(6)
        d = nv(g)
        for (i,j) in [(1,2), (2,3), (2,4),(4,5), (3,5)]
            add_edge!(g,i,j)
        end
        @test has_path(g, 1, 5)
        @test has_path(g, 1, 5; exclude_vertices = [3])
        @test has_path(g, 1, 5; exclude_vertices = [4])
        @test !has_path(g, 1, 5; exclude_vertices = [3, 4])
        @test has_path(g, 5, 1)
        @test has_path(g, 5, 1; exclude_vertices = [3])
        @test has_path(g, 5, 1; exclude_vertices = [4])
        @test !has_path(g, 5, 1; exclude_vertices = [3, 4])
        
        # Edge cases
        @test !has_path(g, 1, 6)
        @test !has_path(g, 6, 1)  
        @test has_path(g, 1, 1) # inseparable 
        @test !has_path(g, 1, 2; exclude_vertices = [2])
        @test !has_path(g, 1, 2; exclude_vertices = [1])
    end
end
