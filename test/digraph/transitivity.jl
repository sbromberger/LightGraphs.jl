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
        # transitive reduction of the nullgraph is again a nullgraph
        nullgraph = SimpleDiGraph(0)
        for g in testdigraphs(nullgraph)
            @test g == @inferred(transitivereduction(g))
        end
        
        # transitive reduction of a path is a path again
        pathgraph = PathDiGraph(10)
        for g in testdigraphs(pathgraph)
            @test g == @inferred(transitivereduction(g))
        end
        
        # transitive reduction of the transitive closure of a path is a path again
        for g in testdigraphs(pathgraph)
            gclosure = transitiveclosure(g)
            @test g == @inferred(transitivereduction(gclosure))
        end

        # Transitive reduction of a complete graph should be s simple cycle
        completegraph = CompleteDiGraph(9)
        for g in testdigraphs(completegraph)
            greduced = @inferred(transitivereduction(g))
            @test length(strongly_connected_components(greduced)) == 1 &&
                ne(greduced) == nv(g)
        end

        # transitive reduction a graph with no edges is the same graph again
        noedgegraph = SimpleDiGraph(7)
        for g in testdigraphs(noedgegraph)
            @test g == @inferred(transitivereduction(g))
        end
         
        # transitve reduction should maintain a selfloop only when selflooped==true
        selfloopgraph = SimpleDiGraph(1)
        add_edge!(selfloopgraph, 1, 1)
        for g in testdigraphs(selfloopgraph)
            @test g == @inferred(transitivereduction(g; selflooped=true));
            @test g != @inferred(transitivereduction(g; selflooped=false));
        end

        # transitive should not maintain selfloops for strongly connected components
        # of size > 1
        selfloopgraph2 = SimpleDiGraph(2)
        add_edge!(selfloopgraph2, 1, 1)
        add_edge!(selfloopgraph2, 1, 2)
        add_edge!(selfloopgraph2, 2, 1)
        add_edge!(selfloopgraph2, 2, 2)
        for g in testdigraphs(selfloopgraph2)
            @test g != @inferred(transitivereduction(g; selflooped=true));
        end

        # directed barbell graph should result in two cycles connected by a single edge
        barbellgraph = SimpleDiGraph(9)
        for i in 1:4, j in 1:4
            i == j && continue
            add_edge!(barbellgraph, i, j)
            add_edge!(barbellgraph, j, i)
        end
        for i in 5:9, j in 5:9
            i == j && continue
            add_edge!(barbellgraph, i, j)
            add_edge!(barbellgraph, j, i)
        end
        add_edge!(barbellgraph, 1, 5);
        for g in testdigraphs(barbellgraph)
            greduced = @inferred(transitivereduction(g))
            scc = strongly_connected_components(greduced)
            @test Set(scc) == Set([[1:4;], [5:9;]])
            @test ne(greduced) == 10
            @test length(weakly_connected_components(greduced)) == 1
        end
    end
end
