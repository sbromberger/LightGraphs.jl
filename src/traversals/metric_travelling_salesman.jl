"""
	dfs_short_circuit(g, s)

`g` is a spanning tree of some graph.
Converts the spanning tree into a tour starting at `s`by
performing depth first search on it but avoids traversing a node more than once.
The tour is represented by a permutation of the vertices of the graph. 
"""
function dfs_short_circuit(g::AbstractGraph, s::T) where T <: Integer

	nvg = nv(g)
    seen = zeros(Bool, nvg)
    S = Vector{T}()
    tour = Vector{T}()
    sizehint!(S, nvg)
    sizehint!(tour, nvg)
    push!(S, s)
    push!(tour, s)
    seen[s] = true

    @inbounds while !isempty(S)
        v = S[end]
        u = zero(T)
        for n in outneighbors(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == zero(T)
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            push!(tour, u)
        end
    end
    return tour
end

"""
	metric_travelling_salesman(g, s)

`g` is a complete undirected graph.
The weights of `g` represented by `distmx` obey the triangle inequality.
Outputs an approximate minimum weight tour `g` represented by a permutation 
of the vertices of `g`.

### Performance
O(|V|^2*log(|V|))

### Approximation Factor
2

### Notes
Triangular inequality: distmx[a, c] <= distmx[a, b] + distmx[b, c] for all vertices in `g`.

### Implementation Notes
Perfrom [Approximate Metric Travaelling Salesman](http://www.cs.tufts.edu/~cowen/advanced/2002/adv-lect3.pdf).
"""
function metric_travelling_salesman(
	g::AbstractGraph{T},
	distmx::AbstractMatrix{U}
	) where T<: Integer where U<: Real
    
    is_directed(g) && return Vector{Edge}()

    mst_tmp = prim_mst(g, distmx)
    #Prim returns Vector{Edge}, we require Vector{Edge{T}}
	mst = SimpleGraphFromIterator([Edge{T}(e.src, e.dst) for e in mst_tmp])

    return dfs_short_circuit(mst, one(T))
end
