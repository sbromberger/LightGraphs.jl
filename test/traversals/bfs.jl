z = bfs_tree(g5, 1)
visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int,nv(g5)))
LightGraphs.bfs_tree!(visitor, g5, 1)
t = visitor.tree
@test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
@test t == [1,1,1,3]

g = smallgraph(:house)
@test gdistances(g, 2) == [1, 0, 2, 1, 2]
@test gdistances(g, [1,2]) == [0, 0, 1, 1, 2]
@test !is_bipartite(g)

g = Graph(5)
add_edge!(g,1,2); add_edge!(g,1,4)
add_edge!(g,2,3); add_edge!(g,2,5)
add_edge!(g,3,4)
@test is_bipartite(g)


import LightGraphs: TreeBFSVisitorVector, bfs_tree!, TreeBFSVisitor, tree
g = smallgraph(:house)
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
t = tree(parents)
@test typeof(t) <: DiGraph
@test typeof(tvis.tree) <: DiGraph
@test t == tvis.tree
@test ne(t) < nv(t)


g10 = CompleteGraph(10)
@test bipartite_map(g10) == Vector{Int}()

g10 = CompleteBipartiteGraph(10,10)
@test bipartite_map(g10) == Vector{Int}([ones(10); 2*ones(10)])

h10 = blkdiag(g10,g10)
@test bipartite_map(h10) == Vector{Int}([ones(10); 2*ones(10); ones(10); 2*ones(10)])
