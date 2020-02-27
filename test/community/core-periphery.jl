@testset "Core periphery" begin
    @testset "star graph core periphery" begin
      g10 = star_graph(10)
      @testset "$g" for g in testgraphs(g10)
          c = core_periphery_deg(g)
          @test @inferred(degree(g, 1)) == 9
          @test c[1] == 1
          for i = 2:10
              @test c[i] == 2
          end
      end
    end

    @testset "blockdiag star graph core periphery" begin
      g10 = star_graph(10)
      g10 = blockdiag(g10, g10)
      add_edge!(g10, 1, 11)
      @testset "$g" for g in testgraphs(g10)
          c = @inferred(core_periphery_deg(g))
          @test c[1] == 1
          @test c[11] == 1
          for i = 2:10
              @test c[i] == 2
          end
          for i = 12:20
              @test c[i] == 2
          end
      end
    end
end
