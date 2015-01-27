d = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
@test a_star(g3, 1, 4; edge_dists=d) == a_star(g4, 1, 4; edge_dists=d)
@test a_star(g4, 4, 1) == nothing
