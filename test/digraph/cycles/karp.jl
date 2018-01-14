@testset "Karp Minimum Cycle Mean" begin
     g1 = SimpleDiGraph(12)
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
     add_edge!(g1, 1, 7)
     add_edge!(g1, 2, 7)
     add_edge!(g1, 3, 9)
     add_edge!(g1, 4, 2)
     add_edge!(g1, 4, 7)
     add_edge!(g1, 5, 2)
     add_edge!(g1, 5, 9)
     add_edge!(g1, 6, 2)
     add_edge!(g1, 6, 7)
     add_edge!(g1, 7, 2)
     add_edge!(g1, 7, 9)
     add_edge!(g1, 9, 11)
     add_edge!(g1, 10, 7)
     add_edge!(g1, 11, 7)
     add_edge!(g1, 12, 9)

     for g in testdigraphs(g1)
         c, λ = karp_minimum_cycle_mean(g, w)
         @test c == [9, 11, 7]
         @test λ == 0.9
     end

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

    g2 = SimpleDiGraph(12)
    add_edge!(g2, 1, 7)
    add_edge!(g2, 2, 7)
    add_edge!(g2, 3, 9)
    add_edge!(g2, 4, 2)
    add_edge!(g2, 4, 7)
    add_edge!(g2, 5, 2)
    add_edge!(g2, 5, 9)
    add_edge!(g2, 6, 2)
    add_edge!(g2, 6, 7)
    add_edge!(g2, 7, 2)
    add_edge!(g2, 7, 9)
    add_edge!(g2, 9, 11)
    add_edge!(g2, 10, 7)
    add_edge!(g2, 11, 7)
    add_edge!(g2, 12, 9)

    for g in testdigraphs(g2)
        c, λ = karp_minimum_cycle_mean(g, w)
        @test λ == -0.04
        @test c == [2, 7]
    end

    # Tricky test case
    # Backward walk from 3 is good:
    # 1 - 2 - 3 - 4 - 3
    # Only the first of the two backward walk from 4 is good:
    # 1 - 3 - 4 - 3 - 4
    # 1 - 2 - 2 - 3 - 4
    # We will do the backward walk from 3 in the test since 0 = F_4(3) < F_4(4) = 1
    tricky = SimpleDiGraph(4)
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

    for g in testdigraphs(tricky)
        c, λ = karp_minimum_cycle_mean(g, distmx)
        @test λ == 0.
        @test sort(c) == [3, 4]

        c, λ = karp_minimum_cycle_mean(g, distmx .- 2)
        @test λ == -2.
        @test sort(c) == [3, 4]
    end

    # Multiple strongly connected components and one component with one node and no edge
    multi = SimpleDiGraph(3)
    add_edge!(multi, 1, 1)
    add_edge!(multi, 2, 2)
    distmx = [0. Inf
              Inf -1]

    for g in testdigraphs(multi)
        c, λ = karp_minimum_cycle_mean(g, distmx)
        @test λ == -1.
        @test c == [2]
    end
end
