y = katz_centrality(g5, 0.4)
z = katz_centrality(g5, 0.4, :receive)
@test round(y, 2) == [0.32, 0.44, 0.62, 0.56]
@test round(z, 2) == [0.69, 0.49, 0.44, 0.31]
