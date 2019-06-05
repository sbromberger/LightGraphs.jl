@testset "Small graphs" begin
    @testset "by string" begin
        g = smallgraph("diamondgraph")
        @test nv(g) == 4 && ne(g) == 5

        g = smallgraph("diamond")
        @test nv(g) == 4 && ne(g) == 5
    end

    smallgraphs = [
        (:diamond        , 4, 5, false),
        (:bull           , 5, 5, false),
        (:chvatal        , 12, 24, false),
        (:cubical        , 8, 12, false),
        (:desargues      , 20, 30, false),
        (:dodecahedral   , 20, 30, false),
        (:frucht         , 12, 18, false),
        (:heawood        , 14, 21, false),
        (:house          , 5,6, false),
        (:housex         , 5, 8, false),
        (:icosahedral    , 12, 30, false),
        (:krackhardtkite , 10, 18, false),
        (:moebiuskantor  , 16, 24, false),
        (:octahedral     , 6, 12, false),
        (:pappus         , 18, 27, false),
        (:petersen       , 10, 15, false),
        (:sedgewickmaze  , 8, 10, false),
        (:tetrahedral    , 4, 6, false),
        (:truncatedcube  , 24, 36, false),
        (:truncatedtetrahedron , 12, 18, false),
        (:truncatedtetrahedron_dir , 12, 18, true),
        (:tutte          , 46, 69, false)
    ]

    @testset "$(s[1])" for s in smallgraphs
        g = smallgraph(s[1])
        (nvg, neg, dir) = s[2:4]
        @test nv(g) == nvg
        @test ne(g) == neg
        @test is_directed(g) == dir
    end

    @testset "karate" begin
        g = smallgraph(:karate)
        degree_sequence = sort([16, 9, 10, 6, 3, 4, 4, 4, 5, 2, 3, 1, 2, 5, 2,  2,  2,
                                 2, 2,  3, 2, 2, 2, 5, 3, 3, 2, 4, 3, 4, 4, 6, 12, 17])
        @test nv(g) == 34 && ne(g) == 78 && sort(degree(g)) == degree_sequence
    end
    @testset "nonexistent graph" begin
        @test_throws ArgumentError g = smallgraph(:nonexistent)
    end
end
