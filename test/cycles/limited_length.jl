@testset "Limited Length Cycles" begin
    completedg = CompleteDiGraph(4)
    pathdg = PathDiGraph(5)
    cycledg = CycleDiGraph(5)

    @test length(simplecycles_limited_length(completedg, 0)) == 0
    @test length(simplecycles_limited_length(completedg, 1)) == 0
    @test length(simplecycles_limited_length(completedg, 2)) == 6
    @test length(simplecycles_limited_length(completedg, 3)) == 14
    @test length(simplecycles_limited_length(completedg, 4)) == 20
    @test length(simplecycles_limited_length(completedg, 4, 10)) == 10
    @test length(simplecycles_limited_length(completedg, 4, typemax(Int))) == 20

    @test length(simplecycles_limited_length(pathdg, 1)) == 0
    @test length(simplecycles_limited_length(pathdg, 2)) == 0
    @test length(simplecycles_limited_length(pathdg, 3)) == 0
    @test length(simplecycles_limited_length(pathdg, 4)) == 0
    @test length(simplecycles_limited_length(pathdg, 5)) == 0

    @test length(simplecycles_limited_length(cycledg, 1)) == 0
    @test length(simplecycles_limited_length(cycledg, 2)) == 0
    @test length(simplecycles_limited_length(cycledg, 3)) == 0
    @test length(simplecycles_limited_length(cycledg, 4)) == 0
    @test length(simplecycles_limited_length(cycledg, 5)) == 1

    selfloopg = DiGraph([
        0 1 0 0;
        0 0 1 0;
        1 0 1 0;
        0 0 0 1;
    ])
    cycles = simplecycles_limited_length(selfloopg, nv(selfloopg))
    @test [3] in cycles
    @test [4] in cycles
    @test [1, 2, 3] in cycles || [2, 3, 1] in cycles || [3, 1, 2] in cycles
    @test length(cycles) == 3

    octag = smallgraph(:octahedral)
    octadg = DiGraph(octag)
    octalengths, _ = simplecycleslength(octadg)
    for k = 1:6
        @test sum(octalengths[1:k]) == length(simplecycles_limited_length(octag, k))
        @test sum(octalengths[1:k]) == length(simplecycles_limited_length(octadg, k))
    end
end
