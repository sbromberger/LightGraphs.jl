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

er = sparse_erdos_renyi(10, 0.5)
@test nv(er) == 10
@test is_directed(er) == false
er = sparse_erdos_renyi(10, 0.5, is_directed=true)
@test nv(er) == 10
@test is_directed(er) == true

er = sparse_erdos_renyi(10, 0.5)
@test nv(er) == 10
@test is_directed(er) == false
er = sparse_erdos_renyi(10, 0.5, is_directed=true)
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
