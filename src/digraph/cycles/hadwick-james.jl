"""
    simplecycles_hadwick_james(g)

Find circuits (including self-loops) in `g` using the algorithm
of Hadwick & James.

### References
- Hadwick & James, "Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs", 2008
"""
function simplecycles_hadwick_james end
@traitfn function simplecycles_hadwick_james(g::::IsDirected)
    nvg = nv(g)
    T = eltype(g)
    B = Vector{Vector{T}}()
    for i in vertices(g)
        push!(B, Vector{T}())
    end
    blocked = zeros(Bool, nvg)
    stack = Vector{T}()
    cycles = Vector{Vector{T}}()
    for v in vertices(g)
        circuit_recursive!(g, v, v, blocked, B, stack, cycles)
        resetblocked!(blocked)
        resetB!(B)
    end
    return cycles
end

"""
    resetB!(B)

Reset B work structure.
"""
resetB!(B) = map!(empty!, B, B)

"""
    resetblocked!(blocked)

Reset vector of `blocked` vertices.
"""
resetblocked!(blocked) = fill!(blocked, false)

"""
    circuit_recursive!(g, v1, v2, blocked, B, stack, cycles)

Find circuits in `g` recursively starting from v1.
"""
function circuit_recursive! end
@traitfn function circuit_recursive!{T<:Integer}(g::::IsDirected, v1::T, v2::T, blocked::AbstractVector, B::Vector{Vector{T}}, stack::Vector{T}, cycles::Vector{Vector{T}})
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
            f = circuit_recursive!(g, v1, w, blocked, B, stack, cycles)
        end
    end
    if f
        unblock!(v2, blocked, B)
    else
        for w in Av
            (w < v1) && continue
            if !(v2 in B[w])
                push!(B[w], v2)
            end
        end
    end
    pop!(stack)
    return f
end

"""
    unblock!(v, blocked, B)

Unblock the value `v` from the `blocked` list and remove from `B`.
"""
function unblock!(v::T, blocked::AbstractVector, B::Vector{Vector{T}}) where T
    blocked[v] = false
    wPos = 1
    Bv = B[v]
    while wPos <= length(Bv)
        w = Bv[wPos]
        wPos += 1 - (length(Bv) - length(filter!(v -> v == w, Bv)))
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
    return nothing
end
