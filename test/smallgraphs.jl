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

g = crosspath(3, BinaryTree(2))
#= f = Vector{Vector{Int}}[[2 3 4]; =#  
#=      [1 5]; =#
#=      [1 6]; =#
#=      [1 5 6 7]; =#
#=      [2 4 8]; =#
#=      [3 4 9]; =#
#=      [4 8 9]; =#
#=      [5 7]; =#
#=      [6 7] =# 
#=     ] =#
I = [1,1,1,2,2,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,8,9,9]
J = [2,3,4,1,5,1,6,1,5,6,7,2,4,8,3,4,9,4,8,9,5,7,6,7]
V = ones(Int, length(I))
Adj = sparse(I,J,V)
@test Adj == sparse(g)

rg3 = RoachGraph(3)
#= [3] =#      
#=  [4] =#      
#=  [1,5] =#    
#=  [2,6] =#    
#=  [3,7] =#    
#=  [4,8] =#    
#=  [9,8,5] =#  
#=  [10,7,6] =# 
#=  [11,10,7] =#
#=  [8,9,12] =# 
#=  [9,12] =#   
#=  [10,11] =#  
I = [ 1,2,3,3,4,4,5,5,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,12,12 ]
J = [ 3,4,1,5,2,6,3,7,4,8,9,8,5,10,7,6,11,10,7,8,9,12,9,12,10,11 ]
V = ones(Int, length(I))
Adj = sparse(I,J,V)
@test Adj == sparse(rg3)
