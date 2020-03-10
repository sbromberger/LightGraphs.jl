@testset "Minimal Dominating Set" begin


    g0 = SimpleGraph(0)
    for g in testgraphs(g0)
        for parallel in [:threads, :distributed]
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            @test isempty(d)
        end
    end

    g1 = SimpleGraph(1)
    for g in testgraphs(g1)
        for parallel in [:threads, :distributed]
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            @test (d == [1])

            add_edge!(g, 1, 1)
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            @test (d == [1])
        end
    end

    g3 = star_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g3)
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            @test (length(d) == 1 || (length(d) == 4 && minimum(d) > 1))
        end
    end

    g4 = complete_graph(5)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g4)
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            @test length(d) == 1 #Exactly one vertex
        end
    end

    g5 = path_graph(4)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            sort!(d)
            @test (
                d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4]
            )
        end
    end

    add_edge!(g5, 2, 2)
    add_edge!(g5, 3, 3)
    for parallel in [:threads, :distributed]
        for g in testgraphs(g5)
            d = @inferred(Parallel.dominating_set(
                g,
                4,
                MinimalDominatingSet();
                parallel = parallel,
                seed = 0,
            ))
            sort!(d)
            @test (
                d == [1, 2, 4] || d == [1, 3] || d == [1, 4] || d == [2, 3] || d == [2, 4]
            )
        end
    end
end
