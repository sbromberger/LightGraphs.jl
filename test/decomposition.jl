@testset "Decomposition" begin
	# graph from https://en.wikipedia.org/wiki/Ear_decomposition
	elist = [(1,2),(1,5),(1,8),(2,3),(2,7),(3,4),(4,5),(4,6), (6, 7), (7, 8)];
	g1 = SimpleGraph(8)
	for e in elist
		add_edge!(g1, e[1], e[2])
	end

	ear_d1 = @inferred(ear_decomposition(g1))
	expected_results = [[1, 5, 4, 3, 2, 1], [1, 8, 7, 6, 4], [2, 7]]
	@test ear_d1 == expected_results

	# test for path graph
	g2 = PathGraph(5)
	ear_d2 = @inferred(ear_decomposition(g2))
	@test ear_d2 == []

	# test for cycle graph
	g3 = PathGraph(5)
	add_edge!(g3, 1, 5)
	ear_d3 = @inferred(ear_decomposition(g3))
	expected_results = [[1, 5, 4, 3, 2, 1]]
	@test ear_d3 == expected_results
end
