@testset "Connectivity" begin
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
            @test @inferred(!LC.is_connected(gc))
            cc = @inferred(LC.connected_components(gc))
            label = zeros(eltype(gc), nv(gc))
            @inferred(LC.connected_components!(label, gc))
            @test label[1:10] == [1, 1, 1, 1, 5, 5, 5, 8, 8, 8]
            cclab = @inferred(LC.components_dict(label))
            @test cclab[1] == [1, 2, 3, 4]
            @test cclab[5] == [5, 6, 7]
            @test cclab[8] == [8, 9, 10]
            @test length(cc) >= 3 && sort(cc[3]) == [8, 9, 10]
        end
        @testset "$g" for g in testgraphs(g6)
            gc = copy(g)
            @test @inferred(LC.is_connected(gc))
        end
    end # basic connectivity testset

    @testset "neighborhood / neighborhood_dists" begin
        g10dists = ones(10, 10)
        g10dists[1,2] = 10.0
        g10 = star_graph(10)
        @testset "$g" for g in testgraphs(g10)
            @test @inferred(LC.neighborhood_dists(g, 1, 0)) == [(1, 0)]
            @test length(@inferred(LC.neighborhood(g, 1, 1))) == 10
            @test length(@inferred(LC.neighborhood(g, 1, 1, g10dists))) == 9
            @test length(@inferred(LC.neighborhood(g, 2, 1))) == 2
            @test length(@inferred(LC.neighborhood(g, 1, 2))) == 10
            @test length(@inferred(LC.neighborhood(g, 2, 2))) == 10
            @test length(@inferred(LC.neighborhood(g, 2, -1))) == 0
        end
        g10 = star_digraph(10)
        @testset "$g" for g in testgraphs(g10)
            @test @inferred(LC.neighborhood_dists(g10, 1, 0; neighborfn=outneighbors)) == [(1, 0)]
            @test length(@inferred(LC.neighborhood(g, 1, 1, neighborfn=outneighbors))) == 10
            @test length(@inferred(LC.neighborhood(g, 1, 1, g10dists, neighborfn=outneighbors))) == 9
            @test length(@inferred(LC.neighborhood(g, 2, 1, neighborfn=outneighbors))) == 1
            @test length(@inferred(LC.neighborhood(g, 1, 2, neighborfn=outneighbors))) == 10
            @test length(@inferred(LC.neighborhood(g, 2, 2, neighborfn=outneighbors))) == 1
            @test @inferred(LC.neighborhood_dists(g, 1, 0, neighborfn=inneighbors)) == [(1, 0)]
            @test length(@inferred(LC.neighborhood(g, 1, 1, neighborfn=inneighbors))) == 1
            @test length(@inferred(LC.neighborhood(g, 2, 1, neighborfn=inneighbors))) == 2
            @test length(@inferred(LC.neighborhood(g, 2, 1, g10dists, neighborfn=inneighbors))) == 2
            @test length(@inferred(LC.neighborhood(g, 1, 2, neighborfn=inneighbors))) == 1
            @test length(@inferred(LC.neighborhood(g, 2, 2, neighborfn=inneighbors))) == 2
        end
        gd = SimpleDiGraph([0 1 1 0; 0 0 0 1; 0 0 0 1; 0 0 0 0])
        add_edge!(gd, 1, 4)
        @testset "$g" for g in testgraphs(gd)
              z = @inferred(LC.neighborhood_dists(g, 1, 4))
              @test (4, 1) ∈ z
              @test (4, 2) ∉ z
        end
        @testset "test #1363" begin
            g = complete_graph(3)
            d = zeros(3, 3)
            d[1, 2] = 10
            d[1, 3] = 1
            d[3, 2] = 1
            @test sort(neighborhood(g, 1, 4, d)) == [1, 2, 3]
        end
        @testset "test #1116" begin
        gc = cycle_graph(4)
            @testset "$g" for g in testgraphs(gc)
                z = @inferred(LC.neighborhood(g, 3, 3))
                @test (z == [3, 2, 4, 1] || z == [3, 4, 2, 1])
            end
        end
    end
    @testset "is_graphical" begin
        @test @inferred(!LC.is_graphical([1, 1, 1]))
        @test @inferred(LC.is_graphical([2, 2, 2]))
        @test @inferred(LC.is_graphical(fill(3, 10)))
    end 
end
