@testset "Transitivity" begin
    completedg = CompleteDiGraph(4)
    circledg = PathDiGraph(4)
    add_edge!(circledg, 4, 1)
    for circle in testdigraphs(circledg)
        T = eltype(circle)
        complete = DiGraph{T}(completedg)
        newcircle = @inferred(transitiveclosure(circle))
        @test newcircle == complete
        @test ne(circle) == 4
        @test newcircle == @inferred(transitiveclosure!(circle))
        @test ne(circle) == 12
    end

    loopedcompletedg = copy(completedg)
    for i in vertices(loopedcompletedg)
        add_edge!(loopedcompletedg, i, i)
    end
    circledg = PathDiGraph(4)
    add_edge!(circledg, 4, 1)
    for circle in testdigraphs(circledg)
        T = eltype(circle)
        loopedcomplete = DiGraph{T}(loopedcompletedg)
        newcircle = @inferred(transitiveclosure(circle, true))
        @test newcircle == loopedcomplete
        @test ne(circle) == 4
        @test newcircle == @inferred(transitiveclosure!(circle, true))
        @test ne(circle) == 16
    end

    # transitivereduction
    let
        nullgraph = SimpleDiGraph(0)
        pathgraph = SimpleDiGraph(10)
        pathgraph_closure = transitiveclosure(pathgraph)
        complete_graph = CompleteDiGraph(9)
        complete_graph_reduced = transitivereduction(complete_graph)
        no_edge_graph = SimpleDiGraph(7)
        self_loop_graph = SimpleDiGraph(1)
        add_edge!(self_loop_graph, 1, 1)
        
        barbell_graph = SimpleDiGraph(9)
        for i in 1:4, j in 1:4
            i == j && continue
            add_edge!(barbell_graph, i, j)
        end
        barbell_graph = SimpleDiGraph(9)
        for i in 1:4, j in 1:4
            i == j && continue
            add_edge!(barbell_graph, i, j)
        end
        for i in 5:9, j in 5:9
            i == j && continue
            add_edge!(barbell_graph, i, j)
        end
        add_edge!(barbell_graph, 1,5);

        # transitive reduction of a the nullgraph is again a nullgraph
        @test nullgraph == transitivereduction(nullgraph)

        # transitive reduction of a path is a path again
        @test pathgraph == transitivereduction(pathgraph)

        # transitive reduction of a the transtitve closure of a path is the same path again
        @test pathgraph == transitivereduction(pathgraph_closure)
        for pathgraph2 in testdigraphs(pathgraph)
            pathgraph_reduced = @inferred(transitivereduction(pathgraph2))
            @test pathgraph2 == pathgraph_reduced
        end

        # Transitive reduction of a complete graph should be s simple cycle
        @test length(strongly_connected_components(complete_graph_reduced)) == 1 &&
            ne(complete_graph_reduced) == nv(complete_graph)

        # transitive reduction a graph with no edges is the same graph again
        @test no_edge_graph == transitivereduction(no_edge_graph)

        # transitve reduction should maintain a selfloop only when selflooped==true
        @test self_loop_graph == transitivereduction(self_loop_graph; selflooped=true)
        @test self_loop_graph != transitivereduction(self_loop_graph; selflooped=false)

        # directed barbell should result in two cycles connected by a single edge
        barbell_graph_reduced = transitivereduction(barbell_graph)
        scc = strongly_connected_components(barbell_graph_reduced)
        @test Set(scc) == Set([[1:4;], [5:9;]])
        @test ne(barbell_graph_reduced) == 10
        @test length(weakly_connected_components(barbell_graph_reduced)) == 1
    end

end
