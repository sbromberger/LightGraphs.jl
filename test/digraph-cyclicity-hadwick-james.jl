@testset "Hadwick-James Cycles" begin
    hadwick_james_ex1 = DiGraph(5)
    add_edge!(hadwick_james_ex1, 1, 2)
    add_edge!(hadwick_james_ex1, 2, 3)
    add_edge!(hadwick_james_ex1, 3, 4)
    add_edge!(hadwick_james_ex1, 3, 5)
    add_edge!(hadwick_james_ex1, 4, 5)
    add_edge!(hadwick_james_ex1, 5, 2)

    hadwick_circuits = simplecycles_hadwick_james(hadwick_james_ex1)

    expected_circuits = Vector{Int}[
        [2, 3, 4, 5],
        [2, 3, 5]
    ]
    @test issubset(expected_circuits, hadwick_circuits)
    @test issubset(hadwick_circuits, expected_circuits)

    add_edge!(hadwick_james_ex1, 1, 1)
    add_edge!(hadwick_james_ex1, 3, 3)

    hadwick_circuits_self = simplecycles_hadwick_james(hadwick_james_ex1)

    @test issubset(expected_circuits, hadwick_circuits_self)
    @test [1] ∈ hadwick_circuits_self && [3] ∈ hadwick_circuits_self

    ex2_size = 10
    hadwick_james_ex2 = PathDiGraph(ex2_size)
    @test isempty(simplecycles_hadwick_james(hadwick_james_ex2))

end
