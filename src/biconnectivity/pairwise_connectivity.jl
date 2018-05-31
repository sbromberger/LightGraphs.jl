"""
	lower_bound_pairwise_connectivity(g, s, t)

Obtain a lower bound on the number of vertices (other than `s` and `t`) that must be removed from
`g` to disconnect `s` and `t`.

### Performance
Runtime: O(|V|*|E|)

### References
[Fast approximation algorithms for finding node-independent paths in networks](http://eclectic.ss.uci.edu/~drwhite/working.pdf),
Douglas R. White, M. E. J. Newman. SSRN Electronic Journal, 2001.
"""
function lower_bound_pairwise_connectivity(
    g::AbstractGraph{T},
    s::Integer, 
    t::Integer
    ) where T <: Integer

    (!has_vertex(g, s) || !has_vertex(g, t) || s == t || has_edge(g, s, t)) && return typemax(T)

    deleted = zeros(Bool, nv(g))
    connectivity = zero(T)
    excluded = Vector{T}()
    sizehint!(excluded, nv(g))

    while true
        path = get_path(g, s, t, excluded) #s and t are valid
        path[1] == 0 && break
        connectivity += one(T)
        append!(excluded, path)
    end
    return connectivity
end
