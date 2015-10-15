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
