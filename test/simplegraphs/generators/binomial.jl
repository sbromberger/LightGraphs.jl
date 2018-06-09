# NOTE: These tests are not part of the active test suite, because they require Distributions.jl.
# DO NOT INCORPORATE INTO runtests.jl.

using Distributions
using LightGraphs
using StatsBase
using Base.Test
import Random

import Base: -
import LightGraphs: randbn
import StatsBase: SummaryStats

function -(s::SummaryStats, t::SummaryStats)
    return SummaryStats(
        s.mean - t.mean,
        s.min - t.min,
        s.q25 - t.q25,
        s.median - t.median,
        s.q75 - t.q75,
        s.max - t.max)
end
function binomial_test(n, p, s)
    drand = rand(Binomial(n, p), s)
    lrand = Int64[randbn(n, p) for i in 1:s]

    ds = @show summarystats(drand)
    ls = @show summarystats(lrand)
    dσ = @show std(drand)
    lσ = @show std(lrand)

    summarydiff = @show ds - ls
    @test abs(summarydiff.mean) / ds.mean < .10
    @test abs(summarydiff.median) / ds.median < .10
    @test abs(summarydiff.q25) / ds.q25 < .10
    @test abs(summarydiff.q75) / ds.q75 < .10

    @show dσ - lσ
    @test abs(dσ - lσ) / dσ < .10
end
Random.srand(1234)
n = 10000
p = 0.3
s = 100000

for (n, p, s) in [(100, 0.3, 1000), (1000, 0.8, 1000), (10000, 0.25, 1000)]
    binomial_test(n, p, s)
end

