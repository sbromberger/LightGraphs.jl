g = Graph(12)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 4)
add_edge!(g, 3, 5)
add_edge!(g, 4, 5)
add_edge!(g, 2, 6)
add_edge!(g, 1, 7)
add_edge!(g, 6, 7)
add_edge!(g, 6, 8)
add_edge!(g, 6, 9)
add_edge!(g, 8, 9)
add_edge!(g, 9, 10)
add_edge!(g, 11, 12)

bcc = biconnected_components(g)
a = [[Edge(3, 5),Edge(4, 5), Edge(2, 4),Edge(3, 4),Edge(2, 3)], [Edge(9, 10)], [Edge(6, 9),Edge(8, 9),Edge(6, 8)], [Edge(1, 7),Edge(6, 7),Edge(2, 6),Edge(1, 2)], [Edge(11, 12)]]
@test bcc == a

g = Graph(4)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)
add_edge!(g, 3, 4)
add_edge!(g, 1, 4)

h = Graph(4)
add_edge!(h, 1, 2)
add_edge!(h, 2, 3)
add_edge!(h, 3, 4)
add_edge!(h, 1, 4)

G = blkdiag(g, h)
add_edge!(G, 4, 5)

bcc = biconnected_components(G)
a = [[Edge(5, 8),Edge(7, 8),Edge(6, 7),Edge(5, 6)], [Edge(4, 5)], [Edge(1, 4),Edge(3, 4),Edge(2, 3),Edge(1, 2)]]
@test bcc == a
