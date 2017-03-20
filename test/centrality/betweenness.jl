@testset "Betweenness" begin
    # self loops
    s2 = DiGraph(3)
    add_edge!(s2,1,2); add_edge!(s2,2,3); add_edge!(s2,3,3)
    s1 = Graph(s2)
    g3 = PathGraph(5)

    function readcentrality(f::AbstractString)
        f = open(f,"r")
        c = Vector{Float64}()
        while !eof(f)
            line = chomp(readline(f))
            push!(c, float(line))
        end
        return c
    end


    gint = load(joinpath(testdir,"testdata","graph-50-500.jgz"), "graph-50-500")

    c = readcentrality(joinpath(testdir,"testdata","graph-50-500-bc.txt"))
    for g in testdigraphs(gint)
        z = betweenness_centrality(g)
        @test map(Float32, z) == map(Float32, c)

        y = betweenness_centrality(g, endpoints=true, normalize=false)
        @test @inferred(round.(y[1:3],4)) ==
            round.([122.10760591498584, 159.0072453120582, 176.39547945994505], 4)

        x = betweenness_centrality(g,3)
        @test @inferred(length(x)) == 50
    end

    @test @inferred(betweenness_centrality(s1)) == [0, 1, 0]
    @test @inferred(betweenness_centrality(s2)) == [0, 0.5, 0]

    g = Graph(2)
    add_edge!(g,1,2)
    z = betweenness_centrality(g; normalize=true)
    @test @inferred(z[1]) == z[2] == 0.0
    z2 = betweenness_centrality(g, vertices(g))
    z3 = betweenness_centrality(g, [vertices(g);])

    @test z == z2 == z3


    z = betweenness_centrality(g3; normalize=false)
    @test @inferred(z[1]) == z[5] == 0.0
end
