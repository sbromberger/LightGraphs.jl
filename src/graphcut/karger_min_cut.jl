"""
    karger_min_cut(g)

Perform [Karger Minimum Cut](https://en.wikipedia.org/wiki/Karger%27s_algorithm)
to find the minimum cut of graph `g` with some probability of success.
A cut is a partition of `vertices(g)` into two non-empty sets.
The size of a cut is the number of edges crossing the two non-empty sets.

### Implementation Notes
The cut is represented by an integer array.
If `cut[v] == 1` then `v` is in the first non-empty set.
If `cut[v] == 2` then `v` is in the second non-empty set.
`cut[1] = 1`.

If |V| < 2 then `cut[v] = 0` for all `v`.

### Performance
Runtime: O(|E|)
Memory: O(|E|)
"""
function karger_min_cut(g::AbstractGraph{T}) where T <: Integer

    nvg = nv(g)
    nvg < 2 && return zeros(Int, nvg)
    nvg == 2 && return [1, 2]

    connected_vs = IntDisjointSets(nvg)
    num_components = nvg

    for e in shuffle(collect(edges(g)))
        s = src(e)
        d = dst(e)
        if !in_same_set(connected_vs, s, d)
            union!(connected_vs, s, d)
            num_components -= one(T)
            (num_components <= 2) && break
        end
    end

    return [(in_same_set(connected_vs, one(T), v) ? 1 : 2) for v in vertices(g)]
end

"""
    karger_cut_cost(g, cut)

Find the number of crossing edges in a cut of graph `g` where the cut is represented
by the integer array, `cut`.
"""
karger_cut_cost(g::AbstractGraph{T}, cut::Vector{<:Integer}) where T <: Integer =
count((e::Edge{T})->cut[src(e)] != cut[dst(e)], edges(g))

"""
    karger_cut_edges(g, cut)

Find the crossing edges in a cut of graph `g` where the cut is represented
by the integer array, `cut`.
"""
karger_cut_edges(g::AbstractGraph{T}, cut::Vector{<:Integer}) where T <: Integer =
[e for e in edges(g) if cut[src(e)] != cut[dst(e)]]
