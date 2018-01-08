import Base: full

# just so that we can assert equality of matrices
full(nbt::Nonbacktracking) = full(sparse(nbt))

@testset "Spectral" begin

    g3 = PathGraph(5)
    g4 = PathDiGraph(5)
    g5 = SimpleDiGraph(4)
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

    g10 = CompleteGraph(10)
    for g in testgraphs(g10)
        B, em = non_backtracking_matrix(g)
        @test length(em) == 2 * ne(g)
        @test size(B) == (2 * ne(g), 2 * ne(g))
        for i = 1:10
          @test sum(B[:, i]) == 8
          @test sum(B[i, :]) == 8
        end
        @test !issymmetric(B)

        v = ones(Float64, ne(g))
        z = zeros(Float64, nv(g))
        n10 = Nonbacktracking(g)
        @test size(n10) == (2 * ne(g), 2 * ne(g))
        @test eltype(n10) == Float64
        @test !issymmetric(n10)

        contract!(z, n10, v)

        zprime = contract(n10, v)
        @test z == zprime
        @test z == 9 * ones(Float64, nv(g))
    end

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
    # TESTS FOR Nonbacktracking operator.

    n = 10; k = 5
    pg = CompleteGraph(n)
    # ϕ1 = nonbacktrack_embedding(pg, k)'
    for g in testgraphs(pg)
        nbt = Nonbacktracking(g)
        B, emap = non_backtracking_matrix(g)
        Bs = sparse(nbt)
        @test sparse(B) == Bs
        @test eigs(nbt, nev=1)[1] ≈ eigs(B, nev=1)[1] atol = 1e-5

        # check that matvec works
        x = ones(Float64, nbt.m)
        y = nbt * x
        z = B * x
        @test norm(y - z) < 1e-8

        #check that matmat works and full(nbt) == B
        @test norm(nbt * eye(nbt.m) - B) < 1e-8

        #check that matmat works and full(nbt) == B
        @test norm(nbt * eye(nbt.m) - B) < 1e-8

        #check that we can use the implicit matvec in nonbacktrack_embedding
        @test size(y) == size(x)

        B₁ = Nonbacktracking(g10)

        @test full(B₁) == full(B)
        @test  B₁ * ones(size(B₁)[2]) == B * ones(size(B)[2])
        @test size(B₁) == size(B)
        #   @test norm(eigs(B₁)[1] - eigs(B)[1]) ≈ 0.0 atol=1e-8
        @test !issymmetric(B₁)
        @test eltype(B₁) == Float64
    end
    # END tests for Nonbacktracking

    # spectral distance checks
    for n = 3:10
        polygon = random_regular_graph(n, 2)
        for g in testgraphs(polygon)
            @test spectral_distance(g, g) ≈ 0 atol=1e-8
            @test spectral_distance(g, g, 1) ≈ 0 atol=1e-8
        end
    end
end
