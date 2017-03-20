@testset "Small graphs" begin
    g = smallgraph("diamondgraph")
    @test @inferred(nv(g)) == 4 && ne(g) == 5

    g = smallgraph("diamond")
    @test @inferred(nv(g)) == 4 && ne(g) == 5

    g = smallgraph(:diamond)
    @test @inferred(nv(g)) == 4 && ne(g) == 5

    g = smallgraph(:bull)
    @test @inferred(nv(g)) == 5 && ne(g) == 5

    g = smallgraph(:chvatal)
    @test @inferred(nv(g)) == 12 && ne(g) == 24

    g = smallgraph(:cubical)
    @test @inferred(nv(g)) == 8 && ne(g) == 12

    g = smallgraph(:desargues)
    @test @inferred(nv(g)) == 20 && ne(g) == 30

    g = smallgraph(:dodecahedral)
    @test @inferred(nv(g)) == 20 && ne(g) == 30

    g = smallgraph(:frucht)
    @test @inferred(nv(g)) == 20 && ne(g) == 18

    g = smallgraph(:heawood)
    @test @inferred(nv(g)) == 14 && ne(g) == 21

    g = smallgraph(:house)
    @test @inferred(nv(g)) == 5 && ne(g) == 6

    g = smallgraph(:housex)
    @test @inferred(nv(g)) == 5 && ne(g) == 8

    g = smallgraph(:icosahedral)
    @test @inferred(nv(g)) == 12 && ne(g) == 30

    g = smallgraph(:krackhardtkite)
    @test @inferred(nv(g)) == 10 && ne(g) == 18

    g = smallgraph(:moebiuskantor)
    @test @inferred(nv(g)) == 16 && ne(g) == 24

    g = smallgraph(:octahedral)
    @test @inferred(nv(g)) == 6 && ne(g) == 12

    g = smallgraph(:pappus)
    @test @inferred(nv(g)) == 18 && ne(g) == 27

    g = smallgraph(:petersen)
    @test @inferred(nv(g)) == 10 && ne(g) == 15

    g = smallgraph(:sedgewickmaze)
    @test @inferred(nv(g)) == 8 && ne(g) == 10

    g = smallgraph(:tetrahedral)
    @test @inferred(nv(g)) == 4 && ne(g) == 6

    g = smallgraph(:truncatedcube)
    @test @inferred(nv(g)) == 24 && ne(g) == 36

    g = smallgraph(:truncatedtetrahedron)
    @test @inferred(nv(g)) == 12 && ne(g) == 18 && !is_directed(g)

    g = smallgraph(:truncatedtetrahedron_dir)
    @test @inferred(nv(g)) == 12 && ne(g) == 18 && is_directed(g)

    g = smallgraph(:tutte)
    @test @inferred(nv(g)) == 46 && ne(g) == 69

    @test_throws ErrorException g = smallgraph(:nonexistent)
end
