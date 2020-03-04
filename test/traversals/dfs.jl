@testset "DFS" begin

  g5 = SimpleDiGraph(4)
  add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
  gx = cycle_digraph(3)

  @testset "dfs_tree" begin
    for g in testdigraphs(g5)
      z = @inferred(dfs_tree(g, 1))
      @test ne(z) == 3 && nv(z) == 4
      @test !has_edge(z, 1, 3)
      @test !is_cyclic(g)
    end
  end

  @testset "topological_sort_by_dfs" begin
    for g in testdigraphs(g5)
      @test @inferred(topological_sort_by_dfs(g)) == [1, 2, 3, 4]
    end

    for g in testdigraphs(gx)
      @test @inferred(is_cyclic(g))
      @test_throws Exception topological_sort_by_dfs(g)      
    end
  end

  @testset "is_cyclic" begin
    for g in testgraphs(path_graph(2))
      @test @inferred(is_cyclic(g))
      @test @inferred(!is_cyclic(zero(g)))
    end
  end

end
