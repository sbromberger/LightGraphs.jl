@testset "Cycle Basis" begin

    function evaluate(x,y)
        @test length(x) == length(y)
        for i=1:length(x)
            @test isempty(setdiff(x[i],y[i]))
            @test isempty(setdiff(x[i],y[i]))
        end
    end

    # No Edges
    ex = Graph(1)
    expected_cyclebasis = Array{Int64,1}[]
    for g in testgraphs(ex)
        ex_cyclebasis = @inferred cycle_basis(g)
        @test isempty(ex_cyclebasis)
    end

    # Only one self-edge
    elist = [(1,1)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[[1]]
    for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis,expected_cyclebasis)
    end

    # Graph with one cycle
    elist = [(1,2),(2,3),(3,4),(4,1),(1,5)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[
        [1,2,3,4] ]
    for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis,expected_cyclebasis)
    end    

    # Graph with 2 of 3 cycles forming a basis
    elist = [(1,2),(1,3),(2,3),(2,4),(3,4)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[
        [2,3,4],
        [2,1,3] ]
    for g in testgraphs(ex)
        ex_cyclebasis = cycle_basis(g)
        evaluate(ex_cyclebasis,expected_cyclebasis)
    end

    # Testing root argument
    elist = [(1,2),(1,3),(2,3),(2,4),(3,4),(1,5),(5,6),(6,4)]
    ex = Graph(SimpleEdge.(elist))
    expected_cyclebasis = Array{Int64,1}[
        [2, 4, 3],
        [1, 5, 6, 4, 3],
        [1, 2, 3] ]
    for g in testgraphs(ex)
        ex_cyclebasis = @inferred cycle_basis(g,3)
        evaluate(ex_cyclebasis,expected_cyclebasis)
    end
end
