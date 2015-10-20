z = bfs_tree(g5, 1)
@test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)

g = HouseGraph()
@test gdistances(g, 2) == [1, 0, 2, 1, 2]
@test gdistances(g, [1,2]) == [0, 0, 1, 1, 2]
@test !is_bipartite(g)

g = Graph(5)
add_edge!(g,1,2); add_edge!(g,1,4)
add_edge!(g,2,3); add_edge!(g,2,5)
add_edge!(g,3,4)
@test is_bipartite(g)


import LightGraphs: TreeBFSVisitorVector, bfs_tree!, Tree!, TreeBFSVisitor
g = HouseGraph()
n = nv(g)
visitor = TreeBFSVisitorVector(n)
@test length(visitor.tree) == n
parents = visitor.tree
bfs_tree!(visitor, g, 1)
maxdepth = n

function istree(parents::Vector{Int})
    flag = true
    for i in 1:n
        s = i
        depth = 0
        while parents[s] > 0 && parents[s] != s
            s = parents[s]
            depth += 1
            if depth > maxdepth
                return false
            end
        end
    end
    return flag
end
@test istree(parents) == true
tvis = TreeBFSVisitor(visitor)
@test nv(tvis.tree) == nv(g)
@test typeof(tvis.tree) <: DiGraph
tvis = TreeBFSVisitor(n)
tree = Tree!(tvis, parents)
@test tree == tvis.tree
@test ne(tree) <= nv(tree)
pfail = zeros(Int, 10n-2)
@test_throws ErrorException Tree!(tvis, pfail)
