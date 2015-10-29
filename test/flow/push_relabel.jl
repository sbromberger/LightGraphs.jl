using LightGraphs
using Base.Test
# Construct DiGraph
flow_graph = DiGraph(8)

# Load custom dataset
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

capacity_matrix = zeros(Int,8,8);

for e in flow_edges
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

residual_graph, capacity_matrix = LightGraphs.residual(flow_graph, capacity_matrix)

# Test with default distances
@test LightGraphs.push_relabel(residual_graph, 1, 8)[1] == 3

# Test with capacity matrix
@test LightGraphs.push_relabel(residual_graph, 1, 8, capacity_matrix)[1] == 28
