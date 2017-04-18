@testset "Articulation" begin
    gint = Graph(13)
    add_edge!(gint, 1, 7)
    add_edge!(gint, 1, 2)
    add_edge!(gint, 1, 3)
    add_edge!(gint, 12, 13)
    add_edge!(gint, 10, 13)
    add_edge!(gint, 10, 12)
    add_edge!(gint, 12, 11)
    add_edge!(gint, 5, 4)
    add_edge!(gint, 6, 4)
    add_edge!(gint, 8, 9)
    add_edge!(gint, 6, 5)
    add_edge!(gint, 1, 6)
    add_edge!(gint, 7, 5)
    add_edge!(gint, 7, 3)
    add_edge!(gint, 7, 8)
    add_edge!(gint, 7, 10)
    add_edge!(gint, 7, 12)

    for g in testgraphs(gint)
      art = @inferred(articulation(g))
      ans = [1, 7, 8, 12]
      @test art == ans
    end
    for level in 1:6
        btree = LightGraphs.BinaryTree(level)
        for tree in [btree, Graph{UInt8}(btree), Graph{Int16}(btree)]
          artpts = @inferred(articulation(tree))
          @test artpts == collect(1:(2^(level-1)-1))
        end
    end

    hint = LightGraphs.blkdiag(WheelGraph(5), WheelGraph(5))
    add_edge!(hint, 5, 6)
    for h in (hint, Graph{UInt8}(hint), Graph{Int16}(hint))
      @test @inferred(articulation(h)) == [5, 6]
    end
end
