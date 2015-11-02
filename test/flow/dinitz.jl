# Construct DiGraph
flow_graph = DiGraph(8)

# Load custom dataset
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

capacity_matrix = zeros(Int ,nv(flow_graph) ,nv(flow_graph));

for e in flow_edges
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

# Construct the residual graph
residual_graph = LightGraphs.residual(flow_graph)

# Test with default distances
@test LightGraphs.dinitz_impl(residual_graph, 1, 8, LightGraphs.DefaultCapacity(residual_graph))[1] == 3

# Test with capacity matrix
@test LightGraphs.dinitz_impl(residual_graph, 1, 8, capacity_matrix)[1] == 28

# Test on disconnected graphs
function test_blocking_flow(residual_graph, source, target, capacity_matrix, flow_matrix)
    h = copy(residual_graph)
    for dst in collect(neighbors(residual_graph, source))
        rem_edge!(h, source, dst)
    end

    @test LightGraphs.blocking_flow!(h, source, target, capacity_matrix, flow_matrix) == 0

    h = copy(residual_graph)

    for dst in collect(in_neighbors(residual_graph, target))
        rem_edge!(h, dst, target)
    end

    @test LightGraphs.blocking_flow!(h, source, target, capacity_matrix, flow_matrix) == 0

    @test LightGraphs.blocking_flow!(residual_graph, source, target, capacity_matrix, flow_matrix) > 0
end

flow_matrix = zeros(Int, nv(residual_graph), nv(residual_graph))
test_blocking_flow(residual_graph, 1, 8, capacity_matrix, flow_matrix)
