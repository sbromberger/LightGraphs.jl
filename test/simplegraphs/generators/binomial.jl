# NOTE: These tests are not part of the active test suite, because they require Distributions.jl.
# DO NOT INCORPORATE INTO runtests.jl.

using Distributions
using LightGraphs
using StatsBase
using Test
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
        s.max - t.max,
    )
end
function binomial_test(n, p, s)
    drand = rand(Binomial(n, p), s)
    lrand = Int64[randbn(n, p) for i in 1:s]

    ds = summarystats(drand)
    ls = summarystats(lrand)
    dσ = std(drand)
    lσ = std(lrand)

    summarydiff = ds - ls
    @test abs(summarydiff.mean) / ds.mean < 0.10
    @test abs(summarydiff.median) / ds.median < 0.10
    @test abs(summarydiff.q25) / ds.q25 < 0.10
    @test abs(summarydiff.q75) / ds.q75 < 0.10

    @test abs(dσ - lσ) / dσ < 0.10
end
seed!(1234)
n = 10000
p = 0.3
s = 100000

@testset "($n, $p, $s)" for (n, p, s) in [(100, 0.3, 1000), (1000, 0.8, 1000), (10000, 0.25, 1000)]
    binomial_test(n, p, s)
end
