using Base.Test
srand(17)
g = Graph(10, 10)
println(Dict{Edge,Int}() |> valtype)

em1 = EdgeMap{Int, Dict{Edge,Int}}(Dict{Edge,Int}())
em2 = EdgeMap(Int)
em3 = EdgeMap(Dict{Edge, Int}())
em4 = EdgeMap{Int, Dict{Edge,Int}}()
em5= ConstEdgeMap(1)
# em = ConstEdgeMap(g, x)
#em = DefaultEdgeMap(Int)
@test_throws(ErrorException, em5[1,2] = 1)

i = 0
for e in edges(g)
    em1[e] = (i+=1)
    em2[src(e), dst(e)] = em1[e]
    @test em1[e] == em2[e]
    @test  em2[src(e), dst(e)] == em1[src(e), dst(e)]
end
