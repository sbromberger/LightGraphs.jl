"""
sample!([rng, ]a, k)

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Changes the order of the elements in `a`. For a non-mutating version, see [`sample`](@ref).
"""
function sample!(rng::AbstractRNG, a::AbstractArray, k::Integer; exclude = ())
    length(a) < k + length(exclude) && error("Array too short.")
    res = Vector{eltype(a)}()
    sizehint!(res, k)
    n = length(a)
    i = 1
    while length(res) < k
        r = rand(rng, 1:(n - i + 1))
        if !(a[r] in exclude)
            push!(res, a[r])
            a[r], a[n - i + 1] = a[n - i + 1], a[r]
            i += 1
        end
    end
    res
end

sample!(a::AbstractArray, k::Integer; exclude = ()) = sample!(getRNG(), a, k; exclude = exclude)

"""
    sample([rng,] r, k)

Sample `k` element from unit range `r` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Unlike [`sample!`](@ref), does not produce side effects.
"""
sample(a::UnitRange, k::Integer; exclude = ()) = sample!(getRNG(), collect(a), k; exclude = exclude)

getRNG(seed::Integer = -1) = seed >= 0 ? MersenneTwister(seed) : Base.Random.GLOBAL_RNG

"""
    insorted(item, collection)

Return true if `item` is in sorted collection `collection`.

### Implementation Notes
Does not verify that `collection` is sorted.
"""
insorted(item, collection) = !isempty(searchsorted(collection, item))

"""
    uniquesorted!(A::AbstractVector)

Remove duplicate items from a sorted array. Returns the modified array `A` with 
items in order of encounter.
"""
# Based on the MIT licenced code of `_groupedunique!` from Jack Devine
# https://github.com/JuliaLang/julia/commit/ce3f853348e23eb6adae211891738058d80b50e7#diff-d39084ec0fef2ad65e4b5fe0fcfaab8e
function uniquesorted!(A::AbstractVector)
    isempty(A) && return A
    idxs = eachindex(A)
    y = first(A)
    state = start(idxs)
    i, state = next(idxs, state)
    for x in A
        if !isequal(x, y)
            i, state = next(idxs, state)
            y = A[i] = x
        end
    end
    resize!(A, i - first(idxs) + 1)
end
