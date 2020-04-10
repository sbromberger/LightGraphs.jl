for alg in [LC.DFS, LC.DFSQ, LC.UnionMerge]
    @testset "$alg" begin
        g6 = smallgraph(:house)
        gx = path_graph(4)
        add_vertices!(gx, 10)
        add_edge!(gx, 5, 6)
        add_edge!(gx, 6, 7)
        add_edge!(gx, 8, 9)
        add_edge!(gx, 10, 9)
    
        @testset "basic connectivity" begin
            @testset "$g" for g in testgraphs(gx)
                gc = copy(g)
                @test @inferred(!LC.is_connected(gc, alg()))
                cc = @inferred(LC.connected_components(gc, alg()))
                @test length(cc) >= 3 && sort(cc[3]) == [8, 9, 10]
            end
            @testset "$g" for g in testgraphs(g6)
                gc = copy(g)
                @test @inferred(LC.is_connected(gc, alg()))
            end
        end # basic connectivity testset
    
        @testset "digraphs" begin
            # graph from https://en.wikipedia.org/wiki/Strongly_connected_component
            h = SimpleDiGraph(8)
            add_edge!(h, 1, 2); add_edge!(h, 2, 3); add_edge!(h, 2, 5);
            add_edge!(h, 2, 6); add_edge!(h, 3, 4); add_edge!(h, 3, 7);
            add_edge!(h, 4, 3); add_edge!(h, 4, 8); add_edge!(h, 5, 1);
            add_edge!(h, 5, 6); add_edge!(h, 6, 7); add_edge!(h, 7, 6);
            add_edge!(h, 8, 4); add_edge!(h, 8, 7)
            @testset "$g" for g in testdigraphs(h)
                @test @inferred(LC.is_connected(g, alg()))
                wcc = @inferred(LC.connected_components(g, alg()))
                @test length(wcc) == 1 && length(wcc[1]) == nv(g)
            end
        end
    
        @testset "empty graph connectivity" begin
            #Test case for empty graph
            h = SimpleGraph(0)
            @testset "$g" for g in testgraphs(h)
                cc = @inferred(LC.connected_components(g, alg()))
                @test length(cc) == 0
            end
            h = SimpleDiGraph(0)
            @testset "$g" for g in testdigraphs(h)
                cc = @inferred(LC.connected_components(g, alg()))
                @test length(cc) == 0
            end
        end # empty graph testset
    
        @testset "single vertex graph connectivity" begin
            h = SimpleGraph(1)
            @testset "$g" for g in testgraphs(h)
                cc = @inferred(LC.connected_components(g, alg()))
                @test length(cc) == 1 && cc[1] == [1]
            end
            h = SimpleDiGraph(1)
            @testset "$g" for g in testdigraphs(h)
                cc = @inferred(LC.connected_components(g, alg()))
                @test length(cc) == 1 && cc[1] == [1]
            end
        end
    
        @testset "self loop connectivity" begin
            h = SimpleGraph(3)
            add_edge!(h, 1, 1); add_edge!(h, 2, 2); add_edge!(h, 3, 3); add_edge!(h, 1, 2)
    
            @testset "$g" for g in testdigraphs(h)
                cc = @inferred(LC.connected_components(g, alg()))
                @test length(cc) == 2
                sort!(cc, by=length)
                @test cc[1] == [3]
                @test sort(cc[2]) == [1,2]
            end
        end # self loop testset
    end
end
