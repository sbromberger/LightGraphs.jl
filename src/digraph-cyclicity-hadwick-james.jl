@doc_str """
Find circuits (including self-loops) using the algorithm of Hadwick & James
("Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs", 2008)
"""
function simplecycles_hadwick_james end
@traitfn function simplecycles_hadwick_james(g::::IsDirected)
    nvg = nv(g)
    B = [Int[] for i in 1:nvg]
    blocked = [false for i in 1:nvg]
    stack = Int[]
    cycles = Vector{Vector{Int}}()
    for v in vertices(g)
        circuit_recursive!(g, v, v, blocked, B, stack, cycles)
        resetblocked!(blocked)
        resetB!(B)
    end
    return cycles
end

"""
Reset B work structure.
"""
resetB!(B) = map!(empty!, B, B)

"""
Reset vector of "blocked" vertices.
"""
resetblocked!(blocked) = fill!(blocked, false)

@doc_str """
Find circuits starting from v1 recursively.
"""
function circuit_recursive! end
@traitfn function circuit_recursive!(g::::IsDirected, v1::Int, v2::Int, blocked::Vector{Bool}, B::Vector{Vector{Int}}, stack::Vector{Int}, cycles::Vector{Vector{Int}})
    f = false
    push!(stack, v2)
    blocked[v2] = true

    Av = out_neighbors(g, v2)
    for w in Av
        (w < v1) && continue
        if w == v1 # Found a circuit
            push!(cycles, copy(stack))
            f = true
        elseif !blocked[w]
            if circuit_recursive!(g, v1, w, blocked, B, stack, cycles)
                f = true
            end
        end
    end
    if f
        unblock!(v2, blocked, B)
    else
        for w in Av
            (w < v1) && continue
            if !in(v2, B[w])
                push!(B[w], v2)
            end
        end
    end
    pop!(stack)
    return f
end

"""
Simultaneously count and remove occurences of a value `val` in the array `list`.
"""
function countAndFilter!{T}(val::T, list::AbstractArray{T})
    nocc = 0
    function doFilter(v)
        if v == val
            nocc += 1
            false
        else
            true
        end
    end
    filter!(doFilter, list)
    return nocc
end

"""
Unblock the value `v` from the blocked list and remove from `B`.
"""
function unblock!{T}(v::T, blocked::Vector{Bool}, B::Vector{Vector{T}})
    blocked[v] = false
    wPos = 1
    Bv = B[v]
    while wPos <= length(Bv)
        w = Bv[wPos]
        wPos += 1 - countAndFilter!(w, Bv)
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
    return nothing
end
