z = katz_centrality(g5, 0.4)
@test round(z, 2) == [0.32, 0.44, 0.62, 0.56]
