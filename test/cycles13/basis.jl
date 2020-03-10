@testset "Cycle Basis" begin

    function evaluate(x, y)
        x_sorted = sort(sort.(x))
        y_sorted = sort(sort.(y))
        @test x_sorted == y_sorted
    end

    # No Edges
    ex = Graph(1)
    expected_cyclebasis = Array{Int64,1}[]
    @testset "no edges" for g in testgraphs(ex)
        ex_cyclebasis = @inferred cycle_basis(g)
        @test isempty(ex_cyclebasis)
    end

    # Only one self-edge
    elist = [(1, 1)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[[1]]
    @testset "one self-edge" for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis, expected_cyclebasis)
    end

    # Graph with one cycle
    elist = [(1, 2), (2, 3), (3, 4), (4, 1), (1, 5)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[[1, 2, 3, 4]]
    @testset "one cycle" for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis, expected_cyclebasis)
    end

    # Graph with 2 of 3 cycles forming a basis
    elist = [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[[2, 3, 4], [2, 1, 3]]
    @testset "2 of 3 cycles w/ basis" for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis, expected_cyclebasis)
    end

    # Testing root argument
    elist = [(1, 2), (1, 3), (2, 3), (2, 4), (3, 4), (1, 5), (5, 6), (6, 4)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[[2, 4, 3], [1, 5, 6, 4, 3], [1, 2, 3]]
    @testset "root argument" for g in testgraphs(ex)
        ex_cyclebasis = @inferred cycle_basis(g, 3)
        evaluate(ex_cyclebasis, expected_cyclebasis)
    end

    @testset "two isolated cycles" begin
        ex = blockdiag(cycle_graph(3), cycle_graph(4))
        expected_cyclebasis = [[1, 2, 3], [4, 5, 6, 7]]
        for g in testgraphs(ex)
            found_cyclebasis = @inferred cycle_basis(g)
            evaluate(expected_cyclebasis, found_cyclebasis)
        end
    end
end
