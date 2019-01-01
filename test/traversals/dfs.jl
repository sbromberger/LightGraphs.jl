@testset "DFS" begin
    function is_valid_simple_cycle(g, cycle)
        isempty(cycle) && return false
        length(unique(cycle)) != length(cycle) && return fals
        for i = 1:length(cycle)
            v, w = cycle[[i, mod1(i + 1, length(cycle))]]
            w ∉ outneighbors(g, v) && return false
        end
        return true
    end

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    for g in testdigraphs(g5)
        z = @inferred(dfs_tree(g, 1))
        @test ne(z) == 3 && nv(z) == 4
        @test !has_edge(z, 1, 3)

        @test @inferred(topological_sort_by_dfs(g)) == [1, 2, 3, 4]
        @test !is_cyclic(g)
        @test isempty(@inferred(get_cycle(g)))
    end

    gx = CycleDiGraph(3)
    for g in testdigraphs(gx)
        @test @inferred(is_cyclic(g))
        @test is_valid_simple_cycle(g, @inferred(get_cycle(g)))
        @test_throws ErrorException topological_sort_by_dfs(g)
    end

    gy = PathDiGraph(5)
    add_edge!(gy, 5, 3)
    for g in testdigraphs(gy)
        @test @inferred(is_cyclic(g))
        @test is_valid_simple_cycle(g, @inferred(get_cycle(g)))
        @test isempty(@inferred(get_cycle(g, 1)))
        @test is_valid_simple_cycle(g, @inferred(get_cycle(g, 4)))
        @test @inferred(get_path(g, 1, 5)) == 1:5
        @test isempty(@inferred(get_path(g, 5, 1)))
        @test @inferred(get_path(g, 5, 4)) == [5, 3, 4]
    end

    gz = PathDiGraph(4)
    add_edge!(gz, 3, 2)
    add_edge!(gz, 4, 1)
    for g in testdigraphs(gz)
        cycle = @inferred(get_cycle(g, 1))
        @test is_valid_simple_cycle(g, cycle)
        @test 1 in cycle
    end

    for g in testgraphs(PathGraph(3))
        @test @inferred(is_cyclic(g))
        @test !@inferred(is_cyclic(zero(g)))
        @test isempty(@inferred(get_cycle(zero(g))))
        @test is_valid_simple_cycle(g, @inferred(get_cycle(g)))
        @test is_valid_simple_cycle(g, @inferred(get_cycle(g, 2)))
        @test @inferred(get_path(g, 1, 3)) == 1:3
        @test @inferred(get_path(g, 3, 1)) == [3, 2, 1]
    end
end
