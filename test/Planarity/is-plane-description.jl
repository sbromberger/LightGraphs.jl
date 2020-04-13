@testset "is plane description" begin

    # first test: K_5
    g1 = complete_graph(5)
    g1_desc = [[2,3,4,5], [1,3,4,5], [1,2,4,5], [1,2,3,5], [1,2,3,4]]
    for g in testgraphs(g1)
        # Testing if g1_desc is a plane description of g1   
        res1 = is_plane_description(g, g1_desc)
        @test res1 == false # there is no plane description to the graph K_{5}
    end

    # second test: K_3,3
    g2 = complete_bipartite_graph(3, 3)
    g2_desc = [[4,5,6], [4,5,6], [4,5,6], [1,2,3], [1,2,3], [1,2,3]]
    for g in testgraphs(g2)
        # Testing if g2_desc ia a plane description of g2
        res2 = is_plane_description(g, g2_desc) 
        @test res2 == false # there is no plane description to the graph K_{3,3}
    end

    # third test: an arbitrary planar graph
    g3_edges = Edges.([(1,2), (1,7), (2,4), (2,3), (3,4), (3,5), 
            (4,5), (5,6), (5,11), (6,8), (6,11), (7,8),
            (7,9), (9,10), (9,11), (10,11)])

    g3_desc = [[2,7], [1,4,3], [2,4,5], [2,5,3], [3,4,11,6], 
              [5,11,8], [1,8,9], [6,7], [7,10,11], [9,11], [9,10,6,5]]
    g3 = SimpleGraph(g3_edges)

    for g in testgraphs(g3)
        # Testing if the description g3_desc is a plane description of g3
        res3 = is_plane_description(g, g3_desc)
        @test res3 == true
    end

    # fourth test: K_4
    g4 = complete_graph(4)
    g4_desc = [[2,4,3], [3,4,1], [1,4,2], [1,2,3]]

    for g in testgraphs(g4)
        # Testing if the description g4_desc is a plane description of g4
        res4 = is_plane_description(g, g4_desc)
        @test res4 == true
    end

    # fifth test: K_4
    g5 = complete_graph(4)
    g5_desc = [[2,3,4], [3,4,1], [4,1,2], [1,2,3]]

    for g in testgraphs(g5)
        # Testing if the description g5_desc is a plane description of g5
        res5 = is_plane_description(g, g5_desc)
        @test res5 == false
    end
end
