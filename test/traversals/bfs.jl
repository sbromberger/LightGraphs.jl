@testset "BFS" begin
    g5 = DiGraph(4)
    add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)

    z = bfs_tree(g5, 1)
    visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int,nv(g5)))
    LightGraphs.bfs_tree!(visitor, g5, 1)
    t = visitor.tree
    @test t == [1,1,1,3]
    @test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)

    @test gdistances(g6, 2) == [1, 0, 2, 1, 2]
    @test gdistances(g6, [1,2]) == [0, 0, 1, 1, 2]
    @test gdistances(g6, []) == [-1, -1, -1, -1, -1]
    @test !is_bipartite(g6)
    @test !is_bipartite(g6, 2)

    g = Graph(5)
    add_edge!(g,1,2); add_edge!(g,1,4)
    add_edge!(g,2,3); add_edge!(g,2,5)
    add_edge!(g,3,4)
    @test is_bipartite(g)
    @test is_bipartite(g, 2)


    import LightGraphs: TreeBFSVisitorVector, bfs_tree!, tree

    function istree(parents::Vector{Int}, maxdepth)
        flag = true
        for i in 1:n
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

    n = nv(g6)
    visitor = TreeBFSVisitorVector(n)
    @test length(visitor.tree) == n
    parents = visitor.tree
    bfs_tree!(visitor, g6, 1)

    @test istree(parents, n) == true
    t = tree(parents)
    @test typeof(t) <: DiGraph
    @test ne(t) < nv(t)

    # test Dict{Int,Int}() colormap
    n = nv(g6)
    visitor = TreeBFSVisitorVector(n)
    @test length(visitor.tree) == n
    parents = visitor.tree
    bfs_tree!(visitor, g6, 1, vertexcolormap = Dict{Int,Int}())

    @test istree(parents, n) == true
    t = tree(parents)
    @test typeof(t) <: DiGraph
    @test ne(t) < nv(t)

    g10 = CompleteGraph(10)
    @test bipartite_map(g10) == Vector{Int}()

    g10 = CompleteBipartiteGraph(10,10)
    @test bipartite_map(g10) == Vector{Int}([ones(10); 2*ones(10)])

    h10 = blkdiag(g10,g10)
    @test bipartite_map(h10) == Vector{Int}([ones(10); 2*ones(10); ones(10); 2*ones(10)])
end
