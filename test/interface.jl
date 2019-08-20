mutable struct DummyGraph <: AbstractGraph{Int} end
mutable struct DummyDiGraph <: AbstractGraph{Int} end
mutable struct DummyEdge <: AbstractEdge{Int} end

@testset "Interface" begin
    dummygraph = DummyGraph()
    dummydigraph = DummyDiGraph()
    dummyedge = DummyEdge()

    @test_throws LightGraphs.ImplementationError is_directed(DummyGraph)
    @test_throws LightGraphs.ImplementationError zero(DummyGraph)

    for edgefun in [src, dst, Pair, Tuple, reverse]
        @test_throws LightGraphs.ImplementationError edgefun(dummyedge)
    end

    for edgefun2edges in [==]
        @test_throws LightGraphs.ImplementationError edgefun2edges(dummyedge, dummyedge)
     end

    for graphfunbasic in [
        nv, ne, vertices, edges, is_directed,
        edgetype, eltype
    ]
        @test_throws LightGraphs.ImplementationError graphfunbasic(dummygraph)
    end

    for graphfun1int in [
        has_vertex, inneighbors, outneighbors
    ]
        @test_throws LightGraphs.ImplementationError graphfun1int(dummygraph, 1)
    end
    for graphfunedge in [
        has_edge,
      ]
        @test_throws LightGraphs.ImplementationError graphfunedge(dummygraph, dummyedge)
        @test_throws LightGraphs.ImplementationError graphfunedge(dummygraph, 1, 2)
    end

end # testset
