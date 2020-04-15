@testset "communities" begin
    @testset "Clique percolation" begin
        function setofsets(array_of_arrays)
            Set(map(BitSet, array_of_arrays))
        end

        function test_cliques(graph, expected)
            # Make test results insensitive to ordering
            Set(LCOM.communities(graph, LCOM.CliquePercolation())) == setofsets(expected)
        end

        g = Graph(5)
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 1)
        add_edge!(g, 1, 4)
        add_edge!(g, 4, 5)
        add_edge!(g, 5, 1)
        @test test_cliques(g, Array[[1, 2, 3], [1, 4, 5]])
    end

    @testset "Label propagation" begin
        n = 10
        g10 = complete_graph(n)
        @testset "$g" for g in testgraphs(g10)
            z = copy(g)
            for k = 2:5
                z = blockdiag(z, g)
                add_edge!(z, (k - 1) * n, k * n)
                c, ch = @inferred(LCOM.communities(z, LCOM.LabelPropagation()))
                a = collect(n:n:(k * n))
                a = Int[div(i - 1, n) + 1 for i = 1:(k * n)]
                # check the number of communities
                @test length(unique(a)) == length(unique(c))
                # check the partition
                @test a == c
            end
        end
    end
end
