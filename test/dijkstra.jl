d = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
z = dijkstra_shortest_paths(g4, 2; edge_dists=d)

@test z.parents == [0, 0, 2, 3, 4]
@test z.dists == [Inf, 0, 6, 17, 33]

z = dijkstra_predecessor_and_distance(g4, 2; edge_dists=d)
@test z.predecessors[3] == [2]
