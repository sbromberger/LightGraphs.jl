using Distributions

@testset "Diffusion Simulation" begin

    ######
    # Check on fully connected, prob = 1
    ######

    g = CompleteGraph(5)
    for i in 1:5
      add_vertex!(g)
    end

    # Basic test. Watch connected vertices
    result = @inferred(diffusion_simulation(g,
                                  1.0,
                                  4,
                                  to_watch=Set(1:5),
                                  initial_at_risk=Set(1:5)
                                  )
             )
    result
    @test result == [5, 5, 5, 5]

    # Watching unconnected vertices
    result = @inferred(diffusion_simulation(g,
                                  1.0,
                                  4,
                                  to_watch=Set(6:10),
                                  initial_at_risk=Set(1:5)
                                  )
               )
    @test  result == [0, 0, 0, 0]

    # Watch subset
    result = @inferred(diffusion_simulation(g,
                                  1.0,
                                  4,
                                  to_watch=Set(1:2),
                                  initial_at_risk=Set(1:5)
                                  )
             )
    result
    @test result == [2, 2, 2, 2]

    result = diffusion_simulation(g,
                                  1.0,
                                  4,
                                  to_watch=Set(1:5),
                                  initial_at_risk=Set(10)
                                  )

    @test result == [0, 0, 0, 0]

    ######
    # Check along path graph
    ######

    g2 = PathGraph(5)
    result = @inferred(diffusion_simulation(g2,
                                  1.0,
                                  4,
                                  to_watch=Set(1:5),
                                  initial_at_risk=Set(1)
                                  )
              )
    @test  result == [2, 3, 4, 5]

    result = @inferred(diffusion_simulation(g2,
                                  1.0,
                                  4,
                                  to_watch=Set(1:5),
                                  initial_at_risk=Set(3)
                                  )
             )
    @test result == [3, 5, 5, 5]

    # Check normalize
    result = @inferred(diffusion_simulation(g,
                                  1.0,
                                  4,
                                  to_watch=Set(1:5),
                                  initial_at_risk=Set(1:5),
                                  normalize_p=true
                                  )
             )
    result
    @test result != [5, 5, 5, 5]

    # Test probability accurate
    runs = 20
    for p in [0.2, 0.4]
        binomial = Binomial(4, p)
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_simulation(g2,
                                                    p,
                                                    4,
                                                    initial_at_risk=Set(1))
                               )
            final_value += result[4]

        end

        # Pretty loose bounds so don't get lots of failed tests.
        # Just want some safeguard.
        # False rate less than 1 in 1000
        # Subtract 1 for initial infection
        avg = final_value / runs - 1
        @test avg < mean(binomial) + std(binomial) / sqrt(runs) * 3.5
        @test avg > mean(binomial) - std(binomial) / sqrt(runs) * 3.5
    end

    ######
    # Check on digraphs
    ######
    gx = PathDiGraph(10)

    result = @inferred(diffusion_simulation(gx,
                                  1.0,
                                  9,
                                  initial_at_risk=Set(1)
                                  )
             )
    @test result == collect(2:10)

    result = @inferred(diffusion_simulation(gx,
                                  1.0,
                                  9,
                                  initial_at_risk=Set(10)
                                  )
             )
    @test result == ones(Int64, 9)

    # Check probabilities
    runs = 20
    for p in [0.2, 0.4]
        binomial = Binomial(10, p)
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_simulation(gx,
                                                    p,
                                                    10,
                                                    initial_at_risk=Set(1))
                               )
            final_value += result[10]

        end

        # Pretty loose bounds so don't get lots of failed tests.
        # Just want some safeguard.
        # False rate less than 1 in 1000
        # Subtract 1 for initial infection
        avg = final_value / runs - 1
        @test avg < mean(binomial) + std(binomial) / sqrt(runs) * 3.5
        @test avg > mean(binomial) - std(binomial) / sqrt(runs) * 3.5
    end


end
