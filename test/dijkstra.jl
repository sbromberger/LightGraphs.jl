d1 = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
d2 = sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

y = dijkstra_shortest_paths(g4, 2; edge_dists=d1)
z = dijkstra_shortest_paths(g4, 2; edge_dists=d2)

@test y.parents == z.parents == [0, 0, 2, 3, 4]
@test y.dists == z.dists == [Inf, 0, 6, 17, 33]

y = dijkstra_predecessor_and_distance(g4, 2; edge_dists=d1)
z = dijkstra_predecessor_and_distance(g4, 2; edge_dists=d2)
@test z.predecessors[3] == y.predecessors[3] == [2]

@test enumerate_paths(z) == enumerate_paths(y)
@test enumerate_paths(z)[4] ==
    enumerate_paths(z,4) ==
    enumerate_paths(y,4) == [2,3,4]
