
@testset "Diffusion Simulation" begin

gx = complete_graph(5)

for g in testgraphs(gx)  # this makes graphs of different eltypes
    # Most basic
    @test @inferred(diffusion_rate(g, 1.0, 4)) == [1, 5, 5, 5]
end

for i in 1:5
  add_vertex!(gx)
end

for g in testgraphs(gx)  # this makes graphs of different eltypes

    ######
    # Check on fully connected, prob = 1
    ######


    # Add disconnected for more dynamics

    # Basic test. Watch connected vertices
    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(1:5),
                                   initial_infections=[2]
                                   )) == [1, 5, 5, 5]

    # Watching unconnected vertices
    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(6:10),
                                   initial_infections=[2]
                                   )) == [0, 0, 0, 0]

    # Watch subset
    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(1:2),
                                   initial_infections=[2]
                                   )) == [1, 2, 2, 2]

    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(1:5),
                                   initial_infections=[10]
                                   )) == [0, 0, 0, 0]

end

######
# Check along path graph
######

gx = path_graph(5)

for g in testgraphs(gx)  # this makes graphs of different eltypes

    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(1:5),
                                   initial_infections=[1]
                                   )) == [1, 2, 3, 4]

    @test @inferred(diffusion_rate(g, 1.0, 4,
                                   watch=collect(1:5),
                                   initial_infections=[3]
                                   )) == [1, 3, 5, 5]
end

gx = path_graph(30)
for g in testgraphs(gx)
    # Check normalize
    @test @inferred(diffusion_rate(g,
                                  1.0,
                                  6,
                                  initial_infections=[15],
                                  normalize=false
                                  )) == [1, 3, 5, 7, 9, 11]


    @test @inferred(diffusion_rate(g, 2.0, 6,
                                   initial_infections=[15],
                                   normalize=true)
                                   ) == [1, 3, 5, 7, 9, 11]

    # Test probability accurate
    # In a Path network,
    # number of nodes infected (minus 1)
    # is equal to number of successes of a
    # Burnoulli process.
    # So if p = 0.2, in 5 steps (seed +
    # 4 trials) expected value is 0.8,
    # with standard deviation 0.8.

    means = Dict(0.2 => 0.8, 0.4 => 1.6)
    stds = Dict(0.2 => 0.8, 0.4 => 0.98)
    runs = 20
    for p in [0.2, 0.4]
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_rate(g, p, 5,
                                     initial_infections=[1]))
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
end


gx = path_digraph(10)

for g in testdigraphs(gx)

    ######
    # Check on digraphs
    ######

    @test @inferred(diffusion_rate(g, 1.0, 9,
                                  initial_infections=[1]
                                  )) == collect(1:9)

    @test @inferred(diffusion_rate(g, 1.0, 9,
                                  initial_infections=[10]
                                  )) == ones(Int, 9)

    # Check probabilities.
    # See note in analogous tests above for undirected tests.
    runs = 20
    means = Dict(0.2 => 2, 0.4 => 4)
    stds = Dict(0.2 => 1.2649110640673518,
                0.4 => 1.5491933384829668)

    for p in [0.2, 0.4]
        final_value = 0.0

        for i in 1:20
            result = @inferred(diffusion_rate(g, p, 11,
                                     initial_infections=[1]))
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
end
