@testset "DFS" begin
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    for g in testdigraphs(g5)
        z = @inferred(dfs_tree(g, 1))
        @test ne(z) == 3 && nv(z) == 4
        @test !has_edge(z, 1, 3)

        @test @inferred(topological_sort_by_dfs(g)) == [1, 2, 3, 4]
        @test !is_cyclic(g)
    end

    gx = CycleDiGraph(3)
    for g in testdigraphs(gx)
        @test @inferred(is_cyclic(g))
        @test_throws ErrorException topological_sort_by_dfs(g)
    end

    for g in testgraphs(PathGraph(2))
        @test @inferred(is_cyclic(g))
        @test @inferred(!is_cyclic(zero(g)))
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

    # Cases of haspath(g, v, v)
    # Undirected
    for i in 1:4
        gx = CycleGraph(i) 
        for g in testgraphs(gx)
            if i <= 2
                @test !has_path(g, 1, 1)
            else
                @test has_path(g, 1, 1)
            end

            if i == 4
                @test !has_path(g, 1, 1; exclude_vertices=[2]) 
            end
        end
    end
    # Directed
    for i in 1:3
        gx = CycleDiGraph(i)
        if i == 1
            @test !has_path(gx, 1, 1)
        else
            @test has_path(gx, 1, 1)
        end
    end
    # Self Loop
    gx = SimpleDiGraph(Edge{Int}.([(1, 1)]))
    @test has_path(gx, 1, 1)
    @test !has_path(PathGraph(30),15,15)
end
