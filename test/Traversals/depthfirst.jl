@testset "DepthFirst" begin

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    gx = cycle_digraph(3)

    @testset "dfs tree" begin
        for g in testdigraphs(g5)
            z = @inferred(tree(g, 1, DepthFirst()))
            @test ne(z) == 3 && nv(z) == 4
            @test !has_edge(z, 1, 3)
            @test !is_cyclic(g)
        end
    end

    @testset "topological_sort" begin
        for g in testdigraphs(g5)
            @test @inferred(topological_sort(g)) == [1, 2, 3, 4]
        end

        for g in testdigraphs(gx)
            @test @inferred(is_cyclic(g))
            @test_throws CycleError topological_sort(g)
        end
    end

    @testset "is_cyclic" begin
        for g in testgraphs(path_graph(2))
            @test @inferred(is_cyclic(g))
            @test @inferred(!is_cyclic(zero(g)))
        end
        for g in testgraphs(wheel_digraph(10))
            @test is_cyclic(g)
        end
        for g in testgraphs(star_digraph(10))
            @test !is_cyclic(g)
        end
    end

    @testset "visited_vertices" begin
        gt = binary_tree(3)
        for g in testgraphs(gt)
            @test visited_vertices(g, 1, DepthFirst()) == [1, 2, 4, 5, 3, 6, 7]
        end
    end
end
