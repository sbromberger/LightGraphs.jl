using LightGraphs.Transitivity
using LightGraphs.Connectivity
using LightGraphs.Connectivity: Tarjan, UnionMerge
const LTR = LightGraphs.Transitivity

@testset "Transitivity" begin
    completedg = complete_digraph(4)
    circledg = path_digraph(4)
    add_edge!(circledg, 4, 1)
    @testset "$circle" for circle in testgraphs(circledg)
        T = eltype(circle)
        complete = DiGraph{T}(completedg)
        @testset "no self-loops" begin
            newcircle = @inferred(LTR.transitive_closure(circle))
            @test newcircle == complete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(LTR.transitive_closure!(c))
            @test ne(c) == ne(newcircle) == 12
        end

        loopedcomplete = copy(complete)
        for i in vertices(loopedcomplete)
            add_edge!(loopedcomplete, i, i)
        end
        @testset "self-loops" begin
            newcircle = @inferred(LTR.transitive_closure(circle, true))
            @test newcircle == loopedcomplete
            @test ne(circle) == 4
            c = copy(circle)
            @test newcircle == @inferred(LTR.transitive_closure!(c, true))
            @test ne(c) == ne(newcircle) == 16
        end
    end

    # LTR.transitive_reduction
    @testset "Transitive Reduction" begin
        # transitive reduction of the nullgraph is again a nullgraph
        @testset "nullgraph reduction" begin
            nullgraph = SimpleDiGraph(0)
            @testset "g" for g in testgraphs(nullgraph)
                @test g == @inferred(LTR.transitive_reduction(g))
            end
        end

        # transitive reduction of a path is a path again
        @testset "pathgraph reduction" begin
            pathgraph = path_digraph(10)
            @testset "$g" for g in testgraphs(pathgraph)
                @test g == @inferred(LTR.transitive_reduction(g))

                # transitive reduction of the transitive closure of a path is a path again
                gclosure = LTR.transitive_closure(g)
                @test g == @inferred(LTR.transitive_reduction(gclosure))
            end
        end

        # Transitive reduction of a complete graph should be s simple cycle
        @testset "completegraph reduction" begin
            completegraph = complete_digraph(9)
            @testset "$g" for g in testgraphs(completegraph)
                greduced = @inferred(LTR.transitive_reduction(g))
                @test length(Connectivity.connected_components(greduced, UnionMerge())) == 1 &&
                    ne(greduced) == nv(g)
            end
        end

        # transitive reduction a graph with no edges is the same graph again
        @testset "zero-edge reduction" begin
        noedgegraph = SimpleDiGraph(7)
            @testset "$g" for g in testgraphs(noedgegraph)
                @test g == @inferred(LTR.transitive_reduction(g))
            end
        end

        # transitve reduction should maintain a selfloop only when selflooped==true
        @testset "selfloops reduction" begin
            selfloopgraph = SimpleDiGraph(1)
            add_edge!(selfloopgraph, 1, 1)
            @testset "$g" for g in testgraphs(selfloopgraph)
                @test g == @inferred(LTR.transitive_reduction(g, true))
                @test g != @inferred(LTR.transitive_reduction(g, false))
            end

        # transitive should not maintain selfloops for strongly connected components
        # of size > 1
            selfloopgraph2 = SimpleDiGraph(2)
            add_edge!(selfloopgraph2, 1, 1)
            add_edge!(selfloopgraph2, 1, 2)
            add_edge!(selfloopgraph2, 2, 1)
            add_edge!(selfloopgraph2, 2, 2)
            @testset "$g" for g in testgraphs(selfloopgraph2)
                @test g != @inferred(LTR.transitive_reduction(g, true))
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
            add_edge!(barbellgraph, 1, 5)
            @testset "$g" for g in testgraphs(barbellgraph)
                greduced = @inferred(LTR.transitive_reduction(g))
                scc = Connectivity.connected_components(greduced, Tarjan())
                @test Set(scc) == Set([[1:4;], [5:9;]])
                @test ne(greduced) == 10
                @test length(Connectivity.connected_components(greduced, UnionMerge())) == 1
            end
        end
    end
end
