@testset "Generator deprecations" begin
    types_0 = [BullGraph, ChvatalGraph, CubicalGraph, DesarguesGraph,
        DiamondGraph, DodecahedralGraph, FruchtGraph, HeawoodGraph,
        HouseGraph, HouseXGraph, IcosahedralGraph, KarateGraph, KrackhardtKiteGraph,
        MoebiusKantorGraph, OctahedralGraph, PappusGraph, PetersenGraph,
        SedgewickMazeGraph, TetrahedralGraph, TruncatedCubeGraph,
        TruncatedTetrahedronGraph, TruncatedTetrahedronDiGraph, TutteGraph]
    types_1param = [CompleteGraph, CompleteDiGraph,
            StarGraph, StarDigraph, PathGraph,
            PathDiGraph, CycleGraph, CycleDiGraph, WheelGraph, WheelDiGraph,
            BinaryTree, Doublebinary_tree, RoachGraph,
            LadderGraph, Circularladder_graph]
    types_2params = [CompleteBipartiteGraph, LollipopGraph, BarbellGraph,
        TuranGraph, CliqueGraph]
    for G in types_0
        @test_deprecated G()
    end
    for G in types_1param
        @test_deprecated G(5)
    end
    for G in types_2params
        @test_deprecated G(5, 2)
    end
    @test_deprecated CompleteMultipartiteGraph([3, 5])
    @test_deprecated Grid([3, 5])
end
