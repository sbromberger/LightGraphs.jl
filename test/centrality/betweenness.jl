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


    gint = loadgraph(joinpath(testdir,"testdata","graph-50-500.jgz"), "graph-50-500")

    c = readcentrality(joinpath(testdir,"testdata","graph-50-500-bc.txt"))
    for g in testdigraphs(gint)
        z  = @inferred(betweenness_centrality(g))
        zp = parallel_betweenness_centrality(g)
        @test all(isapprox(z,zp))
        @test map(Float32, z)  == map(Float32, c)

        y  = @inferred(betweenness_centrality(g, endpoints=true, normalize=false))
        yp = parallel_betweenness_centrality(g, endpoints=true, normalize=false)
        @test all(isapprox(y,yp))
        @test round.(y[1:3],4) ==
            round.([122.10760591498584, 159.0072453120582, 176.39547945994505], 4)



        x  = @inferred(betweenness_centrality(g,3))
        x2  = @inferred(betweenness_centrality(g,collect(1:20)))
        xp2 = parallel_betweenness_centrality(g,collect(1:20))
        @test all(isapprox(x2,xp2))
        @test length(x) == 50
    end

    @test @inferred(betweenness_centrality(s1)) == [0, 1, 0]
    @test parallel_betweenness_centrality(s1)   == [0, 1, 0]

    @test @inferred(betweenness_centrality(s2)) == [0, 0.5, 0]
    @test parallel_betweenness_centrality(s2)   == [0, 0.5, 0]

    g = Graph(2)
    add_edge!(g,1,2)
    z  = @inferred(betweenness_centrality(g; normalize=true))
    zp = parallel_betweenness_centrality(g; normalize=true)
    all(isapprox(z,zp))
    @test z[1] == z[2] == 0.0
    z2  = @inferred(betweenness_centrality(g, vertices(g)))
    zp2 = parallel_betweenness_centrality(g, vertices(g))
    all(isapprox(z2,zp2))
    z3  = @inferred(betweenness_centrality(g, [vertices(g);]))
    zp3 = parallel_betweenness_centrality(g, [vertices(g);])
    all(isapprox(z3,zp3))

    @test z == z2 == z3


    z  = @inferred(betweenness_centrality(g3; normalize=false))
    zp = parallel_betweenness_centrality(g3; normalize=false)
    all(isapprox(z,zp))
    @test z[1] == z[5] == 0.0
end
