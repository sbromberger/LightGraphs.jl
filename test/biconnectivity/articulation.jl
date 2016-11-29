g = Graph(13)
add_edge!(g, 1, 7)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 12, 13)
add_edge!(g, 10, 13)
add_edge!(g, 10, 12)
add_edge!(g, 12, 11)
add_edge!(g, 5, 4)
add_edge!(g, 6, 4)
add_edge!(g, 8, 9)
add_edge!(g, 6, 5)
add_edge!(g, 1, 6)
add_edge!(g, 7, 5)
add_edge!(g, 7, 3)
add_edge!(g, 7, 8)
add_edge!(g, 7, 10)
add_edge!(g, 7, 12)

art = articulation(g)
ans = [1, 7, 8, 12]
@test art == ans

for level in 1:6
    tree = LightGraphs.BinaryTree(level)
    artpts = articulation(tree)
    @test artpts == collect(1:(2^(level-1)-1))
end

h = LightGraphs.blkdiag(WheelGraph(5), WheelGraph(5))
add_edge!(h, 5,6)
@test articulation(h) == [5,6]