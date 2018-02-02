@testset "Randgraphs" begin
    r1 = SimpleGraph(10,20)
    r2 = SimpleDiGraph(5,10)

    @test nv(r1) == 10
    @test ne(r1) == 20
    @test nv(r2) == 5
    @test ne(r2) == 10
    @test eltype(r1) == Int
    @test eltype(r2) == Int

    @test eltype(Graph(0x5, 0x2)) == eltype(Graph(0x5, 2)) == UInt8
    for T in [UInt8, Int8, UInt16, Int16, UInt32, Int32, UInt, Int]
        @test eltype(Graph{T}(5,2)) == T
        @test eltype(DiGraph{T}(5,2)) == T
    end

    @test SimpleGraph(10,20,seed=3) == SimpleGraph(10,20,seed=3)
    @test SimpleDiGraph(10,20,seed=3) == SimpleDiGraph(10,20,seed=3)
    @test SimpleGraph(10,20,seed=3) == erdos_renyi(10,20,seed=3)
    @test ne(Graph(10,40,seed=3)) == 40
    @test ne(DiGraph(10,80,seed=3)) == 80

    er = erdos_renyi(10, 0.5)
    @test nv(er) == 10
    @test is_directed(er) == false
    er = erdos_renyi(10, 0.5, is_directed=true)
    @test nv(er) == 10
    @test is_directed(er) == true

    er = erdos_renyi(10, 0.5, seed=17)
    @test nv(er) == 10
    @test is_directed(er) == false

    cl = expected_degree(zeros(10), seed = 17)
    @test nv(cl) == 10
    @test ne(cl) == 0
    @test is_directed(cl) == false

    cl = expected_degree([3, 2, 1, 2], seed = 17)
    @test nv(cl) == 4
    @test is_directed(cl) == false

    cl = expected_degree(fill(99, 100), seed = 17)
    @test nv(cl) == 100
    @test all(degree(cl) .> 95)

    ws = watts_strogatz(10,4,0.2)
    @test nv(ws) == 10
    @test ne(ws) == 20
    @test is_directed(ws) == false

    ws = watts_strogatz(10, 4, 0.2, is_directed=true)
    @test nv(ws) == 10
    @test ne(ws) == 20
    @test is_directed(ws) == true

    ba = barabasi_albert(10, 2)
    @test nv(ba) == 10
    @test ne(ba) == 16
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 2, 2)
    @test nv(ba) == 10
    @test ne(ba) == 16
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 4, 2)
    @test nv(ba) == 10
    @test ne(ba) == 12
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 2, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 17
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 2, 2, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 17
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 4, 2, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 18
    @test is_directed(ba) == false

    ba = barabasi_albert(10, 2, is_directed=true)
    @test nv(ba) == 10
    @test ne(ba) == 16
    @test is_directed(ba) == true

    ba = barabasi_albert(10, 2, 2, is_directed=true)
    @test nv(ba) == 10
    @test ne(ba) == 16
    @test is_directed(ba) == true

    ba = barabasi_albert(10, 4, 2, is_directed=true)
    @test nv(ba) == 10
    @test ne(ba) == 12
    @test is_directed(ba) == true

    ba = barabasi_albert(10, 2, is_directed=true, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 18
    @test is_directed(ba) == true

    ba = barabasi_albert(10, 2, 2, is_directed=true, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 18
    @test is_directed(ba) == true

    ba = barabasi_albert(10, 4, 2, is_directed=true, complete=true)
    @test nv(ba) == 10
    @test ne(ba) == 24
    @test is_directed(ba) == true

    fm = static_fitness_model(20, rand(10))
    @test nv(fm) == 10
    @test ne(fm) == 20
    @test is_directed(fm) == false

    fm = static_fitness_model(20, rand(10), rand(10))
    @test nv(fm) == 10
    @test ne(fm) == 20
    @test is_directed(fm) == true

    sf = static_scale_free(10, 20, 2.0)
    @test nv(sf) == 10
    @test ne(sf) == 20
    @test is_directed(sf) == false

    sf = static_scale_free(10, 20, 2.0, 2.0)
    @test nv(sf) == 10
    @test ne(sf) == 20
    @test is_directed(sf) == true

    rr = random_regular_graph(5, 0)
    @test nv(rr) == 5
    @test ne(rr) == 0
    @test is_directed(rr) == false

    rd = random_regular_digraph(10,0)
    @test nv(rd) == 10
    @test ne(rd) == 0
    @test is_directed(rd)

    rr = random_regular_graph(6, 3, seed=1)
    @test nv(rr) == 6
    @test ne(rr) == 9
    @test is_directed(rr) == false

    rr = random_regular_graph(1000, 50)
    @test nv(rr) == 1000
    @test ne(rr) == 25000
    @test is_directed(rr) == false
    for v in vertices(rr)
        @test degree(rr, v) == 50
    end

    rr = random_configuration_model(10, repmat([2,4] ,5), seed=3)
    @test nv(rr) == 10
    @test ne(rr) == 15
    @test is_directed(rr) == false
    num2 = 0; num4 = 0
    for v in vertices(rr)
        d = degree(rr, v)
        @test  d == 2 || d == 4
        d == 2 ? num2 += 1 : num4 += 1
    end
    @test num4 == 5
    @test num2 == 5

    rr = random_configuration_model(1000, zeros(Int,1000))
    @test nv(rr) == 1000
    @test ne(rr) == 0
    @test is_directed(rr) == false

    rr = random_configuration_model(3, [2,2,2], check_graphical=true)
    @test nv(rr) == 3
    @test ne(rr) == 3
    @test is_directed(rr) == false

    rd = random_regular_digraph(1000, 4)
    @test nv(rd) == 1000
    @test ne(rd) == 4000
    @test is_directed(rd)
    @test std(outdegree(rd)) == 0

    rd = random_regular_digraph(1000, 4, dir=:in)
    @test nv(rd) == 1000
    @test ne(rd) == 4000
    @test is_directed(rd)
    @test std(indegree(rd)) == 0

    rr = random_regular_graph(10, 8, seed=4)
    @test nv(rr) == 10
    @test ne(rr) == 40
    @test is_directed(rr) == false
    for v in vertices(rr)
        @test degree(rr, v) == 8
    end

    rd = random_regular_digraph(10, 8, dir=:out, seed=4)
    @test nv(rd) == 10
    @test ne(rd) == 80
    @test is_directed(rd)

    rt = random_tournament_digraph(10)
    @test nv(rt) == 10
    @test ne(rt) == 45
    @test is_directed(rt)
    @test all(degree(rt) .== 9)
    Edges = edges(rt)
    for i = 1:10, j = 1:10
        if i != j
            edge = Edge(i, j)
            @test xor(edge ∈ Edges, reverse(edge) ∈ Edges)
        end
    end

    g = stochastic_block_model(2., 3., [100,100])
    @test  4.0 < mean(degree(g)) < 6.0
    g = stochastic_block_model(3., 4., [100,100,100])
    @test  10.0 < mean(degree(g)) < 12.0

    function generate_nbp_sbm(numedges, sizes)
        density = 1
        between = density * 0.90
        intra = density * -0.005
        noise = density * 0.00501
        sbm = nearbipartiteSBM(sizes, between, intra, noise)
        edgestream = make_edgestream(sbm)
        g = SimpleGraph(sum(sizes), numedges, edgestream)
        return sbm, g
    end


    function test_sbm(sbm, bp)
        @test sum(sbm.affinities) != NaN
        @test all(sbm.affinities .> 0)
        @test sum(sbm.affinities) != 0
        @test all(bp .>= 0)
        @test all(bp .!= NaN)
    end

    numedges = 100
    sizes = [10, 10, 10, 10]

    n = sum(sizes)
    sbm, g = generate_nbp_sbm(numedges, sizes)
    @test ne(g) >= 0.9numedges
    bc = blockcounts(sbm, g)
    bp = blockfractions(sbm, g) ./ (sizes * sizes')
    ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
    test_sbm(sbm, bp)
    @test norm(collect(ratios)) < 0.25

    sizes = [200, 200, 100]
    internaldeg = 15
    externaldeg = 6
    internalp = Float64[internaldeg/i for i in sizes]
    externalp = externaldeg/sum(sizes)
    numedges = internaldeg + externaldeg #+ sum(externaldeg.*sizes[2:end])
    numedges *= div(sum(sizes), 2)
    sbm = StochasticBlockModel(internalp, externalp, sizes)
    g = SimpleGraph(sum(sizes), numedges, sbm)
    @test ne(g) >= 0.9numedges
    @test ne(g) <= numedges
    @test nv(g) == sum(sizes)
    bc = blockcounts(sbm, g)
    bp = blockfractions(sbm, g) ./ (sizes * sizes')
    test_sbm(sbm, bp)
    ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
    @test norm(collect(ratios)) < 0.25

    # check that average degree is not too high
    # factor of two is cushion for random process
    @test mean(degree(g)) <= 4//2*numedges/sum(sizes)
    # check that the internal degrees are higher than the external degrees
    # 5//4 is cushion for random process.
    @test all(sum(bc-diagm(diag(bc)), 1) .<= 5//4 .* diag(bc))


    sbm2 = StochasticBlockModel(0.5*ones(4), 0.3, 10*ones(Int,4))
    sbm  = StochasticBlockModel(0.5, 0.3, 10, 4)
    @test sbm == sbm2
    sbm.affinities[1,1] = 0
    @test sbm != sbm2

    kg = @inferred kronecker(5,5)
    @test nv(kg) == 32
    @test is_directed(kg)
end
