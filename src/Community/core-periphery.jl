"""
    struct Degree <: CorePeripheryAlgorithm

A struct representing a degree-based approach to core-periphery detection.

### Implementation Notes
Degree-based core-periphery is only defined for undirected graphs.

### References
- [Lip](http://arxiv.org/abs/1102.5511))

# Examples
```jldoctest
julia> using LightGraphs

julia> core_periphery(star_graph(5), Degree())
5-element Array{Int64,1}:
 1
 2
 2
 2
 2

julia> core_periphery(path_graph(3), Degree())
3-element Array{Int64,1}:
 2
 1
 2
```
"""
struct Degree <: CorePeripheryAlgorithm end

@traitfn function core_periphery(g::::(!IsDirected), ::Degree)
    degs = degree(g)
    p = sortperm(degs, rev=true)
    s = sum(degs) / 2.
    sbest = +Inf
    kbest = 0
    for k = 1:nv(g) - 1
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
