"""
    struct FixedColoring <: ColoringAlgorithm

A struct representing a [`ColoringAlgorithm`](@ref) that colors a graph iteratively using
a given vertex ordering function.

### Required Arguments
- `ordering::Function g->iterable`: the function to use to order the vertices.
sortest degree).
"""
struct FixedColoring{F <: Function}
    ordering::F
end
FixedColoring(ordering::AbstractVector) = FixedColoring(_->ordering)
FixedColoring(;ordering::AbstractVector) = FixedColoring(_->ordering)

function color(g::AbstractGraph{T}, alg::FixedColoring) where {T <: Integer}
    nvg = nv(g)
    cols = zeros(T, nvg)
    S = IntSet()

    for u in alg.ordering(g)
        mincolor = one(T)
        for v in neighbors(g, u)
            if cols[v] != 0
                push!(S, cols[v])
            end
        end
        for c in S
            c != mincolor && break
            mincolor += one(T)
        end
        cols[u] = mincolor
        empty!(S)
    end
    return GraphColoring{T}(maximum(cols), cols)
end

"""
    DegreeColoring

A function that creates a [`FixedColoring`](@ref) that colors a graph iteratively in
descending order of the degree of the vertices.
"""
DegreeColoring() = FixedColoring(g-> sortperm(degree(g), rev=true))
