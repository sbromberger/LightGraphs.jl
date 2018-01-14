@testset "Boykov Kolmogorov" begin
    # construct graph
    gg = SimpleDiGraph(3)
    add_edge!(gg, 1, 2)
    add_edge!(gg, 2, 3)

    # source and sink terminals
    source, target = 1, 3


    for g in testdigraphs(gg)
    # default capacity
      capacity_matrix = LightGraphs.DefaultCapacity(g)
      residual_graph = @inferred(LightGraphs.residual(g))
      T = eltype(g)
      flow_matrix = zeros(T, 3, 3)
      TREE = zeros(T, 3)
      TREE[source] = T(1)
      TREE[target] = T(2)
      PARENT = zeros(T, 3)
      A = [T(source), T(target)]
# see https://github.com/JuliaLang/julia/issues/21077
# @show("testing $g with eltype $T, residual_graph type is $(eltype(residual_graph)), flow_matrix type is $(eltype(flow_matrix)), capacity_matrix type is $(eltype(capacity_matrix))")
      path = LightGraphs.find_path!(
        residual_graph, source, target, flow_matrix,
        capacity_matrix, PARENT, TREE, A)

      @test path == [1, 2, 3]
  end
end
