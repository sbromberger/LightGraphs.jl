g = PathGraph(4)
add_vertices!(g, 10)
add_edge!(g, 5, 6)
add_edge!(g, 6, 7)
add_edge!(g, 8, 9)
add_edge!(g, 10, 9)


cc = connected_components(g)


@test length(cc) == 3 && sort(cc[3]) == [8, 9, 10]


# graph from https://en.wikipedia.org/wiki/Strongly_connected_component
h = DiGraph(8)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,2,5);
add_edge!(h,2,6); add_edge!(h,3,4); add_edge!(h,3,7);
add_edge!(h,4,3); add_edge!(h,4,8); add_edge!(h,5,1);
add_edge!(h,5,6); add_edge!(h,6,7); add_edge!(h,7,6);
add_edge!(h,8,4); add_edge!(h,8,7)

scc = strongly_connected_components(h)
wcc = weakly_connected_components(h)

@test length(scc) == 3 && sort(scc[3]) == [1, 2, 5]
@test length(wcc) == 1 && length(wcc[1]) == nv(h)
