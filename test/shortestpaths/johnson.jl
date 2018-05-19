@testset "Johnson" begin
    g3 = PathGraph(5)
    d = [0 1 2 3 4; 1 0 6 7 8; 2 6 0 11 12; 3 7 11 0 16; 4 8 12 16 0]
    for g in testgraphs(g3)
      z = @inferred(johnson_shortest_paths(g, d))
      @test z.dists[3, :][:] == [7, 6, 0, 11, 27]
      @test z.parents[3, :][:] == [2, 3, 0, 3, 4]

      @test @inferred(enumerate_paths(z))[2][2] == []
      @test @inferred(enumerate_paths(z))[2][4] == enumerate_paths(z, 2)[4] == enumerate_paths(z, 2, 4) == [2, 3, 4]
      
      z = @inferred(johnson_shortest_paths(g, d, parallel=true))
      @test z.dists[3, :][:] == [7, 6, 0, 11, 27]
      @test z.parents[3, :][:] == [2, 3, 0, 3, 4]

      @test @inferred(enumerate_paths(z))[2][2] == []
      @test @inferred(enumerate_paths(z))[2][4] == enumerate_paths(z, 2)[4] == enumerate_paths(z, 2, 4) == [2, 3, 4]
    
    end

    g4 = PathDiGraph(4)
    for g in testdigraphs(g4)
      z = @inferred(johnson_shortest_paths(g))
      @test length(enumerate_paths(z, 4, 3)) == 0
      @test length(enumerate_paths(z, 4, 1)) == 0
      @test length(enumerate_paths(z, 2, 3)) == 2

      z = @inferred(johnson_shortest_paths(g, parallel=true))
      @test length(enumerate_paths(z, 4, 3)) == 0
      @test length(enumerate_paths(z, 4, 1)) == 0
      @test length(enumerate_paths(z, 2, 3)) == 2
    end 

    g5 = DiGraph([1 1 1 0 1; 0 1 0 1 1; 0 1 1 0 0; 1 0 1 1 0; 0 0 0 1 1])
    d = [0 3 8 0 -4; 0 0 0 1 7; 0 4 0 0 0; 2 0 -5 0 0; 0 0 0 6 0]
    for g in testdigraphs(g5)
      z = @inferred(johnson_shortest_paths(g, d))
      @test z.dists == [0 1 -3 2 -4; 3 0 -4 1 -1; 7 4 0 5 3; 2 -1 -5 0 -2; 8 5 1 6 0]
      
      z = @inferred(johnson_shortest_paths(g, d, parallel=true))
      @test z.dists == [0 1 -3 2 -4; 3 0 -4 1 -1; 7 4 0 5 3; 2 -1 -5 0 -2; 8 5 1 6 0]
    end 

end
