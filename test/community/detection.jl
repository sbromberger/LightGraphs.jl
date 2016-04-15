""" Spectral embedding of the non-backtracking matrix of `g`
(see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

`g`: imput Graph
`k`: number of dimensions in which to embed

return : a matrix ϕ where ϕ[:,i] are the coordinates for vertex i.
"""
function nonbacktrack_embedding_dense(g::Graph, k::Int)
    B, edgeid = non_backtracking_matrix(g)
    λ,eigv,conv = eigs(B, nev=k+1, v0=ones(Float64, size(B,1)))
    ϕ = zeros(Complex64, k-1, nv(g))
    # TODO decide what to do with the stationary distribution ϕ[:,1]
    # this code just throws it away in favor of eigv[:,2:k+1].
    # we might also use the degree distribution to scale these vectors as is
    # common with the laplacian/adjacency methods.
    for n=1:k-1
        v= eigv[:,n+1]
        for i=1:nv(g)
            for j in neighbors(g, i)
                u = edgeid[Edge(j,i)]
                ϕ[n,i] += v[u]
            end
        end
    end
    return ϕ
end

n = 10; k = 5
pg = PathGraph(n)
ϕ1 = nonbacktrack_embedding(pg, k)'

nbt = Nonbacktracking(pg)
B, emap = non_backtracking_matrix(pg)
Bs = sparse(nbt)
@test sparse(B) == Bs

# check that matvec works
x = ones(Float64, nbt.m)
y = nbt * x
z = B * x
@test norm(y-z) < 1e-8

#check that matmat works and full(nbt) == B
@test norm(nbt*eye(nbt.m) - B) < 1e-8

#check that we can use the implicit matvec in nonbacktrack_embedding
@test size(y) == size(x)
ϕ2 = nonbacktrack_embedding_dense(pg, k)'
@test size(ϕ2) == size(ϕ1)

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

