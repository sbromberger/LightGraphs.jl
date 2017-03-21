@testset "Floyd Warshall" begin
    g3 = PathGraph(5)
    d = [ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]
    for g in testgraphs(g3)
      z = @inferred(floyd_warshall_shortest_paths(g, d))
      @test z.dists[3,:][:] == [7, 6, 0, 11, 27]
      @test z.parents[3,:][:] == [2, 3, 0, 3, 4]

      @test @inferred(enumerate_paths(z))[2][2] == []
      @test @inferred(enumerate_paths(z))[2][4] == enumerate_paths(z,2)[4] == enumerate_paths(z,2,4) == [2,3,4]
    end
end
