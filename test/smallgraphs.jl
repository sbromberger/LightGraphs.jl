g = CompleteDiGraph(5)
@test nv(g) == 5 && ne(g) == 20
g = CompleteGraph(5)
@test nv(g) == 5 && ne(g) == 10

g = CompleteBipartiteGraph(5, 8)
@test nv(g) == 13 && ne(g) == 40

g = StarDiGraph(5)
@test nv(g) == 5 && ne(g) == 4
g = StarGraph(5)
@test nv(g) == 5 && ne(g) == 4
g = StarGraph(1)
@test nv(g) == 1 && ne(g) == 0

g = PathDiGraph(5)
@test nv(g) == 5 && ne(g) == 4
g = PathGraph(5)
@test nv(g) == 5 && ne(g) == 4

g = CycleDiGraph(5)
@test nv(g) == 5 && ne(g) == 5
g = CycleGraph(5)
@test nv(g) == 5 && ne(g) == 5

g = WheelDiGraph(5)
@test nv(g) == 5 && ne(g) == 8
g = WheelGraph(5)
@test nv(g) == 5 && ne(g) == 8

g = DiamondGraph()
@test nv(g) == 4 && ne(g) == 5

g = BullGraph()
@test nv(g) == 5 && ne(g) == 5

g = ChvatalGraph()
@test nv(g) == 12 && ne(g) == 24

g = CubicalGraph()
@test nv(g) == 8 && ne(g) == 12


g = DesarguesGraph()
@test nv(g) == 20 && ne(g) == 30

g = DodecahedralGraph()
@test nv(g) == 20 && ne(g) == 30

g = FruchtGraph()
@test nv(g) == 20 && ne(g) == 18

g = HeawoodGraph()
@test nv(g) == 14 && ne(g) == 21

g = HouseGraph()
@test nv(g) == 5 && ne(g) == 6

g = HouseXGraph()
@test nv(g) == 5 && ne(g) == 8

g = IcosahedralGraph()
@test nv(g) == 12 && ne(g) == 30

g = KrackhardtKiteGraph()
@test nv(g) == 10 && ne(g) == 18

g = MoebiusKantorGraph()
@test nv(g) == 16 && ne(g) == 24

g = OctahedralGraph()
@test nv(g) == 6 && ne(g) == 12

g = PappusGraph()
@test nv(g) == 18 && ne(g) == 27

g = PetersenGraph()
@test nv(g) == 10 && ne(g) == 15

g = SedgewickMazeGraph()
@test nv(g) == 8 && ne(g) == 10

g = TetrahedralGraph()
@test nv(g) == 4 && ne(g) == 6

g = TruncatedCubeGraph()
@test nv(g) == 24 && ne(g) == 36

g = TruncatedTetrahedronGraph()
@test nv(g) == 12 && ne(g) == 18 && !is_directed(g)

g = TruncatedTetrahedronDiGraph()
@test nv(g) == 12 && ne(g) == 18 && is_directed(g)

g = TutteGraph()
@test nv(g) == 46 && ne(g) == 69
