@test nv(r1) == 10
@test ne(r1) == 20
@test nv(r2) == 5
@test ne(r2) == 10

er = erdos_renyi(10, 0.5)
@test nv(er) == 10
@test is_directed(er) == false
er = erdos_renyi(10, 0.5, is_directed=true)
@test nv(er) == 10
@test is_directed(er) == true

ws = watts_strogatz(10,4,0.2)
@test nv(ws) == 10
@test ne(ws) == 20
@test is_directed(ws) == false

ws = watts_strogatz(10, 4, 0.2, is_directed=true)
@test nv(ws) == 10
@test ne(ws) == 20
@test is_directed(ws) == true

rr = random_regular_graph(5, 0)
@test nv(rr) == 5
@test ne(rr) == 0
@test is_directed(rr) == false

rd = random_regular_digraph(10,0)
@test nv(rd) == 10
@test ne(rd) == 0
@test is_directed(rd)

rr = random_regular_graph(10, 2)
@test nv(rr) == 10
@test ne(rr) == 10
@test is_directed(rr) == false
rr = random_regular_graph(1000, 50)
@test nv(rr) == 1000
@test ne(rr) == 25000
@test is_directed(rr) == false
for v in vertices(rr)
    @test degree(rr, v) == 50
end

rr = random_configuration_model(10, repmat([2,4] ,5), 3)
@test nv(rr) == 10
@test ne(rr) == 15
@test is_directed(rr) == false
num2 = 0; num4 = 0
for v in vertices(rr)
    d = degree(rr, v)
    @test  d == 2 || d == 4
    d == 2 ? num2 += 1 : num4 += 1
end
@test num4 == 5
@test num2 == 5

rr = random_configuration_model(1000, zeros(Int,1000))
@test nv(rr) == 1000
@test ne(rr) == 0
@test is_directed(rr) == false

rd = random_regular_digraph(1000, 4)
@test nv(rd) == 1000
@test ne(rd) == 4000
@test is_directed(rd)
@test std(outdegree(rd)) == 0

rd = random_regular_digraph(1000, 4, :in)
@test nv(rd) == 1000
@test ne(rd) == 4000
@test is_directed(rd)
@test std(indegree(rd)) == 0

rr = random_regular_graph(10, 8, 4)
@test nv(rr) == 10
@test ne(rr) == 40
@test is_directed(rr) == false
for v in vertices(rr)
    @test degree(rr, v) == 8
end

rd = random_regular_digraph(10, 8, :out, 4)
@test nv(rd) == 10
@test ne(rd) == 80
@test is_directed(rd)
