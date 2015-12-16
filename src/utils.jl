Base.start(it::Void) = nothing
Base.done(it::Void, state::Void) = true
Base.next(it::Void, state::Void) = (nothing, nothing)
Base.length(v::Void) = 0

"""
Sample `k` element from array `a` without repetition and excluding elements in `exclude`.
Pay attention, it changes the order of the elements in `a`.

sample!(rng, a, k; exclude = nothing)
"""
function sample!(rng::AbstractRNG, a::AbstractArray, k::Integer; exclude = nothing)
    length(a) < k + length(exclude) && error("Array too short.")
    res = Vector{eltype(a)}()
    sizehint!(res, k)
    n = length(a)
    i = 1
    while length(res) < k
        r = rand(rng, 1:n-i+1)
        if !(a[r] in exclude)
            push!(res, a[r])
            a[r], a[n-i+1] = a[n-i+1], a[r]
            i += 1
        end
    end
    res
end

getRNG(seed::Integer) = seed >= 0 ? MersenneTwister(seed) : Base.Random.GLOBAL_RNG
