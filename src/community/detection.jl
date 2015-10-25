"""
Community detection using the spectral properties of
the non-backtracking matrix of `g` (see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

`g`: imput Graph
`k`: number of communities to detect
"""
function community_detection_nback(g::Graph, k::Int)
    #TODO insert check on connected_components
    #TODO implement k-menas for k > 2
    c = ones(Int, nv(g))
    B, edgeid = non_backtracking_matrix(g)
    λ, eigv = eig(B)
    idx = sortperm(λ, lt=(x,y)-> abs(x) > abs(y))[2:k] #the second eigenvector is the relevant one
    ϕ = zeros(Float64, k-1, nv(g))
    for n=1:k-1
        v= eigv[:,idx[n]]
        for i=1:nv(g)
            for j in neighbors(g, i)
                u = edgeid[Edge(j,i)]
                ϕ[n,i] += v[u]
            end
        end
    end

    if k==2
        for i=1:nv(g)
            c[i] = ϕ[1,i] > 0 ?  1 : 2
        end
    else
        c = kmeans(ϕ, k).assignments
    end

    c
end
