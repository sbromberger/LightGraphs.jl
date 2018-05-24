@testset "Metric Travelling Salesman" begin

	g3 = CompleteGraph(5)
	d = [0 1 23 17 20; 1 0 3 13 16; 23 3 0 15 7; 17 13 15 0 9; 20 16 7 9  0]

	for g in testgraphs(g3)
		m = @inferred(metric_travelling_salesman(g, d))
		@test m == [1, 2, 3, 5, 4]
	end
end
