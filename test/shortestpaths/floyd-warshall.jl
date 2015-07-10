d = [ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]
z = floyd_warshall_shortest_paths(g3, d)
@test z.dists[3,:] == [7 6 0 11 27]
@test z.parents[3,:] == [2 3 0 3 4]

@test enumerate_paths(z)[2][2] == []
@test enumerate_paths(z)[2][4] == enumerate_paths(z,2)[4] == enumerate_paths(z,2,4) == [2,3,4]
