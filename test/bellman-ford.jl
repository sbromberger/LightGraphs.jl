d1 = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
d2 = sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
y = bellman_ford_shortest_paths(g4, 2, d1)
z = bellman_ford_shortest_paths(g4, 2, d2)
@test y.dists == z.dists == [Inf, 0, 6, 17, 33]
@test enumerate_paths(z)[2] == []
@test enumerate_paths(z)[4] == enumerate_paths(z,4) == [2,3,4]
@test !has_negative_edge_cycle(g4)
