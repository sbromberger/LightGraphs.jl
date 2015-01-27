d = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
z = floyd_warshall(g3; edge_dists=d)
@test z.dists[3] == [7, 6, 0, 11, 27]
@test z.parents[3] == [2, 3, 0, 3, 4]
