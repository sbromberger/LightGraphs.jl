@testset "Boykov Kolmogorov" begin
    # construct graph
    G = DiGraph(3)
    add_edge!(G,1,2)
    add_edge!(G,2,3)

    # source and sink terminals
    source, target = 1, 3


    for g in testdigraphs(G)
    # default capacity
      capacity_matrix = LightGraphs.DefaultCapacity(g)
      residual_graph = LightGraphs.residual(g)
      T = eltype(g)
      flow_matrix = zeros(T, 3, 3)
      TREE = zeros(T, 3)
      TREE[source] = T(1)
      TREE[target] = T(2)
      PARENT = zeros(T, 3)
      A = [T(source),T(target)]
      path = LightGraphs.find_path!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A)

      @test path == [1,2,3]
    end
end
