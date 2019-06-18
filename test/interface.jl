mutable struct DummyGraph <: AbstractGraph{Int} end
mutable struct DummyDiGraph <: AbstractGraph{Int} end
mutable struct DummyEdge <: AbstractEdge{Int} end

@testset "Interface" begin
    dummygraph = DummyGraph()
    dummydigraph = DummyDiGraph()
    dummyedge = DummyEdge()

    @test_throws ErrorException is_directed(DummyGraph)
    @test_throws ErrorException zero(DummyGraph)

    for edgefun in [src, dst, Pair, Tuple, reverse]
        @test_throws ErrorException edgefun(dummyedge)
    end

    for edgefun2edges in [==]
        @test_throws ErrorException edgefun2edges(dummyedge, dummyedge)
     end

    for graphfunbasic in [
        nv, ne, vertices, edges, is_directed,
        edgetype, eltype
    ]
        @test_throws ErrorException graphfunbasic(dummygraph)
    end

    for graphfun1int in [
        has_vertex, inneighbors, outneighbors
    ]
        @test_throws ErrorException graphfun1int(dummygraph, 1)
    end
    for graphfunedge in [
        has_edge,
      ]
        @test_throws ErrorException graphfunedge(dummygraph, dummyedge)
        @test_throws ErrorException graphfunedge(dummygraph, 1, 2)
    end

end # testset
