g = PathGraph(4)
add_vertices!(g,10)
add_edge!(g,5,6)
add_edge!(g,6,7)
add_edge!(g,8,9)
add_edge!(g,10,9)


cc = connected_components(g)


@test length(cc) == 3 && sort(cc[3]) == [8,9,10]


# graph from https://en.wikipedia.org/wiki/Strongly_connected_component
h = DiGraph(8)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,2,5);
add_edge!(h,2,6); add_edge!(h,3,4); add_edge!(h,3,7);
add_edge!(h,4,3); add_edge!(h,4,8); add_edge!(h,5,1);
add_edge!(h,5,6); add_edge!(h,6,7); add_edge!(h,7,6);
add_edge!(h,8,4); add_edge!(h,8,7)

scc = strongly_connected_components(h)
wcc = weakly_connected_components(h)

@test length(scc) == 3 && sort(scc[3]) == [1,2,5]
@test length(wcc) == 1 && length(wcc[1]) == nv(h)

h = DiGraph(6)
add_edge!(h,1,3); add_edge!(h,3,4); add_edge!(h,4,2); add_edge!(h,2,1)
add_edge!(h,3,5); add_edge!(h,5,6); add_edge!(h,6,4)

scc = strongly_connected_components(h)

@test length(scc) == 1 && sort(scc[1]) == [1:6;]

# tests from Graphs.jl
h = DiGraph(4)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,3,1); add_edge!(h,4,1)
scc = strongly_connected_components(h)
@test length(scc) == 2 && sort(scc[1]) == [1:3;] && sort(scc[2]) == [4]

h = DiGraph(12)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,2,4); add_edge!(h,2,5);
add_edge!(h,3,6); add_edge!(h,4,5); add_edge!(h,4,7); add_edge!(h,5,2);
add_edge!(h,5,6); add_edge!(h,5,7); add_edge!(h,6,3); add_edge!(h,6,8);
add_edge!(h,7,8); add_edge!(h,7,10); add_edge!(h,8,7); add_edge!(h,9,7);
add_edge!(h,10,9); add_edge!(h,10,11); add_edge!(h,11,12); add_edge!(h,12,10)

scc = strongly_connected_components(h)
@test length(scc) == 4
@test sort(scc[1]) == [7,8,9,10,11,12]
@test sort(scc[2]) == [3, 6]
@test sort(scc[3]) == [2, 4, 5]
@test scc[4] == [1]
