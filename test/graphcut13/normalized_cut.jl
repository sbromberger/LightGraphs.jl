@testset "Normalized Cut" begin

    gx = SimpleGraph(6)
    add_edge!(gx, 1, 2)
    add_edge!(gx, 2, 3)
    add_edge!(gx, 1, 3)
    add_edge!(gx, 4, 5)
    add_edge!(gx, 4, 6)
    add_edge!(gx, 5, 6)
    add_edge!(gx, 1, 6)
    add_edge!(gx, 3, 4)

    w = zeros(6, 6)
    w[2, 1] = 1.0
    w[3, 1] = 1.0
    w[6, 1] = 0.1
    w[1, 2] = 1.0
    w[3, 2] = 1.0
    w[1, 3] = 1.0
    w[2, 3] = 1.0
    w[4, 3] = 0.2
    w[3, 4] = 0.2
    w[5, 4] = 1.0
    w[6, 4] = 1.0
    w[4, 5] = 1.0
    w[6, 5] = 1.0
    w[1, 6] = 0.1
    w[4, 6] = 1.0
    w[5, 6] = 1.0

    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 1, w))
        @test labels == [1, 1, 1, 2, 2, 2] || labels == [2, 2, 2, 1, 1, 1]
    end

    w = SparseMatrixCSC(w)
    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 1, w))
        @test labels == [1, 1, 1, 2, 2, 2] || labels == [2, 2, 2, 1, 1, 1]
    end

    gx = SimpleGraph(4)
    add_edge!(gx, 1, 2)
    add_edge!(gx, 3, 4)

    w = zeros(4, 4)
    w[2, 1] = 1.0
    w[1, 2] = 1.0
    w[4, 3] = 1.0
    w[3, 4] = 1.0
    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 0.1, w))
        @test labels == [1, 1, 2, 2] || labels == [2, 2, 1, 1]
    end

    w = SparseMatrixCSC(w)
    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 0.1, w))
        @test labels == [1, 1, 2, 2] || labels == [2, 2, 1, 1]
    end

    w = ones(12, 12)
    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 0.1, w))
        @test labels == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    end

    w = ones(12, 12)
    for g in testgraphs(gx)
        labels = @inferred(normalized_cut(g, 0.1, w))
        @test labels == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    end

    g = path_graph(50)

    function contiguous(labels::Vector{Int})::Bool
        changes = 0
        for i in 1:(length(labels)-1)
            if labels[i] != labels[i+1]
                changes += 1
            end
        end
        return changes == length(unique(labels)) - 1
    end

    num_subgraphs = Vector{Int}(undef, 9)

    for t in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
        labels = @inferred(normalized_cut(g, t))
        @test contiguous(labels) == true
        num_subgraphs[convert(Int, 10 * t)] = size(unique(labels), 1)
    end

    @test issorted(num_subgraphs) == true

    @test any(length(unique(normalized_cut(g, t))) == 4 for t in [0.125, 0.15, 0.16, 0.175, 0.20])

end
