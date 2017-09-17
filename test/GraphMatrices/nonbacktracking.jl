# just so that we can assert equality of matrices
import Base: full
full(nbt::Nonbacktracking) = full(sparse(nbt))


@testset "Nonbacktracking" begin
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
end
