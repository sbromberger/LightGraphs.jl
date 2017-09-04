@testset "Karp Minimum Cycle Mean" begin
    # Tricky test case
    # Backward walk from 3 is good:
    # 1 - 2 - 3 - 4 - 3
    # Only the first of the two backward walk from 4 is good:
    # 1 - 3 - 4 - 3 - 4
    # 1 - 2 - 2 - 3 - 4
    # We will do the backward walk from 3 in the test since 0 = F_4(3) < F_4(4) = 1
    tricky = DiGraph(4)
    add_edge!(tricky, 1, 3)
    add_edge!(tricky, 1, 2)
    add_edge!(tricky, 3, 4)
    add_edge!(tricky, 4, 1) # Make it strongly connected
    add_edge!(tricky, 4, 3)
    add_edge!(tricky, 2, 3)
    add_edge!(tricky, 2, 2)
    distmx = [Inf  0.  1. Inf
              Inf  1.  0. Inf
              Inf Inf Inf  0.
               1. Inf  0. Inf]

    c, λ = karp_minimum_cycle_mean(tricky, distmx)
    @test λ == 0.
    @test sort(c) == [3, 4]

    c, λ = karp_minimum_cycle_mean(tricky, distmx .- 2)
    @test λ == -2.
    @test sort(c) == [3, 4]

    # Multiple strongly connected components and one component with one node and no edge
    multi = DiGraph(3)
    add_edge!(multi, 1, 1)
    add_edge!(multi, 2, 2)
    distmx = [0. Inf
              Inf -1]

    c, λ = karp_minimum_cycle_mean(multi, distmx)
    @test λ == -1.
    @test c == [2]
end
