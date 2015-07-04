g = PathGraph(4)

add_vertices!(g,10)
add_edge!(g,5,6)
add_edge!(g,6,7)
add_edge!(g,8,9)
add_edge!(g,10,9)

cc = connected_components(g)



@test length(cc) == 3 && sort(cc[3]) == [8,9,10]


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
# test examples with self-loops from
# Graph-Theoretic Analysis of Finite Markov Chains by J.P. Jarvis & D. R. Shier

# generate figure 1 example
fig1 = spzeros(5,5)
fig1[[3,4,9,10,11,13,18,19,22,24]] = [.5,.4,.1,1.,1.,.2,.3,.2,1.,.3]
fig1 = DiGraph(fig1)
scc_fig1 = Vector[[2,5],[1,3,4]]

# generate figure 3 example
fig3 = spzeros(8,8)
fig3[[1,7,9,13,14,15,18,20,23,27,28,31,33,34,37,45,46,49,57,63,64]] = 1
fig3 = DiGraph(fig3)
scc_fig3 = Vector[[3,4],[2,5,6],[8],[1,7]]

# generate figure 8 example
fig8 = spzeros(6,6)
fig8[[2,10,13,21,24,27,35]] = 1
fig8 = DiGraph(fig8)

scc_fig1 = Vector[[2,5],[1,3,4]]
@test Set(strongly_connected_components(fig1)) == Set(scc_fig1)

scc_fig3 = Vector[[3,4],[2,5,6],[8],[1,7]]
@test Set(strongly_connected_components(fig3)) == Set(scc_fig3)

# construct a n-number edge ring graph (period = n)
n = 10
n_ring_m = spdiagm(ones(n-1),1,n,n); n_ring_m[end,1] = 1
n_ring = DiGraph(n_ring_m)

n_ring_shortcut = copy(n_ring); add_edge!(n_ring_shortcut,Edge(1,4))

@test period(n_ring) == n
@test period(n_ring_shortcut) == 2