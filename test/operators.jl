c3 = complement(g3)
c4 = complement(g4)

@test nv(c3) == 5
@test ne(c3) == 6
@test nv(c4) == 5
@test ne(c4) == 16

g = reverse(g4)
@test re1 in edges(g)
reverse!(g)
@test g == g4

g = blkdiag(g3, g3)
@test nv(g) == 10
@test ne(g) == 8

h = PathGraph(2)
@test intersect(g3, h) == h

h = PathGraph(4)
z = difference(g3, h)
@test nv(z) == 5
@test ne(z) == 1
z = difference(h, g3)
@test nv(z) == 4
@test ne(z) == 0

z = symmetric_difference(h,g3)
@test z == symmetric_difference(g3,h)
@test nv(z) == 5
@test ne(z) == 1

h = Graph(6)
add_edge!(h, 5, 6)
e = Edge(5, 6)
z = union(g3, h)
@test has_edge(z, e)
@test z == PathGraph(6)

p = PathGraph(10)
x = p*ones(10)
@test  x[1]==1.0 && all(x[2:end-1]==2.0) && x[end]==1.0 || @show x
