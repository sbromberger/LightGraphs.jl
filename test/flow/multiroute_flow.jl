#### Graphs for testing
graphs = [
  # Graph with 8 vertices
  (8,
   [
     (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
     (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
     (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
   ],
   1,8,               # source/target
   [28, 28, 15, 0]    # answer for 1 to 4 route(s) flows
  ),

  # Graph with 6 vertices
  (6,
   [
     (1,2,9),(1,3,9),(2,3,10),(2,4,8),(3,4,1),
     (3,5,3),(5,4,8),(4,6,10),(5,6,7)
   ],
   1,6,           # source/target
   [12, 6, 0]     # answer for 1 to 3 route(s) flows
  )
]

for (nvertices,flow_edges,s,t,froutes) in graphs
    flow_graph = DiGraph(nvertices)
    capacity_matrix = zeros(Int,nvertices,nvertices)
    for e in flow_edges
        u,v,f = e
        add_edge!(flow_graph,u,v)
        capacity_matrix[u,v] = f
    end

    # Test all algorithms
    for ALGO in [KishimotoAlgorithm]
      for (k, val) in enumerate(froutes)
        @test multiroute_flow(flow_graph,s,t,capacity_matrix,mrf_algorithm=ALGO(),routes=k)[1] ≈ val
      end
    end
end
