@testset "Augment Matching" begin
  
    g3 = StarGraph(5)
    for g in testgraphs(g3)
        m = @inferred(augment_matching(g))
        @test (size(m)[1] == 1 && (m[1].dst == 1 || m[1].src == 1))
    end
    
    g4 = CompleteGraph(7)
    for g in testgraphs(g4)
        m = @inferred(augment_matching(g))
        @test size(m)[1] == 3 #All except one vertex 

        m = @inferred(augment_matching(g, [Edge(2, 4), Edge(1, 7)]))
        @test size(m)[1] == 3
    end

    g5 = PathGraph(4)
    for g in testgraphs(g5)
        m = @inferred(augment_matching(g))
        @test (m == [Edge(1, 2), Edge(3, 4)] || m == [Edge(3, 4), Edge(1, 2)])

        m = @inferred(augment_matching(g, [Edge(2, 3)]))
        @test (m == [Edge(1, 2), Edge(3, 4)] || m == [Edge(3, 4), Edge(1, 2)])
    end
end
