@testset "Karp Minimum Cycle Mean" begin
     g = DiGraph(12)
     w = [0. 0.  0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 0.  0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 0.  0. 0. 0. 0. 0. 0.  1.1 0.0  0.  0.
          0. 1.2 0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 1.  0. 0. 0. 0. 0. 0.  1.3 0.0  0.  0.
          0. 1.2 0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 1.  0. 0. 0. 0. 0. 0.  1.3 0.0  0.  0.
          0. 0.  0. 0. 0. 0. 0. 0.  0.  0.0  0.  0.
          0. 0.  0. 0. 0. 0. 0. 0.  0.  0.0  0.4 0.
          0. 0.  0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 0.  0. 0. 0. 0. 1. 0.  0.  0.0  0.  0.
          0. 0.  0. 0. 0. 0. 0. 0.  1.2 0.0  0.  0.]
     add_edge!(g, 1, 7)
     add_edge!(g, 2, 7)
     add_edge!(g, 3, 9)
     add_edge!(g, 4, 2)
     add_edge!(g, 4, 7)
     add_edge!(g, 5, 2)
     add_edge!(g, 5, 9)
     add_edge!(g, 6, 2)
     add_edge!(g, 6, 7)
     add_edge!(g, 7, 2)
     add_edge!(g, 7, 9)
     add_edge!(g, 9, 11)
     add_edge!(g, 10, 7)
     add_edge!(g, 11, 7)
     add_edge!(g, 12, 9)

     c, λ = karp_minimum_cycle_mean(g, w)
     @test c == [9, 11, 7]
     @test λ == 0.9

    w = [Inf  Inf    Inf  Inf  Inf  Inf   -0.09 Inf  Inf    Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf   -0.06 Inf  Inf    Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf  Inf    Inf   -0.01 Inf  Inf    Inf
         Inf   -0.19 Inf  Inf  Inf  Inf   -0.09 Inf  Inf    Inf  Inf    Inf
         Inf   -0.02 Inf  Inf  Inf  Inf  Inf    Inf   -0.03 Inf  Inf    Inf
         Inf   -0.19 Inf  Inf  Inf  Inf   -0.09 Inf  Inf    Inf  Inf    Inf
         Inf   -0.02 Inf  Inf  Inf  Inf  Inf    Inf   -0.03 Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf  Inf    Inf  Inf    Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf  Inf    Inf  Inf    Inf    0.39 Inf
         Inf  Inf    Inf  Inf  Inf  Inf   -0.09 Inf  Inf    Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf   -0.06 Inf  Inf    Inf  Inf    Inf
         Inf  Inf    Inf  Inf  Inf  Inf  Inf    Inf   -0.01 Inf  Inf    Inf]

    g = DiGraph(12)
    add_edge!(g, 1, 7)
    add_edge!(g, 2, 7)
    add_edge!(g, 3, 9)
    add_edge!(g, 4, 2)
    add_edge!(g, 4, 7)
    add_edge!(g, 5, 2)
    add_edge!(g, 5, 9)
    add_edge!(g, 6, 2)
    add_edge!(g, 6, 7)
    add_edge!(g, 7, 2)
    add_edge!(g, 7, 9)
    add_edge!(g, 9, 11)
    add_edge!(g, 10, 7)
    add_edge!(g, 11, 7)
    add_edge!(g, 12, 9)

    c, λ = karp_minimum_cycle_mean(g, w)
    @test λ == -0.04
    @test c == [2, 7]

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
