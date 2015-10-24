g10 = CompleteGraph(10)
g10 = join(g10, g10)
add_edge!(g10, 1, 11)
c = community_detection_nback(g10, 2)
@test c[1] != c[11]
for i=2:10
    @test c[i] == c[1]
end
for i=11:20
    @test c[i] == c[11]
end
