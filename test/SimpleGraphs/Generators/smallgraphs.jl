@testset "Small Graphs" begin
    undirsmallgraphs = [
        (SGGEN.Diamond        , 4, 5),
        (SGGEN.Bull           , 5, 5),
        (SGGEN.Chvatal        , 12, 24),
        (SGGEN.Cubical        , 8, 12),
        (SGGEN.Desargues      , 20, 30),
        (SGGEN.Dodecahedral   , 20, 30),
        (SGGEN.Frucht         , 12, 18),
        (SGGEN.Heawood        , 14, 21),
        (SGGEN.House          , 5, 6),
        (SGGEN.HouseX         , 5, 8),
        (SGGEN.Icosahedral    , 12, 30),
        (SGGEN.KrackhardtKite , 10, 18),
        (SGGEN.MoebiusKantor  , 16, 24),
        (SGGEN.Octahedral     , 6, 12),
        (SGGEN.Pappus         , 18, 27),
        (SGGEN.Petersen       , 10, 15),
        (SGGEN.SedgewickMaze  , 8, 10),
        (SGGEN.Tetrahedral    , 4, 6),
        (SGGEN.TruncatedCube  , 24, 36),
        (SGGEN.TruncatedTetrahedron , 12, 18),
        (SGGEN.Tutte          , 46, 69)
    ]

    @testset "$(s[1])" for s in undirsmallgraphs
        gen = @inferred(s[1]())
        g = @inferred(SG.SimpleGraph(gen))
        (nvg, neg) = (s[2], s[3])
        @test nv(g) == nvg
        @test ne(g) == neg
    end
    @testset "directed TruncatedTetrahedron" begin
        dg = @inferred(SG.SimpleDiGraph(SGGEN.TruncatedTetrahedron()))
        @test nv(dg) == 12
        @test ne(dg) == 18
    end

    @testset "karate" begin
        kgen = @inferred(SGGEN.Karate())
        g = @inferred(SG.SimpleGraph(kgen))
        degree_sequence = sort([16, 9, 10, 6, 3, 4, 4, 4, 5, 2, 3, 1, 2, 5, 2,  2,  2,
                                 2, 2,  3, 2, 2, 2, 5, 3, 3, 2, 4, 3, 4, 4, 6, 12, 17])
        @test nv(g) == 34 && ne(g) == 78 && sort(degree(g)) == degree_sequence
    end
end
