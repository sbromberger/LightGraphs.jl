@testset "Bridge" begin
    gint = SimpleGraph(13)
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
        brd = @inferred(bridge(g))
        ans = [
            Edge(1, 2),
            Edge(2, 1),
            Edge(8, 9),
            Edge(9, 8),
            Edge(7, 8),
            Edge(8, 7),
            Edge(12, 11),
            Edge(11, 12),
        ]
        @test brd == ans
    end
    for level in 1:6
        btree = LightGraphs.BinaryTree(level)
        for tree in [btree, Graph{UInt8}(btree), Graph{Int16}(btree)]
            brd = @inferred(bridge(tree))
            ans = collect(edges(tree))
            @test Set(brd) == Set(ans)
        end
    end

    hint = blockdiag(WheelGraph(5), WheelGraph(5))
    add_edge!(hint, 5, 6)
    for h in (hint, Graph{UInt8}(hint), Graph{Int16}(hint))
        @test @inferred(bridge(h)) == [
            Edge(5, 6),
            Edge(6, 5),
        ]
    end
end
