@testset "Maximum flow" begin
    #### Graphs for testing
    graphs = [
      # Graph with 8 vertices
      (8,
       [
         (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
         (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
         (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
       ],
       1,8, # source/target
       3,   # answer for default capacity
       28,  # answer for custom capacity
       15,5 # answer for restricted capacity/restriction
      ),

      # Graph with 6 vertices
      (6,
       [
         (1,2,9),(1,3,9),(2,3,10),(2,4,8),(3,4,1),
         (3,5,3),(5,4,8),(4,6,10),(5,6,7)
       ],
       1,6, # source/target
       2,   # answer for default capacity
       12,  # answer for custom capacity
       8,5  # answer for restricted capacity/restriction
      )
    ]

    for (nvertices,flow_edges,s,t,fdefault,fcustom,frestrict,caprestrict) in graphs
        flow_graph = DiGraph(nvertices)
        capacity_matrix = zeros(Int,nvertices,nvertices)
        for e in flow_edges
            u,v,f = e
            add_edge!(flow_graph,u,v)
            capacity_matrix[u,v] = f
        end

        # Test DefaultCapacity
        d = LightGraphs.DefaultCapacity(flow_graph)
        @test typeof(d) <: AbstractArray{Int, 2}
        @test d[s,t] == 0
        @test size(d) == (nvertices,nvertices)
        @test typeof(transpose(d)) == LightGraphs.DefaultCapacity
        @test typeof(ctranspose(d)) == LightGraphs.DefaultCapacity

        # Test all algorithms
        for ALGO in [EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm]
          @test maximum_flow(flow_graph,s,t,algorithm=ALGO())[1] == fdefault
          @test maximum_flow(flow_graph,s,t,capacity_matrix,algorithm=ALGO())[1] == fcustom
          @test maximum_flow(flow_graph,s,t,capacity_matrix,algorithm=ALGO(),restriction=caprestrict)[1] == frestrict
        end
    end
end
