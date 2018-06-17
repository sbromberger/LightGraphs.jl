"""
sample!([rng, ]a, k)

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Changes the order of the elements in `a`. For a non-mutating version, see [`sample`](@ref).
"""
function sample!(rng::AbstractRNG, a::AbstractVector, k::Integer; exclude=())
    minsize = k + length(exclude)
    length(a) < minsize && throw(ArgumentError("vector must be at least size $minsize"))
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

sample!(a::AbstractVector, k::Integer; exclude=()) = sample!(getRNG(), a, k; exclude=exclude)

"""
    sample([rng,] r, k)

Sample `k` element from unit range `r` without repetition and eventually excluding elements in `exclude`.

### Optional Arguments
- `exclude=()`: elements in `a` to exclude from sampling.

### Implementation Notes
Unlike [`sample!`](@ref), does not produce side effects.
"""
sample(a::UnitRange, k::Integer; exclude=()) = sample!(getRNG(), collect(a), k; exclude=exclude)

getRNG(seed::Integer=-1) = seed >= 0 ? MersenneTwister(seed) : GLOBAL_RNG

"""
    insorted(item, collection)

Return true if `item` is in sorted collection `collection`.

### Implementation Notes
Does not verify that `collection` is sorted.
"""
function insorted(item, collection)
    index = searchsortedfirst(collection, item)
    @inbounds return (index <= length(collection) && collection[index] == item)
end
