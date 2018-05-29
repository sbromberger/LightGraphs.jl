@testset "Metric Steiner Tree" begin
    
	function sum_weight(E::Vector{Edge}, distmx::Matrix{<:Integer}) 
		sum_wt = zero(Int32)
		for e in E
			sum_wt += distmx[e.src, e.dst]
		end
		return sum_wt
	end

	d = [2  3  4   5   6   7
		 3  4  5   6   7   8
		 4  5  6   7   8   9
		 5  6  7   8   9  10
		 6  7  8   9  10  11
		 7  8  9  10  11  12]
		
	g3 = CompleteGraph(6) 
	for g in testgraphs(g3)
		st = @inferred(metric_steiner_tree(g, [2, 4, 5], d))
		@test sum_weight(st, d) == 13#2+2+4+5
	end
 
end