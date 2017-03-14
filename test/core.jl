@testset "Core" begin
  d = DummyGraph()
  for fn in [ degree, density, all_neighbors ]
    @test_throws ErrorException fn(d)
  end
end
