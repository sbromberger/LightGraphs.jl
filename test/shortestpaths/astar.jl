@testset "A star" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)

    d1 = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    for g in testgraphs(g3), dg in testdigraphs(g4)
      @test a_star(g, 1, 4, d1) ==
          a_star(dg, 1, 4, d1) ==
          a_star(g, 1, 4, d2)
      @test a_star(dg, 4, 1) == nothing
    end
end
