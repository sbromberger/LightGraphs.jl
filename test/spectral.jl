@testset "Spectral" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)
    g5 = DiGraph(4)
    for g in testgraphs(g3)
        @test adjacency_matrix(g, Bool) == adjacency_matrix(g, Bool; dir=:out)
        @test adjacency_matrix(g)[3, 2] == 1
        @test adjacency_matrix(g)[2, 4] == 0
        @test laplacian_matrix(g)[3, 2] == -1
        @test laplacian_matrix(g)[1, 3] == 0
        @test laplacian_spectrum(g)[5] ≈ 3.6180339887498945
        @test adjacency_spectrum(g)[1] ≈ -1.732050807568878
    end


    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    for g in testdigraphs(g5)
        @test adjacency_matrix(g, Bool) == adjacency_matrix(g, Bool; dir=:out)
        @test laplacian_spectrum(g)[3] == laplacian_spectrum(g; dir=:both)[3] == 3.0
        @test laplacian_spectrum(g; dir=:in)[3] == 1.0
        @test laplacian_spectrum(g; dir=:out)[3] == 1.0
    end

    # check adjacency matrices with self loops
    gx = copy(g3)
    add_edge!(gx, 1, 1)
    for g in testgraphs(gx)
        @test adjacency_matrix(g)[1, 1] == 2
    end
    g = copy(g5)
    add_edge!(g, 1, 1)
    @test adjacency_matrix(g)[1, 1] == 1
    @test indegree(g) == sum(adjacency_matrix(g), 1)[1, :]
    @test outdegree(g) == sum(adjacency_matrix(g), 2)[:, 1]
    for g in testdigraphs(g5)
        @test adjacency_spectrum(g)[3] ≈ 0.311 atol = 0.001
    end

    for g in testgraphs(g3)
        @test adjacency_matrix(g) ==
            adjacency_matrix(g, dir=:out) ==
            adjacency_matrix(g, dir=:in) ==
            adjacency_matrix(g, dir=:both)

        @test_throws ErrorException adjacency_matrix(g; dir=:purple)
    end

    #that call signature works
    for g in testdigraphs(g5)
        inmat   = adjacency_matrix(g, Int; dir=:in)
        outmat  = adjacency_matrix(g, Int; dir=:out)
        bothmat = adjacency_matrix(g, Int; dir=:both)

        #relations that should be true
        @test inmat' == outmat
        @test all((bothmat - outmat) .>= 0)
        @test all((bothmat - inmat)  .>= 0)

      #check properties of the undirected laplacian carry over.
        for dir in [:in, :out, :both]
            T = eltype(g)
            amat = adjacency_matrix(g, Float64; dir=dir)
            lmat = laplacian_matrix(g, Float64; dir=dir)
            @test isa(amat, SparseMatrixCSC{Float64,T})
            @test isa(lmat, SparseMatrixCSC{Float64,T})
            evals = eigvals(full(lmat))
            @test all(evals .>= -1e-15) # positive semidefinite
            @test (minimum(evals)) ≈ 0 atol = 1e-13
        end
    end


    for g in testdigraphs(g4)
        # testing incidence_matrix, first directed graph
        @test size(incidence_matrix(g)) == (5, 4)
        @test incidence_matrix(g)[1, 1] == -1
        @test incidence_matrix(g)[2, 1] == 1
        @test incidence_matrix(g)[3, 1] == 0
    end

    for g in testgraphs(g3)
        # now undirected graph
        @test size(incidence_matrix(g)) == (5, 4)
        @test incidence_matrix(g)[1, 1] == 1
        @test incidence_matrix(g)[2, 1] == 1
        @test incidence_matrix(g)[3, 1] == 0

        # undirected graph with orientation
        @test size(incidence_matrix(g; oriented=true)) == (5, 4)
        @test incidence_matrix(g; oriented=true)[1, 1] == -1
        @test incidence_matrix(g; oriented=true)[2, 1] == 1
        @test incidence_matrix(g; oriented=true)[3, 1] == 0
    end

    # spectral distance checks
    for n = 3:10
        polygon = random_regular_graph(n, 2)
        for g in testgraphs(polygon)
            @test spectral_distance(g, g) ≈ 0 atol=1e-8
            @test spectral_distance(g, g, 1) ≈ 0 atol=1e-8
        end
    end
end
