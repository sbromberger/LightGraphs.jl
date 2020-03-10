"""
    core_periphery_deg(g)

Compute the degree-based core-periphery for graph `g`. Return the vertex
assignments (`1` for core and `2` for periphery) for each node in `g`.

References:
    [Lip](http://arxiv.org/abs/1102.5511))

# Examples
```jldoctest
julia> using LightGraphs

julia> core_periphery_deg(star_graph(5))
5-element Array{Int64,1}:
 1
 2
 2
 2
 2

julia> core_periphery_deg(path_graph(3))
3-element Array{Int64,1}:
 2
 1
 2
```
"""
function core_periphery_deg end
@traitfn function core_periphery_deg(g::::(!IsDirected))
    degs = degree(g)
    p = sortperm(degs, rev = true)
    s = sum(degs) / 2.0
    sbest = +Inf
    kbest = 0
    for k in 1:(nv(g)-1)
        s = s + k - 1 - degree(g, p[k])
        if s < sbest
            sbest = s
            kbest = k
        end
    end
    c = fill(2, nv(g))
    c[p[1:kbest]] .= 1
    c
end
