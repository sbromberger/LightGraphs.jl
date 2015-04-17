function readcentrality(f::AbstractString)
    f = open(f,"r")
    c = Float64[]
    while !eof(f)
        line = chomp(readline(f))
        push!(c, float(line))
    end
    return c
end


g = readgraph(joinpath(testdir,"testdata","graph-50-500.jgz"))

c = readcentrality(joinpath(testdir,"testdata","graph-50-500-bc.txt"))
z = betweenness_centrality(g)
if VERSION > v"0.4"
    @test map(Float32, z) == map(Float32, c)
end
y = betweenness_centrality(g, endpoints=true, normalize=false)
@test y[1:3] == [122.10760591498584, 159.0072453120582, 176.39547945994505]
x = betweenness_centrality(g,3)
@test length(x) == 50
