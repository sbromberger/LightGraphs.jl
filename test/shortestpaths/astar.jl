@testset "A star" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)

    d1 = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    @test a_star(g3, 1, 4, d1) ==
        a_star(g4, 1, 4, d1) ==
        a_star(g3, 1, 4, d2)
    @test a_star(g4, 4, 1) == nothing
end
