#### Graphs for testing
graphs = [
  # Graph with 8 vertices
  (8,
   [
     (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
     (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
     (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
   ],
   1,8,                               # source/target
   [28, 28, 15, 0],                   # answer for 1 to 4 route(s) flows
   [(0.0,0.0,3),(5.0,15.0,2),         # breaking points
   (10.0,25.0,1),(13.0,28.0,0)],
   28.0                               # value for 1.5 routes
  ),

  # Graph with 6 vertices
  (6,
   [
     (1,2,9),(1,3,9),(2,3,10),(2,4,8),(3,4,1),
     (3,5,3),(5,4,8),(4,6,10),(5,6,7)
   ],
   1,6,                               # source/target
   [12, 6, 0],                        # answer for 1 to 3 route(s) flows
   [(0.,0.,2),(3.,6.,1),(9.,12.,0)],  # breaking points
   11.0                               # value for 1.5 routes
  )
]

for (nvertices,flow_edges,s,t,froutes,breakpts,ffloat) in graphs
    flow_graph = DiGraph(nvertices)
    capacity_matrix = zeros(Int,nvertices,nvertices)
    for e in flow_edges
        u,v,f = e
        add_edge!(flow_graph,u,v)
        capacity_matrix[u,v] = f
    end

    # Test all algorithms
    for ALGOMRF in [ExtendedMultirouteFlowAlgorithm,KishimotoAlgorithm]
      for ALGOFLOW in [EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm]
        for (k, val) in enumerate(froutes)
          @test multiroute_flow(flow_graph,s,t,capacity_matrix,flow_algorithm=ALGOFLOW(),mrf_algorithm=ALGOMRF(),routes=k)[1] ≈ val
        end
      end
    end
    # Test ExtendedMultirouteFlowAlgorithm when the number of routes is either
    # Noninteger or 0 (the algorithm returns the breaking points)
    @test multiroute_flow(flow_graph,s,t,capacity_matrix) == breakpts
    @test multiroute_flow(flow_graph,s,t,capacity_matrix,routes=1.5)[1] == ffloat
end
