for alg in [LC.Tarjan, LC.Kosaraju]
    @testset "$alg" begin
        g6 = smallgraph(:house)
        gx = path_graph(4)
        add_vertices!(gx, 10)
        add_edge!(gx, 5, 6)
        add_edge!(gx, 6, 7)
        add_edge!(gx, 8, 9)
        add_edge!(gx, 10, 9)

        @testset "strongly connected components" begin
            # graph from https://en.wikipedia.org/wiki/Strongly_connected_component
            h = SimpleDiGraph(8)
            add_edge!(h, 1, 2); add_edge!(h, 2, 3); add_edge!(h, 2, 5);
            add_edge!(h, 2, 6); add_edge!(h, 3, 4); add_edge!(h, 3, 7);
            add_edge!(h, 4, 3); add_edge!(h, 4, 8); add_edge!(h, 5, 1);
            add_edge!(h, 5, 6); add_edge!(h, 6, 7); add_edge!(h, 7, 6);
            add_edge!(h, 8, 4); add_edge!(h, 8, 7)
            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 3
                @test any(sort(x) == [1, 2, 5] for x in scc)
                if alg == LC.Tarjan
                    scc2 = @inferred(LC.connected_components(g))
                    @test scc == scc2
                end
            end

            function scc_ok(graph)
                #Check that all SCC really are strongly connected
                scc = @inferred(LC.connected_components(graph, alg()))
                scc_as_subgraphs = map(i -> graph[i], scc)
                return all(g->LC.is_connected(g, alg()), scc_as_subgraphs)
            end

            # the two graphs below are isomorphic (exchange 2 <--> 4)
            h = SimpleDiGraph(4);  add_edge!(h, 1, 4); add_edge!(h, 4, 2); add_edge!(h, 2, 3); add_edge!(h, 1, 3);
            @testset "$g" for g in testdigraphs(h)
                @test scc_ok(g)
            end

            h2 = SimpleDiGraph(4); add_edge!(h2, 1, 2); add_edge!(h2, 2, 4); add_edge!(h2, 4, 3); add_edge!(h2, 1, 3);
            @testset "$g" for g in testdigraphs(h2)
                @test scc_ok(g)
            end
        end # scc testset

        @testset "empty graph connectivity" begin
            #Test case for empty graph
            h = SimpleDiGraph(0)
            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 0
            end
        end # empty graph testset

        @testset "single vertex graph connectivity" begin
            h = SimpleDiGraph(1)
            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 1 && scc[1] == [1]
            end
        end

        @testset "self loop connectivity" begin
            h = SimpleDiGraph(3);
            add_edge!(h, 1, 1); add_edge!(h, 2, 2); add_edge!(h, 3, 3);
            add_edge!(h, 1, 2); add_edge!(h, 2, 3); add_edge!(h, 2, 1);

            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 2
                sort!(scc, by=length)
                @test scc[1] == [3]
                @test sort(scc[2]) == [1,2]
            end
        end

        @testset "more digraphs" begin
            h = SimpleDiGraph(6)
            add_edge!(h, 1, 3); add_edge!(h, 3, 4); add_edge!(h, 4, 2); add_edge!(h, 2, 1)
            add_edge!(h, 3, 5); add_edge!(h, 5, 6); add_edge!(h, 6, 4)
            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 1 && sort(scc[1]) == [1:6;]
            end
            h = SimpleDiGraph(12)
            add_edge!(h, 1, 2); add_edge!(h, 2, 3); add_edge!(h, 2, 4); add_edge!(h, 2, 5);
            add_edge!(h, 3, 6); add_edge!(h, 4, 5); add_edge!(h, 4, 7); add_edge!(h, 5, 2);
            add_edge!(h, 5, 6); add_edge!(h, 5, 7); add_edge!(h, 6, 3); add_edge!(h, 6, 8);
            add_edge!(h, 7, 8); add_edge!(h, 7, 10); add_edge!(h, 8, 7); add_edge!(h, 9, 7);
            add_edge!(h, 10, 9); add_edge!(h, 10, 11); add_edge!(h, 11, 12); add_edge!(h, 12, 10)

            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                sort!(scc, by=length)
                @test length(scc) == 4
                @test scc[1] == [1]
                @test sort(scc[2]) == [3, 6]
                @test sort(scc[3]) == [2, 4, 5]
                @test sort(scc[4]) == [7, 8, 9, 10, 11, 12]
            end
        end # other digraphs

        @testset "from Graphs.jl" begin
            h = SimpleDiGraph(4)
            add_edge!(h, 1, 2); add_edge!(h, 2, 3); add_edge!(h, 3, 1); add_edge!(h, 4, 1)
            @testset "$g" for g in testdigraphs(h)
                scc = @inferred(LC.connected_components(g, alg()))
                @test length(scc) == 2
                sort!(scc, by=length)
                @test scc[1] == [4] && sort(scc[2]) == [1:3;]
            end
        end # Graphs.jl testset

        @testset "JarvisShier scc" begin
            # Test examples with self-loops from
            # Graph-Theoretic Analysis of Finite Markov Chains by J.P. Jarvis & D. R. Shier

            # figure 1 example
            fig1 = spzeros(5, 5)
            fig1[[3, 4, 9, 10, 11, 13, 18, 19, 22, 24]] = [.5, .4, .1, 1., 1., .2, .3, .2, 1., .3]
            fig1 = SimpleDiGraph(fig1)
            scc_fig1 = Vector[[2, 5], [1, 3, 4]]

            # figure 2 example
            fig2 = spzeros(5, 5)
            fig2[[3, 10, 11, 13, 14, 17, 18, 19, 22]] .= 1
            fig2 = SimpleDiGraph(fig2)

            # figure 3 example
            fig3 = spzeros(8, 8)
            fig3[[1, 7, 9, 13, 14, 15, 18, 20, 23, 27, 28, 31, 33, 34, 37, 45, 46, 49, 57, 63, 64]] .= 1
            fig3 = SimpleDiGraph(fig3)
            scc_fig3 = Vector[[3, 4], [2, 5, 6], [8], [1, 7]]
            fig3_cond = SimpleDiGraph(4);
            add_edge!(fig3_cond, 4, 3); add_edge!(fig3_cond, 2, 1)
            add_edge!(fig3_cond, 4, 1); add_edge!(fig3_cond, 4, 2)


            # construct a n-number edge ring graph (period = n)
            n = 10
            n_ring = cycle_digraph(n)
            n_ring_shortcut = copy(n_ring); add_edge!(n_ring_shortcut, 1, 4)


            # figure 8 example
            fig8 = spzeros(6, 6)
            fig8[[2, 10, 13, 21, 24, 27, 35]] .= 1
            fig8 = SimpleDiGraph(fig8)

            @test Set(@inferred(LC.connected_components(fig1, alg()))) == Set(scc_fig1)
            @test Set(@inferred(LC.connected_components(fig3, alg()))) == Set(scc_fig3)

            @test @inferred(LC.period(n_ring, alg())) == @inferred(LC.period(n_ring)) == n
            @test @inferred(LC.period(n_ring_shortcut, alg())) == 2

            c = @inferred(LC.condensation(fig3, alg()))
            c2 = @inferred(LC.condensation(fig3))
            @test sort(degree(c)) == sort(degree(c2)) == sort(degree(fig3_cond))

            @test @inferred(LC.attracting_components(fig1, alg())) == Vector[[2, 5]]
            ac = @inferred(LC.attracting_components(fig3, alg())) 
            ac2 = @inferred(LC.attracting_components(fig3))
            sort!(ac, by=length)
            sort!(ac2, by=length)
            @test ac[1] == ac2[1] == [8]
            @test sort(ac[2]) == sort(ac2[2]) == [3, 4]
        end # JarvisShier scc testset
    end
end # for loop
