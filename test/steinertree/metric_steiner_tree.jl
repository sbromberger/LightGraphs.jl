@testset "Metric Steiner Tree" begin
    
	function sum_weight(E::Vector{Edge}, distmx::Matrix{Int32}) 
		sum_wt = zero(Int32)
		for e in E
			sum_wt += distmx[e.src, e.dst]
		end
		return sum_wt
	end

	d = Matrix{Int32}(undef, 6, 6)
	for i in 1:6, j in 1:6
		d[i, j] = i+j
	end
		
	g3 = CompleteGraph(6) 
	for g in testgraphs(g3)
		st = @inferred(metric_steiner_tree(g, d, [2, 4, 5]))
		@test sum_weight(st, d) == 13#2+2+4+5
	end
 
end