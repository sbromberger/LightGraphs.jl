@testset "Edmonds Karp" begin
    # Construct DiGraph
    flow_graph = DiGraph(8)

    # Load custom dataset
    flow_edges = [
        (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
        (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
        (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
    ]

    for fg in (flow_graph, DiGraph{UInt8}(flow_graph), DiGraph{Int16}(flow_graph))

      capacity_matrix = zeros(Int,8,8)

        for e in flow_edges
            u,v,f = e
            add_edge!(fg,u,v)
            capacity_matrix[u,v] = f
        end

      residual_graph = LightGraphs.residual(fg)

      # Test with default distances
      @test LightGraphs.edmonds_karp_impl(residual_graph, 1, 8, LightGraphs.DefaultCapacity(residual_graph))[1] == 3

      # Test with capacity matrix
      @test LightGraphs.edmonds_karp_impl(residual_graph,1,8,capacity_matrix)[1] == 28

      # Test the types of the values returned by fetch_path
      function test_find_path_types(residual_graph, s, t, flow_matrix, capacity_matrix)
          v, P, S, flag = LightGraphs.fetch_path(residual_graph, s, t, flow_matrix, capacity_matrix)
          @test typeof(P) == Vector{Int}
          @test typeof(S) == Vector{Int}
          @test typeof(flag) == Int
          @test typeof(v) == eltype(residual_graph)
      end

      # Test the value of the flags returned.
      function test_find_path_disconnected(residual_graph, s, t, flow_matrix, capacity_matrix)
          h = copy(residual_graph)
          for dst in collect(neighbors(residual_graph, s))
              rem_edge!(residual_graph, s, dst)
          end
          v, P, S, flag = LightGraphs.fetch_path(residual_graph, s, t, flow_matrix, capacity_matrix)
          @test flag == 1
          for dst in collect(neighbors(h, t))
              rem_edge!(h, t, dst)
          end
          v, P, S, flag = LightGraphs.fetch_path(h, s, t, flow_matrix, capacity_matrix)
          @test flag == 0
          for i in collect(in_neighbors(h, t))
              rem_edge!(h, i, t)
          end
          v, P, S, flag = LightGraphs.fetch_path(h, s, t, flow_matrix, capacity_matrix)
          @test flag == 2
      end

      flow_matrix = zeros(Int, nv(residual_graph), nv(residual_graph))
      test_find_path_types(residual_graph, 1,8, flow_matrix, capacity_matrix)
      test_find_path_disconnected(residual_graph, 1, 8, flow_matrix, capacity_matrix)
    end
end
