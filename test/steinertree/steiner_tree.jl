@testset "Steiner Tree" begin
    
    function sum_weight(g::AbstractGraph{<:Integer}, distmx::AbstractMatrix{<:Integer} = weights(g))
        sum_wt = zero(eltype(g))
        for e in edges(g)
            sum_wt += distmx[src(e), dst(e)]
        end
        return sum_wt
    end

    approx_factor(t::Integer) = 2-2/t

    g3 = StarGraph(5) 
    for g in testgraphs(g3)
        g_st = @inferred(steiner_tree(g, [2, 5]))
        @test ne(g_st) == 2 # [Edge(2, 1), Edge(1, 5)]

        g_copy = SimpleGraph(g)
        LightGraphs.filter_non_term_leaves!(g_copy, [2, 5])
        @test ne(g_copy) == 2 # [Edge(2, 1), Edge(1, 5)]
    end

    g4 = PathGraph(11) 
    for g in testgraphs(g4)
        g_st = @inferred(steiner_tree(g, [4, 8]))
        @test ne(g_st) == 4

        g_copy = SimpleGraph(g)
        LightGraphs.filter_non_term_leaves!(g_copy, [4, 8])
        @test ne(g_copy) == 4
    end


    g5 = Grid([5, 5])
    for g in testgraphs(g5)
        g_st = @inferred(steiner_tree(g, [3, 11, 15, 23]))
        @test sum_weight(g_st) == 8 
    end

    d = [0   2   3   4   5
         2   0   60   80  1
         3   60   0  120  150
         4   80  120  0  200
         5  1  150  200  0]

    g6 = CompleteGraph(5) 

    for g in testgraphs(g6)
        g_st = @inferred(steiner_tree(g, [2, 4, 5], d))
        @test sum_weight(g_st, d) <= approx_factor(3)*(1+2+4)
    end

    d[2, 5] = d[5, 2] = 100

    for g in testgraphs(g6)
        g_st = @inferred(steiner_tree(g, [2, 4, 5], d))
        @test sum_weight(g_st, d) <= approx_factor(3)*(2+4+5)
    end



end
