@testset "Graph visit" begin
    g6 = smallgraph(:house)
    for g in testgraphs(g6)
      # stub tests for coverage; disregards output.

      f = IOBuffer()

      @test @inferred(traverse_graph_withlog(g, BreadthFirst(), [1;], f)) == nothing
      @test @inferred(visited_vertices(g, BreadthFirst(), [1;])) == [1, 2, 3, 4, 5]


      function trivialgraphvisit(
          g::AbstractGraph,
          alg::LightGraphs.AbstractGraphVisitAlgorithm,
          sources
      )
          visitor = TrivialGraphVisitor()
          @inferred(traverse_graph!(g, alg, sources, visitor))
      end

      @test trivialgraphvisit(g, BreadthFirst(), 1) == nothing

      # this just exercises some graph visitors
      @test @inferred(traverse_graph!(g, BreadthFirst(), 1, TrivialGraphVisitor())) == nothing
      @test @inferred(traverse_graph!(g, BreadthFirst(), 1, LogGraphVisitor(IOBuffer()))) == nothing
    end
    # dummy edge map test
    d = @inferred(LightGraphs.DummyEdgeMap())
    e = Edge(1,2)
    @test d[e] == 0
end
