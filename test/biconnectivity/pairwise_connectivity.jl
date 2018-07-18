@testset "Lower Bound Pairwise Connectivity" begin

	g3 = StarGraph(5)
	for g in testgraphs(g3)
		k = @inferred(lower_bound_pairwise_connectivity(g, 2, 5))
		@test k == 1
	end

	g4 = CompleteGraph(5)
	for g in testgraphs(g4)
		k = @inferred(lower_bound_pairwise_connectivity(g, 2, 5))
		@test k == typemax(typeof(k))
	end

	g5 = PathGraph(5)
	for g in testgraphs(g5)
		k = @inferred(lower_bound_pairwise_connectivity(g, 2, 4))
		@test k == 1
	end

end