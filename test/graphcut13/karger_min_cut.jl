@testset "Karger Minimum Cut" begin

    gx = path_graph(5)

    #Assumes cut[1] = 1
    for g in testgraphs(gx)
        cut = @inferred(karger_min_cut(g))
        @test findfirst(isequal(2), cut) == findlast(isequal(1), cut) + 1
        @test karger_cut_cost(g, cut) == 1
        @test karger_cut_edges(g, cut) ==
              [Edge(findlast(isequal(1), cut), findfirst(isequal(2), cut))]
    end

    add_vertex!(gx)

    for g in testgraphs(gx)
        cut = @inferred(karger_min_cut(g))
        @test cut == [1, 1, 1, 1, 1, 2]
        @test karger_cut_cost(g, cut) == 0
        @test karger_cut_edges(g, cut) == Vector{Edge}()

    end

    gx = star_graph(5)
    for g in testgraphs(gx)
        cut = @inferred(karger_min_cut(g))
        @test count(isequal(2), cut) == 1
        @test karger_cut_cost(g, cut) == 1
        @test karger_cut_edges(g, cut) == [Edge(1, findfirst(isequal(2), cut))]
    end

    gx = SimpleGraph(1)
    for g in testgraphs(gx)
        cut = @inferred(karger_min_cut(g))
        @test cut == zeros(Int, 1)
    end

end
