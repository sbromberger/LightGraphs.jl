n = 10; k = 5
pg = PathGraph(n)
ϕ1 = nonbacktrack_embedding(pg, k)'

nbt = Nonbacktracking(pg)
B, emap = non_backtracking_matrix(pg)

# check that matvec works
x = ones(Float64, nbt.m)
y = nbt * x
z = B * x
@test norm(y-z) < 1e-8

#check that matmat works and full(nbt) == B
@test norm(nbt*eye(nbt.m) - B) < 1e-8

#check that we can use the implicit matvec in nonbacktrack_embedding
@test size(y) == size(x)
ϕ2 = LightGraphs.nonbacktrack_embedding_dense(pg, k)'

#check that this recovers communities in the path of cliques
n=10
g10 = CompleteGraph(n)
z = copy(g10)
for k=2:5
    z = blkdiag(z, g10)
    add_edge!(z, (k-1)*n, k*n)
    c = community_detection_nback(z, k)
    a = collect(n:n:k*n)
    @test length(c[a]) == length(unique(c[a]))
    for i=1:k
        for j=(i-1)*n+1:i*n
            @test c[j] == c[i*n]
        end
    end
end

