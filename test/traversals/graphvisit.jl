@testset "Graph visit" begin
    g6 = smallgraph(:house)
    for g in testgraphs(g6)
      # stub tests for coverage; disregards output.

      f = IOBuffer()

      @test @inferred(traverse_graph_withlog(g, DepthFirst(), 1, f)) == nothing
      @test @inferred(visited_vertices(g, DepthFirst(), 1)) == [1, 2, 4, 3, 5]


      vis = TrivialGraphVisitor()
      @test discover_vertex!(vis, 1)
      @test open_vertex!(vis, 1)
      @test examine_neighbor!(vis, 1, 1, 0, 0, 0)
      @test close_vertex!(vis, 1)

      function trivialgraphvisit(
          g::AbstractGraph,
          alg::LightGraphs.AbstractGraphVisitAlgorithm,
          sources
      )
          visitor = TrivialGraphVisitor()
          @inferred(traverse_graph!(g, alg, sources, visitor))
      end
    end
    # dummy edge map test
    d = @inferred(LightGraphs.DummyEdgeMap())
    
    # check that printing DummyEdgeMap doesn't error
    string(LightGraphs.DummyEdgeMap())
    mktemp() do _, io
        show(io, MIME"text/plain"(), LightGraphs.DummyEdgeMap())
    end    

    e = Edge(1, 2)
    @test d[e] == 0
    @test getindex(d, e) == 0
end
