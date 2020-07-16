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
    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)
    seen = zeros(Bool, nvg + 1)

    for v in alg.ordering(g)
        v = T(v)
        seen[v] = true
        colors_used = zeros(Bool, nvg)

        for w in neighbors(g, v)
            if seen[w]
                colors_used[cols[w]] = true
            end
        end

        for i in one(T):nvg
            if colors_used[i] == false
                cols[v] = i
                break;
            end
        end
    end
    return GraphColoring{T}(maximum(cols), cols)
end

"""
    DegreeColoring
A function that creates a [`FixedColoring`](@ref) that colors a graph iteratively in
descending order of the degree of the vertices.
"""
DegreeColoring() = FixedColoring(g-> sortperm(degree(g), rev=true))
