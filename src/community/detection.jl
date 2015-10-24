"""
Community detection using the spectral properties of
the non-backtracking matrix of `g` REF.

`g`: imput Graph
`k`: number of communities to detect [currently supports only k=2]
"""
function community_detection_nback(g::Graph, k::Int)
    #TODO insert check on connected_components
    #TODO implement k-menas for k > 2
    c = ones(Int, nv(g))
    B, edgeid = non_backtracking_matrix(g)
    λ, v = eig(B)
    idx = sortperm(λ, lt=(x,y)-> abs(x) > abs(y))[2] #the second eigenvector is the relevant one
    v= v[:,idx]
    ϕ = zeros(nv(g))
    for i=1:nv(g)
        for j in neighbors(g, i)
            u = edgeid[Edge(j,i)]
            ϕ[i] += v[u]
        end
        c[i] = ϕ[i] > 0 ?  1 : 2
    end
    c
end
