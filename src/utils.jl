"""
sample!([rng,] a, k; exclude = ())

Sample `k` element from array `a` without repetition and eventually excluding elements in `exclude`.
Pay attention, it changes the order of the elements in `a`.
"""
function sample!(rng::AbstractRNG, a::AbstractArray, k::Integer; exclude = ())
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

sample!(a::AbstractArray, k::Integer; exclude = ()) = sample!(getRNG(), a, k; exclude = exclude)

"""
sample([rng,] r, k; exclude = ())
Sample `k` element from unit range `r` without repetition and eventually excluding elements in `exclude`.
Unlike `sample!`, does not produce side effects.
"""
sample(a::UnitRange, k::Integer; exclude = ()) = sample!(getRNG(), collect(a), k; exclude = exclude)

getRNG(seed::Integer = -1) = seed >= 0 ? MersenneTwister(seed) : Base.Random.GLOBAL_RNG
