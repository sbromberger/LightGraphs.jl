@testset "Transitivity" begin
    completedg = complete_digraph(4)
    circledg = path_digraph(4)
    add_edge!(circledg, 4, 1)
    @testset "$circle" for circle in testgraphs(circledg)
        T = eltype(circle)
        complete = DiGraph{T}(completedg)
        @testset "no self-loops" begin
            newcircle = @inferred(transitiveclosure(circle))
            @test newcircle == complete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c))
            @test ne(c) == ne(newcircle) == 12
        end

        loopedcomplete = copy(complete)
        for i in vertices(loopedcomplete)
            add_edge!(loopedcomplete, i, i)
        end
        @testset "self-loops" begin
            newcircle = @inferred(transitiveclosure(circle, true))
            @test newcircle == loopedcomplete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(transitiveclosure!(c, true))
            @test ne(c) == ne(newcircle) == 16
        end
    end

    # transitivereduction
    @testset "Transitive Reduction" begin
        # transitive reduction of the nullgraph is again a nullgraph
        @testset "nullgraph reduction" begin
            nullgraph = SimpleDiGraph(0)
            @testset "g" for g in testgraphs(nullgraph)
                @test g == @inferred(transitivereduction(g))
            end
        end
        
        # transitive reduction of a path is a path again
        @testset "pathgraph reduction" begin
            pathgraph = path_digraph(10)
            @testset "$g" for g in testgraphs(pathgraph)
                @test g == @inferred(transitivereduction(g))

                # transitive reduction of the transitive closure of a path is a path again
                gclosure = transitiveclosure(g)
                @test g == @inferred(transitivereduction(gclosure))
            end
        end
        
        # Transitive reduction of a complete graph should be s simple cycle
        @testset "completegraph reduction" begin
            completegraph = complete_digraph(9)
            @testset "$g" for g in testgraphs(completegraph)
                greduced = @inferred(transitivereduction(g))
                @test length(strongly_connected_components(greduced)) == 1 &&
                    ne(greduced) == nv(g)
            end
        end

        # transitive reduction a graph with no edges is the same graph again
        @testset "zero-edge reduction" begin
        noedgegraph = SimpleDiGraph(7)
            @testset "$g" for g in testgraphs(noedgegraph)
                @test g == @inferred(transitivereduction(g))
            end
        end
         
        # transitve reduction should maintain a selfloop only when selflooped==true
        @testset "selfloops reduction" begin
            selfloopgraph = SimpleDiGraph(1)
            add_edge!(selfloopgraph, 1, 1)
            @testset "$g" for g in testgraphs(selfloopgraph)
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
            @testset "$g" for g in testgraphs(selfloopgraph2)
                @test g != @inferred(transitivereduction(g; selflooped=true));
            end
        end

        # directed barbell graph should result in two cycles connected by a single edge
        @testset "barbell" begin
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
            @testset "$g" for g in testgraphs(barbellgraph)
                greduced = @inferred(transitivereduction(g))
                scc = strongly_connected_components(greduced)
                @test Set(scc) == Set([[1:4;], [5:9;]])
                @test ne(greduced) == 10
                @test length(weakly_connected_components(greduced)) == 1
            end
        end
    end
end
