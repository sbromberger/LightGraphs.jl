
@testset "Diffusion Simulation" begin

    ######
    # Check on fully connected, prob = 1
    ######

    g = CompleteGraph(5)
    for i in 1:5
      add_vertex!(g)
    end

    # Basic test. Watch connected vertices
    result = @inferred(diffusion_rate(g,
                                  1.0,
                                  4,
                                  watch=Set(1:5),
                                  initial_infections=Set(2)
                                  )
             )
    result
    @test result == [1, 5, 5, 5]

    # Watching unconnected vertices
    result = @inferred(diffusion_rate(g,
                                  1.0,
                                  4,
                                  watch=Set(6:10),
                                  initial_infections=Set(2)
                                  )
               )
    @test  result == [0, 0, 0, 0]

    # Watch subset
    result = @inferred(diffusion_rate(g,
                                  1.0,
                                  4,
                                  watch=Set(1:2),
                                  initial_infections=Set(2)
                                  )
             )
    result
    @test result == [1, 2, 2, 2]

    result = diffusion_rate(g,
                                  1.0,
                                  4,
                                  watch=Set(1:5),
                                  initial_infections=Set(10)
                                  )

    @test result == [0, 0, 0, 0]

    ######
    # Check along path graph
    ######

    g2 = PathGraph(5)
    result = @inferred(diffusion_rate(g2,
                                  1.0,
                                  4,
                                  watch=Set(1:5),
                                  initial_infections=Set(1)
                                  )
              )
    @test  result == [1, 2, 3, 4]

    result = @inferred(diffusion_rate(g2,
                                  1.0,
                                  4,
                                  watch=Set(1:5),
                                  initial_infections=Set(3)
                                  )
             )
    @test result == [1, 3, 5, 5]

    # Check normalize
    g3 = PathGraph(30)
    result = @inferred(diffusion_rate(g3,
                                  1.0,
                                  6,
                                  initial_infections=Set(15),
                                  normalize=false
                                  )
             )
    result
    @test result == [1, 3, 5, 7, 9, 11]


    result = @inferred(diffusion_rate(g3,
                                  2.0,
                                  6,
                                  initial_infections=Set(15),
                                  normalize=true
                                  )
             )
    @test result == [1, 3, 5, 7, 9, 11]

    # Test probability accurate
    means = Dict(0.2 => 0.8, 0.4 => 1.6)
    stds = Dict(0.2 => 0.8, 0.4 => 0.98)
    runs = 20
    for p in [0.2, 0.4]
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_rate(g2,
                                              p,
                                              5,
                                              initial_infections=Set(1))
                               )
            final_value += result[5]
        end

        # Pretty loose bounds so don't get lots of failed tests.
        # Just want some safeguard.
        # Note 5 steps = 4 Bernoullis + initial infection.
        # False rate less than 1 in 1000
        # Subtract 1 for initial infection
        avg = final_value / runs - 1
        @test avg < means[p] + stds[p] / sqrt(runs) * 3.5
        @test avg > means[p] - stds[p] / sqrt(runs) * 3.5
    end

    ######
    # Check on digraphs
    ######
    gx = PathDiGraph(10)

    result = @inferred(diffusion_rate(gx,
                                  1.0,
                                  9,
                                  initial_infections=Set(1)
                                  )
             )
    @test result == collect(1:9)

    result = @inferred(diffusion_rate(gx,
                                  1.0,
                                  9,
                                  initial_infections=Set(10)
                                  )
             )
    @test result == ones(Int64, 9)

    # Check probabilities
    runs = 20
    means = Dict(0.2 => 2, 0.4 => 4)
    stds = Dict(0.2 => 1.2649110640673518, 0.4 => 1.5491933384829668)

    for p in [0.2, 0.4]
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_rate(gx,
                                                    p,
                                                    11,
                                                    initial_infections=Set(1))
                               )
            final_value += result[11]

        end

        # Pretty loose bounds so don't get lots of failed tests.
        # Just want some safeguard.
        # False rate less than 1 in 1000
        # Subtract 1 for initial infection
        avg = final_value / runs - 1
        @test avg < means[p] + stds[p] / sqrt(runs) * 3.5
        @test avg > means[p] - stds[p] / sqrt(runs) * 3.5
    end


end
