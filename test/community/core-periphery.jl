@testset "Core periphery" begin
    g10 = StarGraph(10)
    for g in testgraphs(g10)
      c = core_periphery_deg(g)
      @test degree(g, 1) == 9
      @test @inferred(c[1]) == 1
      for i=2:10
          @test @inferred(c[i]) == 2
      end
    end

    g10 = StarGraph(10)
    g10 = blkdiag(g10,g10)
    add_edge!(g10, 1, 11)
    for g in testgraphs(g10)
      c = core_periphery_deg(g)
      @test @inferred(c[1]) == 1
      @test @inferred(c[11]) == 1
      for i=2:10
          @test @inferred(c[i]) == 2
      end
      for i=12:20
          @test @inferred(c[i]) == 2
      end
    end
end
