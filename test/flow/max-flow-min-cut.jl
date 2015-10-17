# Construct DiGraph
flow_graph = DiGraph(8);

# Add edges
add_edge!(flow_graph,1,2);
add_edge!(flow_graph,1,3);
add_edge!(flow_graph,1,4);
add_edge!(flow_graph,2,3);
add_edge!(flow_graph,2,5);
add_edge!(flow_graph,2,6);
add_edge!(flow_graph,3,4);
add_edge!(flow_graph,3,6);
add_edge!(flow_graph,4,7);
add_edge!(flow_graph,5,6);
add_edge!(flow_graph,5,8);
add_edge!(flow_graph,6,7);
add_edge!(flow_graph,6,8);
add_edge!(flow_graph,7,3);
add_edge!(flow_graph,7,8);

# Test with default distances
@test maximum_flow(flow_graph,1,8)[1] == 3

# Construct capacity matrix 
capacity_matrix = zeros(Int,8,8);

capacity_matrix[1,2] = 10;
capacity_matrix[1,3] = 5;
capacity_matrix[1,4] = 15;
capacity_matrix[2,3] = 4;
capacity_matrix[2,5] = 9;
capacity_matrix[2,6] = 15;
capacity_matrix[3,4] = 4;
capacity_matrix[3,6] = 8;
capacity_matrix[4,7] = 16;
capacity_matrix[5,6] = 15;
capacity_matrix[5,8] = 10;
capacity_matrix[6,7] = 15;
capacity_matrix[6,8] = 10;
capacity_matrix[7,3] = 6;
capacity_matrix[7,8] = 10;


# Run maximum flow Test
@test maximum_flow(flow_graph,1,8,capacity_matrix)[1] == 28

function test_find_path_types(flow_graph, s, t, flow_matrix, capacity_matrix)
    v, P, S, flag = LightGraphs.fetch_path(flow_graph, s, t, flow_matrix, capacity_matrix)
    @test typeof(P) == Vector{Int}
    @test typeof(S) == Vector{Int}
    @test typeof(flag) == Int
    @test typeof(v) == Int
end

function test_find_path_disconnected(flow_graph, s, t, flow_matrix, capacity_matrix)
    h = copy(flow_graph)
    for dst in collect(neighbors(flow_graph, s))
        rem_edge!(flow_graph, s, dst) 
    end
    v, P, S, flag = LightGraphs.fetch_path(flow_graph, s, t, flow_matrix, capacity_matrix)
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

flow_matrix = zeros(Int, nv(flow_graph), nv(flow_graph))
test_find_path_types(flow_graph, 1,8, flow_matrix, capacity_matrix)
test_find_path_disconnected(flow_graph, 1, 8, flow_matrix, capacity_matrix)
