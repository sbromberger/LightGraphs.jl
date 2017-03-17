@benchgroup "connectivity" begin
  @benchgroup "digraphs" begin
    for (name, g) in DIGRAPHS
      @bench "$(name): connected_components" LightGraphs.connected_components($g)
      @bench "$(name): strongly_connected_components" LightGraphs.strongly_connected_components($g)
    end
  end # digraphs
  @benchgroup "graphs" begin
    for (name, g) in GRAPHS
        @bench "$(name): connected_components" LightGraphs.connected_components($g)
    end
  end # graphs
end # connectivity
