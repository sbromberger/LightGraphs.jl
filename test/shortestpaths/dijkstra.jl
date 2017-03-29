d1 = float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
d2 = sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

y = dijkstra_shortest_paths(g4, 2, d1)
z = dijkstra_shortest_paths(g4, 2, d2)

@test y.parents == z.parents == [0, 0, 2, 3, 4]
@test y.dists == z.dists == [Inf, 0, 6, 17, 33]

y = dijkstra_shortest_paths(g4, 2, d1; allpaths=true)
z = dijkstra_shortest_paths(g4, 2, d2; allpaths=true)
@test z.predecessors[3] == y.predecessors[3] == [2]

@test enumerate_paths(z) == enumerate_paths(y)
@test enumerate_paths(z)[4] ==
    enumerate_paths(z,4) ==
    enumerate_paths(y,4) == [2,3,4]

g = PathGraph(5)
add_edge!(g,2,4)
d = ones(Int, 5,5)
d[2,3] = 100
z = dijkstra_shortest_paths(g,1,d)
@test z.dists == [0, 1, 3, 2, 3]
@test z.parents == [0, 1, 4, 2, 4]


# small function to reconstruct the shortest path; I copied it from somewhere, can't find the original source to give the credits
# @Beatzekatze on github
spath(target, dijkstraStruct, sourse) = target == sourse ? target : [spath(dijkstraStruct.parents[target], dijkstraStruct, sourse) target]
function spaths(ds, targets, source)
    shortest_paths = []
    for i in targets
        push!(shortest_paths,spath(i,ds,source))
    end
    return shortest_paths
    
end


G = LightGraphs.Graph()
add_vertices!(G,4)
add_edge!(G,2,1)
add_edge!(G,2,3)
add_edge!(G,1,4)
add_edge!(G,3,4)
add_edge!(G,2,2)
w = [0. 3. 0. 1.;
    3. 0. 2. 0.;
    0. 2. 0. 3.;
    1. 0. 3. 0.]
ds = dijkstra_shortest_paths(G,2,w)
# this loop reconstructs the shortest path for nodes 1, 3 and 4
@test spaths(ds, [1,3,4], 2) == Array[[2 1],
                                      [2 3],
                                      [2 1 4]]

# here a selflink at source is introduced; it should not change the shortest paths
w[2,2] = 10.0
ds = dijkstra_shortest_paths(G,2,w)
shortest_paths = []
# this loop reconstructs the shortest path for nodes 1, 3 and 4
@test spaths(ds, [1,3,4], 2) == Array[[2 1],
                                      [2 3],
                                      [2 1 4]]

