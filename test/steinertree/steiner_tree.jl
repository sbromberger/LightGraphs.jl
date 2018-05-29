@testset "Steiner Tree" begin
    
	function sum_weight(E::Vector{Edge}, distmx::Matrix{<:Integer})
		sum_wt = zero(Int32)
		for e in E
			sum_wt += distmx[e.src, e.dst]
		end
		return sum_wt
	end

	d = [1   2   3   4   5   6
 		 2   4   6   8  10  12
 		 3   6   9  12  15  18
 		 4   8  12  16  20  24
 		 5  10  15  20  25  30
 		 6  12  18  24  30  36]

	
	g3 = StarGraph(6) 
	for g in testgraphs(g3)
		st = @inferred(steiner_tree(g, [2, 4, 5], d))
		@test sum_weight(st, d) == 11 #2+4+5
	end

	g4 = CompleteGraph(6) 
	for g in testgraphs(g4)
		st = @inferred(steiner_tree(g, [2, 4, 5], d))
		@test sum_weight(st, d) == 11 #2+4+5
	end

	g5 = PathGraph(6) 
	for g in testgraphs(g5)
		st = @inferred(steiner_tree(g, [2, 4, 6], d))
		@test sum_weight(st, d) == 68 #2*3+3*4+4*5+5*6
	end

	g6 = WheelGraph(6) 
	for g in testgraphs(g6)
		st = @inferred(steiner_tree(g, [2, 4, 5], d))
		@test sum_weight(st, d) == 11 #2+4+5
	end
end
