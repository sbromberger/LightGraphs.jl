g = smallgraph(:diamond)
@test nv(g) == 4 && ne(g) == 5

g = smallgraph(:bull)
@test nv(g) == 5 && ne(g) == 5

g = smallgraph(:chvatal)
@test nv(g) == 12 && ne(g) == 24

g = smallgraph(:cubical)
@test nv(g) == 8 && ne(g) == 12

g = smallgraph(:desargues)
@test nv(g) == 20 && ne(g) == 30

g = smallgraph(:dodecahedral)
@test nv(g) == 20 && ne(g) == 30

g = smallgraph(:frucht)
@test nv(g) == 20 && ne(g) == 18

g = smallgraph(:heawood)
@test nv(g) == 14 && ne(g) == 21

g = smallgraph(:house)
@test nv(g) == 5 && ne(g) == 6

g = smallgraph(:housex)
@test nv(g) == 5 && ne(g) == 8

g = smallgraph(:icosahedral)
@test nv(g) == 12 && ne(g) == 30

g = smallgraph(:krackhardtkite)
@test nv(g) == 10 && ne(g) == 18

g = smallgraph(:moebiuskantor)
@test nv(g) == 16 && ne(g) == 24

g = smallgraph(:octahedral)
@test nv(g) == 6 && ne(g) == 12

g = smallgraph(:pappus)
@test nv(g) == 18 && ne(g) == 27

g = smallgraph(:petersen)
@test nv(g) == 10 && ne(g) == 15

g = smallgraph(:sedgewickmaze)
@test nv(g) == 8 && ne(g) == 10

g = smallgraph(:tetrahedral)
@test nv(g) == 4 && ne(g) == 6

g = smallgraph(:truncatedcube)
@test nv(g) == 24 && ne(g) == 36

g = smallgraph(:truncatedtetrahedron)
@test nv(g) == 12 && ne(g) == 18 && !is_directed(g)

g = smallgraph(:truncatedtetrahedron_dir)
@test nv(g) == 12 && ne(g) == 18 && is_directed(g)

g = smallgraph(:tutte)
@test nv(g) == 46 && ne(g) == 69

@test_throws ErrorException g = smallgraph(:nonexistent)
