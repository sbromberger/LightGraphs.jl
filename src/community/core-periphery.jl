"""
    core_periphery_deg(g)

Compute the degree-based core-periphery for graph `g`. Return the vertex
assignments (1 for core and 2 for periphery) for each node in `g`.

References:
    [Lip](http://arxiv.org/abs/1102.5511))
"""
function core_periphery_deg end
@traitfn function core_periphery_deg(g::::(!IsDirected))
    degs = degree(g)
    p = sortperm(degs, rev=true)
    s = sum(degs) / 2.
    sbest = +Inf
    kbest = 0
    for k = 1:nv(g)-1
        s = s + k  - 1 - degree(g, p[k])
        if s < sbest
            sbest = s
            kbest = k
        end
    end
    c = 2 + zeros(Int, nv(g))
    c[p[1:kbest]] = 1
    c
end
