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
ans = [[3=>5,4=>5,2=>4,3=>4,2=>3], [9=>10], [6=>9,8=>9,6=>8], [1=>7,6=>7,2=>6,1=>2], [11=>12]]
@test bcc == ans

g = Graph(6)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)
add_edge!(g, 3, 4)
add_edge!(g, 1, 4)
add_edge!(g, 3, 5)
add_edge!(g, 2, 6)

bcc = biconnected_components(g)
ans = [[3=>5], [2=>6], [1=>4,3=>4,2=>3,1=>2]]
@test bcc == ans