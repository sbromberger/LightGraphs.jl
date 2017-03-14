@testset "Interface" begin
    dummygraph = DummyGraph()
    dummydigraph = DummyDiGraph()
    dummyedge = DummyEdge()

    for edgefun in [src, dst, Pair, Tuple, reverse]
      @test_throws ErrorException edgefun(dummyedge)
    end

    for edgefun2edges in [ == ]
       @test_throws ErrorException edgefun2edges(dummyedge, dummyedge)
     end

    for graphfunbasic in [
      nv, ne, vertices, edges, is_directed, add_vertex!
      ]
      @test_throws ErrorException graphfunbasic(dummygraph)
    end

    for graphfun1int in [
      rem_vertex!, has_vertex, in_neighbors, out_neighbors
      ]
      @test_throws ErrorException graphfun1int(dummygraph, 1)
    end
    for graphfunedge in [
      has_edge, add_edge!, rem_edge!
      ]
      @test_throws ErrorException graphfunedge(dummygraph, dummyedge)
    end

end # testset
