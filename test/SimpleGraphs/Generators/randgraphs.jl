@testset "Randgraphs" begin
    rng1 = MersenneTwister(3)
    rng2 = MersenneTwister(3)
    @testset "(Int, Int)" begin
        r1 = @inferred(SG.SimpleGraph(10, 20))
        r2 = @inferred(SG.SimpleDiGraph(5, 10))
        @test nv(r1) == 10
        @test ne(r1) == 20
        @test nv(r2) == 5
        @test ne(r2) == 10
        @test eltype(r1) == Int
        @test eltype(r2) == Int

        @test SG.SimpleGraph(10, 20, rng=rng1) == SG.SimpleGraph(10, 20, rng=rng2)
        @test SG.SimpleGraph(10, 40, rng=rng1) == SG.SimpleGraph(10, 40, rng=rng2)
        @test SG.SimpleDiGraph(10, 20, rng=rng1) == SG.SimpleDiGraph(10, 20, rng=rng2)
        @test SG.SimpleDiGraph(10, 80, rng=rng1) == SG.SimpleDiGraph(10, 80, rng=rng2)
        @test SG.SimpleGraph(10, 20, rng=rng1) == SG.SimpleGraph(SGGEN.ErdosRenyi(10, 20, rng=rng2))
        @test ne(SG.SimpleGraph(10, 40, rng=rng1)) == 40
        @test ne(SG.SimpleDiGraph(10, 80, rng=rng1)) == 80
    end

    @testset "(UInt8, Mixed) eltype" begin
        @test eltype(SG.SimpleGraph(0x5, 0x2)) == eltype(SG.SimpleGraph(0x5, 2)) == UInt8
    end

    @testset "(SimpleGraph{$T}(Int, Int) eltype"for T in [UInt8, Int8, UInt16, Int16, UInt32, Int32, UInt, Int]
        @test eltype(SG.SimpleGraph{T}(5, 2)) == T
        @test eltype(SG.SimpleDiGraph{T}(5, 2)) == T
        @test eltype(SG.SimpleGraph{T}(5, 8)) == T
        @test eltype(SG.SimpleDiGraph{T}(5, 8)) == T
    end


    @testset "Erdös-Renyí" begin
        ergen = @inferred(SGGEN.Binomial(10, 0.5))
        er = @inferred(SG.SimpleGraph(ergen))
        @test nv(er) == 10
        @test is_directed(er) == false
        er = @inferred(SG.SimpleDiGraph(ergen))
        @test nv(er) == 10
        @test is_directed(er) == true

        ergen2 = @inferred(SGGEN.Binomial(10, 0.5, rng=rng1))
        er = @inferred(SG.SimpleGraph(ergen2))
        @test nv(er) == 10
        @test is_directed(er) == false

        ergen3 = @inferred(SGGEN.Binomial(5, 1.0))
        cpgen = @inferred(SGGEN.Complete(5))
        @test SG.SimpleGraph(ergen3) == SG.SimpleGraph(cpgen)
        @test SG.SimpleDiGraph(ergen3) == SG.SimpleDiGraph(cpgen)
        ergen4 = SGGEN.Binomial(5, 2.1)
        @test SG.SimpleGraph(ergen4) == SG.SimpleGraph(cpgen)
        @test SG.SimpleDiGraph(ergen4) == SG.SimpleDiGraph(cpgen)
    end

    @testset "expected degree" begin
        edgen = @inferred(SGGEN.ExpectedDegree(zeros(10), rng=rng1))
        cl = @inferred(SG.SimpleGraph(edgen))
        @test nv(cl) == 10
        @test ne(cl) == 0
        @test is_directed(cl) == false

        cl = @inferred(SG.SimpleGraph(SGGEN.ExpectedDegree([3, 2, 1, 2], rng=rng1)))
        @test nv(cl) == 4
        @test is_directed(cl) == false

        cl = @inferred(SG.SimpleGraph(SGGEN.ExpectedDegree(fill(99, 100), rng=rng1)))
        @test nv(cl) == 100
        @test all(degree(cl) .> 90)

    end

    @testset "Watts-Strogatz" begin
        wsgen1 = @inferred(SGGEN.WattsStrogatz(10, 4, 0.2))
        ws = @inferred(SG.SimpleGraph(wsgen1))
        @test nv(ws) == 10
        @test ne(ws) == 20
        @test is_directed(ws) == false

        ws = @inferred(SG.SimpleDiGraph(wsgen1))
        @test nv(ws) == 10
        @test ne(ws) == 20
        @test is_directed(ws) == true
    end

    @testset "Barabasi-Albert" begin
        bagen1 = @inferred(SGGEN.BarabasiAlbert(10, 2))
        ba = @inferred(SG.SimpleGraph(bagen1))
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == false
        ba = @inferred(SG.SimpleDiGraph(bagen1))
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == true

        bagen2 = @inferred(SGGEN.BarabasiAlbert(10, 2, SG.SimpleGraph(2)))
        ba = @inferred(SG.SimpleGraph(bagen2))
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == false
        ba = @inferred(SG.SimpleDiGraph(bagen2))
        @test nv(ba) == 10
        @test ne(ba) == 16
        @test is_directed(ba) == true

        bagen3 = @inferred(SGGEN.BarabasiAlbert(10, 2, SG.SimpleGraph(4)))
        ba = @inferred(SG.SimpleGraph(bagen3))
        @test nv(ba) == 10
        @test ne(ba) == 12
        @test is_directed(ba) == false
        ba = @inferred(SG.SimpleDiGraph(bagen3))
        @test nv(ba) == 10
        @test ne(ba) == 12
        @test is_directed(ba) == true

        bagen4 = @inferred(SGGEN.BarabasiAlbert(10, 2, SG.SimpleGraph(SGGEN.Complete(2))))
        ba = @inferred(SG.SimpleGraph(bagen4))
        @test nv(ba) == 10
        @test ne(ba) == 17
        @test is_directed(ba) == false
        ba = @inferred(SG.SimpleDiGraph(bagen4))
        @test nv(ba) == 10
        @test ne(ba) == 18
        @test is_directed(ba) == true

        bagen5 = @inferred(SGGEN.BarabasiAlbert(10, 2, SG.SimpleGraph(SGGEN.Complete(4))))
        ba = @inferred(SG.SimpleGraph(bagen5))
        @test nv(ba) == 10
        @test ne(ba) == 18
        @test is_directed(ba) == false
        ba = @inferred(SG.SimpleDiGraph(bagen5))
        @test nv(ba) == 10
        @test ne(ba) == 24
        @test is_directed(ba) == true
    end

    @testset "static fitness" begin
        fm1gen = @inferred(SGGEN.StaticFitnessModel(20, rand(10)))
        fm = @inferred(SG.SimpleGraph(fm1gen))
        @test nv(fm) == 10
        @test ne(fm) == 20
        @test is_directed(fm) == false

        fm1gen = @inferred(SGGEN.StaticFitnessModel(20, rand(10), rand(10)))
        fm = @inferred(SG.SimpleDiGraph(fm1gen))
        @test nv(fm) == 10
        @test ne(fm) == 20
        @test is_directed(fm) == true
    end

    @testset "static scale-free" begin
        sfgen1 = @inferred(SGGEN.StaticScaleFree(10, 20, 2.0, 2.0))
        sf = @inferred(SG.SimpleGraph(sfgen1))
        @test nv(sf) == 10
        @test ne(sf) == 20
        @test is_directed(sf) == false

        sf = @inferred(SG.SimpleDiGraph(sfgen1))
        @test nv(sf) == 10
        @test ne(sf) == 20
        @test is_directed(sf) == true
    end

    @testset "random regular" begin
        rrgen1 = @inferred(SGGEN.RandomRegular(5, 0))
        rr = @inferred(SG.SimpleGraph(rrgen1))
        @test nv(rr) == 5
        @test ne(rr) == 0
        @test is_directed(rr) == false

        rrgen2 = @inferred(SGGEN.RandomRegular(10, 0))
        rd = @inferred(SG.SimpleDiGraph(rrgen2))
        @test nv(rd) == 10
        @test ne(rd) == 0
        @test is_directed(rd)

        rrgen3 = @inferred(SGGEN.RandomRegular(10, 8, rng=rng1))
        rr = @inferred(SG.SimpleGraph(rrgen3))
        @test nv(rr) == 10
        @test ne(rr) == 40
        @test is_directed(rr) == false

        for v in vertices(rr)
            @test degree(rr, v) == 8
        end

        rrgen4 = @inferred(SGGEN.RandomRegular(1000, 50))
        rr = @inferred(SG.SimpleGraph(rrgen4))
        @test nv(rr) == 1000
        @test ne(rr) == 25000
        @test is_directed(rr) == false
        for v in vertices(rr)
            @test degree(rr, v) == 50
        end
        rrgen5 = @inferred(SGGEN.RandomRegular(1000, 4))
        rd = @inferred(SG.SimpleDiGraph(rrgen5))
        @test nv(rd) == 1000
        @test ne(rd) == 4000
        @test is_directed(rd)
        outdegree_rd = @inferred(outdegree(rd))
        @test all(outdegree_rd .== outdegree_rd[1])

        rrgen6 = @inferred(SGGEN.RandomRegular(1000, 4, outbound=false))
        rd = @inferred(SG.SimpleDiGraph(rrgen6))
        @test nv(rd) == 1000
        @test ne(rd) == 4000
        @test is_directed(rd)
        indegree_rd = @inferred(indegree(rd))
        @test all(indegree_rd .== indegree_rd[1])

        rrgen7 = @inferred(SGGEN.RandomRegular(10, 8, rng=rng2))
        rd = @inferred(SG.SimpleDiGraph(rrgen7))
        @test nv(rd) == 10
        @test ne(rd) == 80
        @test is_directed(rd)
    end

    @testset "random configuration model" begin
        rcgen1 = @inferred(SGGEN.RandomConfigurationModel(10, repeat([2, 4], 5), rng=rng1))
        rr = @inferred(SG.SimpleGraph(rcgen1))
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

        rcgen2 = @inferred(SGGEN.RandomConfigurationModel(1000, zeros(Int, 1000)))
        rr = @inferred(SG.SimpleGraph(rcgen2))
        @test nv(rr) == 1000
        @test ne(rr) == 0
        @test is_directed(rr) == false

        rcgen3 = @inferred(SGGEN.RandomConfigurationModel(3, [2,2,2], check_graphical=true))
        rr = @inferred(SG.SimpleGraph(rcgen3))
        @test nv(rr) == 3
        @test ne(rr) == 3
        @test is_directed(rr) == false
    end

    @testset "random tournament" begin
        rtgen = @inferred(SGGEN.Tournament(10))
        rt = @inferred(SG.SimpleDiGraph(rtgen))
        @test nv(rt) == 10
        @test ne(rt) == 45
        @test is_directed(rt)
        @test all(degree(rt) .== 9)
        Edges = edges(rt)
        for i = 1:10, j = 1:10
            if i != j
                edge = @inferred(SG.SimpleEdge(i, j))
                @test xor(edge ∈ Edges, reverse(edge) ∈ Edges)
            end
        end
    end

    @testset "Kronecker" begin
        kggen = @inferred(SGGEN.Kronecker(5, 5))
        kg = SimpleDiGraph(kggen)
        @test nv(kg) == 32
        @test is_directed(kg)
    end

    @testset "Dorogovtsev-Mendes" begin
        dmgen1 = @inferred(SGGEN.DorogovtsevMendes(10))
        g = @inferred(SG.SimpleGraph(dmgen1))
        @test nv(g) == 10 && ne(g) == 17

        dmgen2 = @inferred(SGGEN.DorogovtsevMendes(11))
        g = @inferred(SG.SimpleGraph(dmgen2))
        @test nv(g) == 11 && ne(g) == 19
        @test δ(g) == 2

        dmgen3 = @inferred(SGGEN.DorogovtsevMendes(3))
        g = @inferred(SG.SimpleGraph(dmgen3))
        @test nv(g) == 3 && ne(g) == 3
        # testing domain errors
        @test_throws DomainError @inferred(SGGEN.DorogovtsevMendes(2))
        @test_throws DomainError @inferred(SGGEN.DorogovtsevMendes(-1))
    end

    @testset "random orientation DAG" begin
    # testing if returned graph is acyclic and valid @inferred(SG.SimpleGraph)
        roggen1 = @inferred(SGGEN.RandomOrientationDAG(SG.SimpleGraph(5, 10)))
        rog = @inferred(SG.SimpleDiGraph(roggen1))
        @test isvalid_simplegraph(rog)
        @test !is_cyclic(rog)

        # testing if returned graph is acyclic and valid ComplexGraph
        roggen2 = @inferred(SGGEN.RandomOrientationDAG(SG.SimpleGraph(SGGEN.Complete(5))))
        rog2 = @inferred(SG.SimpleDiGraph(roggen2))
        @test isvalid_simplegraph(rog2)
        @test !is_cyclic(rog2)

        # testing with abstract RNG
        roggen3 = @inferred(SGGEN.RandomOrientationDAG(SG.SimpleGraph(10, 15), rng=rng1))
        rog3 = @inferred(SG.SimpleDiGraph(roggen3))
        @test isvalid_simplegraph(rog3)
        @test !is_cyclic(rog3)
    end
end
