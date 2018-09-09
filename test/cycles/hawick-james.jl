@testset "Hawick-James Cycles" begin

    # Simple graph gives expected circuits
    ex1 = SimpleDiGraph(5)
    add_edge!(ex1, 1, 2)
    add_edge!(ex1, 2, 3)
    add_edge!(ex1, 3, 4)
    add_edge!(ex1, 3, 5)
    add_edge!(ex1, 4, 5)
    add_edge!(ex1, 5, 2)

    expected_circuits = Vector{Int}[
        [2, 3, 4, 5],
        [2, 3, 5]
    ]
    for g in testdigraphs(ex1)
        ex1_circuits = simplecycles_hawick_james(g)

        @test issubset(expected_circuits, ex1_circuits)
        @test issubset(ex1_circuits, expected_circuits)

        # Adding self-edges gives new circuits
        add_edge!(g, 1, 1)
        add_edge!(g, 3, 3)

        ex1_circuits_self = simplecycles_hawick_james(g)

        @test issubset(expected_circuits, ex1_circuits_self)
        @test [1] ∈ ex1_circuits_self && [3] ∈ ex1_circuits_self
    end

    # Path DiGraph
    ex2_size = 10
    ex2 = testdigraphs(PathDiGraph(ex2_size))
    for g in ex2
        @test isempty(simplecycles_hawick_james(g))
    end

    # Complete DiGraph
    ex3_size = 5
    ex3 = testdigraphs(CompleteDiGraph(ex3_size))
    for g in ex3
        ex3_circuits = simplecycles_hawick_james(g)
        @test length(ex3_circuits) == length(unique(ex3_circuits))
    end

    # Almost fully connected DiGraph
    ex4 = SimpleDiGraph(9)
    for (src, dest) in [(1, 2), (1, 5), (1, 7), (1, 8), (2, 9), (3, 4), (3, 6), 
                        (4, 5), (4, 7), (5, 6), (6, 7), (6, 8), (7, 9), (8, 9)] 
        add_edge!(ex4, src, dest)
        add_edge!(ex4, dest, src)
    end
    for g in testdigraphs(ex4)
        ex4_output = simplecycles_hawick_james(g)
        @test [1, 2] ∈ ex4_output && [8, 9] ∈ ex4_output
    end

    # These test cases cover a bug that occurred in a previous version
    for seed in [1, 2, 3], (n, k) in [(14, 18), (10, 22), (7, 16)]
        g = erdos_renyi(n, k, is_directed=true, seed=seed)
        cycles1 = simplecycles(g)
        cycles2 = simplecycles_hawick_james(g)
        foreach(sort!, cycles1)
        foreach(sort!, cycles2)
        sort!(cycles1)
        sort!(cycles2)
        @test cycles1 == cycles2
    end
end
