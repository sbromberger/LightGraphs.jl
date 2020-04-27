import Random

@testset "SG.SimpleGraphs" begin
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    # specific concrete generators - no need for loop
    @test @inferred(eltype(SG.SimpleGraph())) == Int
    @test @inferred(eltype(SG.SimpleGraph(adjmx1))) == Int
    @test_throws ArgumentError SG.SimpleGraph(adjmx2)

    @test_throws LightGraphs.NotImplementedError badj(DummySimpleGraph())

    @test @inferred(ne(SG.SimpleGraph(SG.SimpleDiGraph(SGGEN.Path(5))))) == 4
    @test @inferred(!is_directed(SG.SimpleGraph))
    @test @inferred(!is_directed(SG.SimpleGraph{Int}))

    @test @inferred(eltype(SG.SimpleDiGraph())) == Int
    @test @inferred(eltype(SG.SimpleDiGraph(adjmx2))) == Int
    @test @inferred(ne(SG.SimpleDiGraph(SG.SimpleGraph(SGGEN.Path(5))))) == 8
    @test @inferred(is_directed(SG.SimpleDiGraph))
    @test @inferred(is_directed(SG.SimpleDiGraph{Int}))


    for gbig in [SG.SimpleGraph(0xff), SG.SimpleDiGraph(0xff)]
        @test @inferred(!SG.add_vertex!(gbig))    # overflow
        @test @inferred(SG.add_vertices!(gbig, 10) == 0)
    end

    gdx = SG.SimpleDiGraph(SGGEN.Path(4))
    gx = SG.SimpleGraph()
    @testset "$g" for g in testgraphs(gx)
        T = eltype(g)
        @test sprint(show, g) == "{0, 0} undirected simple $T graph"
        @test @inferred(SG.add_vertices!(g, 5) == 5)
        @test sprint(show, g) == "{5, 0} undirected simple $T graph"
    end
    gx = SG.SimpleDiGraph()
    @testset "$g" for g in testdigraphs(gx)
        T = eltype(g)
        @test sprint(show, g) == "{0, 0} directed simple $T graph"
        @test @inferred(SG.add_vertices!(g, 5) == 5)
        @test sprint(show, g) == "{5, 0} directed simple $T graph"
    end

    gx = SG.SimpleGraph(SGGEN.Path(4))
    @testset "$g" for g in testgraphs(gx)
        @test @inferred(vertices(g)) == 1:4
        @test SG.SimpleEdge(2, 3) in edges(g)
        @test @inferred(nv(g)) == 4
        @test @inferred(SG.fadj(g)) == SG.badj(g) == SG.adj(g) == g.fadjlist
        @test @inferred(SG.fadj(g, 2)) == SG.badj(g, 2) == SG.adj(g, 2) == g.fadjlist[2]

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(!has_edge(g, 20, 3))
        @test @inferred(!has_edge(g, 2, 30))
        @test @inferred(has_edge(g, 3, 2))

        gc = copy(g)
        @test @inferred(SG.add_edge!(gc, 4 => 1)) && gc == SG.SimpleGraph(SGGEN.Cycle(4))
        @test @inferred(has_edge(gc, 4 => 1)) && has_edge(gc, 0x04 => 0x01)
        gc = copy(g)
        @test @inferred(SG.add_edge!(gc, (4, 1))) && gc == SG.SimpleGraph(SGGEN.Cycle(4))
        @test @inferred(has_edge(gc, (4, 1))) && has_edge(gc, (0x04, 0x01))
        gc = copy(g)
        @test SG.add_edge!(gc, 4, 1) && gc == SG.SimpleGraph(SGGEN.Cycle(4))

        @test @inferred(inneighbors(g, 2)) == @inferred(outneighbors(g, 2)) == @inferred(neighbors(g, 2)) == [1, 3]
        @test @inferred(SG.add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(SG.rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(SG.rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!SG.rem_vertex!(ga, 10))

        @test @inferred(zero(g)) == SG.SimpleGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(fadj(g, 1)) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SG.SimpleGraph{T}(6))) == 6

        @test @inferred(eltype(SG.SimpleGraph(T))) == T
        @test @inferred(eltype(SG.SimpleGraph{T}(adjmx1))) == T

        ga = SG.SimpleGraph(10)
        @test @inferred(eltype(SG.SimpleGraph{T}(ga))) == T

        for gd in testdigraphs(gdx)
            U = eltype(gd)
            @test @inferred(eltype(SG.SimpleGraph(gd))) == U
        end

        @test @inferred(edgetype(g)) == SG.SimpleGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(!is_directed(g))

        e = first(edges(g))
        @test @inferred(has_edge(g, e))
    end

    gdx = SG.SimpleDiGraph(SGGEN.Path(4))
    @testset "$g" for g in testdigraphs(gdx)
        @test @inferred(vertices(g)) == 1:4
        @test SG.SimpleEdge(2, 3) in edges(g)
        @test !(SG.SimpleEdge(3, 2) in edges(g))
        @test @inferred(nv(g)) == 4
        @test @inferred(SG.fadj(g)[2]) == SG.fadj(g, 2) == [3]
        @test @inferred(SG.badj(g)[2]) == SG.badj(g, 2) == [1]
        @test_throws MethodError SG.adj(g)

        @test @inferred(has_edge(g, 2, 3))
        @test @inferred(!has_edge(g, 3, 2))
        @test @inferred(!has_edge(g, 20, 3))
        @test @inferred(!has_edge(g, 2, 30))

        gc = copy(g)
        @test @inferred(SG.add_edge!(gc, 4 => 1)) && gc == SG.SimpleDiGraph(SGGEN.Cycle(4))
        @test @inferred(has_edge(gc, 4 => 1)) && has_edge(gc, 0x04 => 0x01)
        gc = copy(g)
        @test @inferred(SG.add_edge!(gc, (4, 1))) && gc == SG.SimpleDiGraph(SGGEN.Cycle(4))
        @test @inferred(has_edge(gc, (4, 1))) && has_edge(gc, (0x04, 0x01))
        gc = @inferred(copy(g))
        @test @inferred(SG.add_edge!(gc, 4, 1)) && gc == SG.SimpleDiGraph(SGGEN.Cycle(4))

        @test @inferred(inneighbors(g, 2)) == [1]
        @test @inferred(outneighbors(g, 2)) == @inferred(neighbors(g, 2)) == [3]
        @test @inferred Set(all_neighbors(g, 2)) == Set(union(outneighbors(g, 2), inneighbors(g, 2)))
        @test @inferred(SG.add_vertex!(gc))   # out of order, but we want it for issubset
        @test @inferred(g ⊆ gc)
        @test @inferred(has_vertex(gc, 5))

        @test @inferred(ne(g)) == 3

        @test @inferred(!SG.rem_edge!(gc, 2, 1))
        @test @inferred(SG.rem_edge!(gc, 1, 2)) && @inferred(!has_edge(gc, 1, 2))
        ga = @inferred(copy(g))
        @test @inferred(SG.rem_vertex!(ga, 2)) && ne(ga) == 1
        @test @inferred(!SG.rem_vertex!(ga, 10))

        @test @inferred(zero(g)) == SG.SimpleDiGraph{eltype(g)}()

        # concrete tests below

        @test @inferred(eltype(g)) == eltype(@inferred(SG.fadj(g, 1))) == eltype(nv(g))
        T = @inferred(eltype(g))
        @test @inferred(nv(SG.SimpleDiGraph{T}(6))) == 6

        @test @inferred(eltype(SG.SimpleDiGraph(T))) == T
        @test @inferred(eltype(SG.SimpleDiGraph{T}(adjmx2))) == T

        ga = SG.SimpleDiGraph(10)
        @test @inferred(eltype(SG.SimpleDiGraph{T}(ga))) == T

        @testset "$g" for gu in testgraphs(gx)
            U = @inferred(eltype(gu))
            @test @inferred(eltype(SG.SimpleDiGraph(gu))) == U
        end

        @test @inferred(edgetype(g)) == SG.SimpleDiGraphEdge{T}
        @test @inferred(copy(g)) == g
        @test @inferred(is_directed(g))

        e = first(@inferred(edges(g)))
        @test @inferred(has_edge(g, e))
    end

    gx = SG.SimpleGraph(SGGEN.Complete(4))
    @testset "$g" for g in testgraphs(gx)
        h = SG.SimpleGraph(g)
        @test g == h
        @test SG.rem_vertex!(g, 2)
        @test nv(g) == 3 && ne(g) == 3
        @test g != h
    end


    gdx = SG.SimpleDiGraph(SGGEN.Complete(4))
    @testset "$g" for g in testdigraphs(gdx)
        h = SG.SimpleDiGraph(g)
        @test g == h
        @test SG.rem_vertex!(g, 2)
        @test nv(g) == 3 && ne(g) == 6
        @test g != h
    end
    # tests for #820
    g = SG.SimpleGraph(SGGEN.Complete(3))
    SG.add_edge!(g, 3, 3)
    SG.rem_vertex!(g, 1)
    @test nv(g) == 2 && ne(g) == 2 && has_edge(g, 1, 1)

    g = SG.SimpleDiGraph(SGGEN.Path(3))
    SG.add_edge!(g, 3, 3)
    SG.rem_vertex!(g, 1)
    @test nv(g) == 2 && ne(g) == 2 && has_edge(g, 1, 1)

    @testset "Cannot create graphs for non-concrete integer type $T" for T in [Signed, Integer]

        @test_throws DomainError SG.SimpleGraph{T}()
        @test_throws DomainError SG.SimpleGraph{T}(one(T))

        @test_throws DomainError SG.SimpleDiGraph{T}()
        @test_throws DomainError SG.SimpleDiGraph{T}(one(T))
    end

     # Tests for constructors from iterators of edges
    @testset "Constructors from edge lists" begin
        rng = MersenneTwister(0)
        g_undir = SG.SimpleGraph(SGGEN.Binomial(200, 100, rng=rng))
        SG.add_edge!(g_undir, 200, 1) # ensure that the result uses all vertices
        SG.add_edge!(g_undir, 2, 2) # add a self-loop

        @testset "SimpleGraphFromIterator for edgetype $(edgetype(g))" for g in testgraphs(g_undir)

            # We create an edge list, shuffle it and reverse half of its edges
            # using this edge list should result in the same graph
            edge_list = [e for e in edges(g)]
            shuffle!(MersenneTwister(0), edge_list)
            for i in rand(MersenneTwister(0), 1:length(edge_list), length(edge_list) ÷ 2)
                e = edge_list[i]
                Te = typeof(e)
                edge_list[i] = Te(dst(e), src(e))
            end

            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SG.SimpleGraph(edge_list)
            # we can't infer the return type of SG.SimpleGraphFromIterator at the moment
            g2 = SG.SimpleGraphFromIterator(edge_list)
            g3 = SG.SimpleGraphFromIterator(edge_iter)
            g4 = SG.SimpleGraphFromIterator(edge_set)
            g5 = SG.SimpleGraphFromIterator(edge_set_any)

            @test g == g1
            @test g == g2
            @test g == g3
            @test g == g4
            @test g == g5
            @test edgetype(g) == edgetype(g1)
            @test edgetype(g) == edgetype(g2)
            @test edgetype(g) == edgetype(g3)
            @test edgetype(g) == edgetype(g4)
            @test edgetype(g) == edgetype(g5)
        end

        g_dir = SG.SimpleDiGraph(SGGEN.Binomial(200, 100, rng))
        SG.add_edge!(g_dir, 200, 1)
        SG.add_edge!(g_dir, 2, 2)

        @testset "SimpleGraphFromIterator for edgetype $(edgetype(g))" for g in testdigraphs(g_dir)
            # We create an edge list and shuffle it
            edge_list = [e for e in edges(g)]
            shuffle!(MersenneTwister(0), edge_list)

            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SG.SimpleDiGraph(edge_list)
            # we can't infer the return type of SG.SimpleDiGraphFromIterator at the moment
            g2 = SG.SimpleDiGraphFromIterator(edge_list)
            g3 = SG.SimpleDiGraphFromIterator(edge_iter)
            g4 = SG.SimpleDiGraphFromIterator(edge_set)
            g5 = SG.SimpleDiGraphFromIterator(edge_set_any)

            @test g == g1
            @test g == g2
            @test g == g3
            @test g == g4
            @test g == g5
            @test edgetype(g) == edgetype(g1)
            @test edgetype(g) == edgetype(g2)
            @test edgetype(g) == edgetype(g3)
            @test edgetype(g) == edgetype(g4)
            @test edgetype(g) == edgetype(g5)
        end

        # SG.SimpleGraphFromIterator of an empty iterator should result
        # in an empty graph of default edgetype
        empty_iter = (x for x in [])
        @testset "SimpleGraphFromIterator for empty iterator" begin
            @test SG.SimpleGraphFromIterator(empty_iter) == SG.SimpleGraph(0)
            @test edgetype(SG.SimpleGraphFromIterator(empty_iter)) == edgetype(SG.SimpleGraph(0))
        end
        @testset "SG.SimpleGraphDiFromIterator for empty iterator" begin
            @test SG.SimpleDiGraphFromIterator(empty_iter) == SG.SimpleDiGraph(0)
            @test edgetype(SG.SimpleDiGraphFromIterator(empty_iter)) == edgetype(SG.SimpleDiGraph(0))
        end

        @testset "SG.SimpleGraphFromIterator for wrong edge types" begin
            @test_throws DomainError SG.SimpleGraphFromIterator( (i for i in 1:2) )
        end

        @testset "SG.SimpleDiGraphFromIterator for wrong edge types" begin
            @test_throws DomainError SG.SimpleDiGraphFromIterator( (SG.SimpleDiGraphEdge(1,2), "a string") )
        end

        # check if multiple edges && multiple self-loops result in the
        # correct number of edges & vertices
        # edges using integers < 1 should be ignored
        g_undir = SG.SimpleGraph(0)
        @testset "SG.SimpleGraphFromIterator with self-loops and multiple edges, edgetype $(edgetype(g))" for g in testgraphs(SG.SimpleGraph(0))

            E = edgetype(g)
            edge_list = E.([(4, 4),(1, 2),(4, 4),(1, 2),(4, 4),(2, 1),(0, 1),(1, 0),(0, 0)])
            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SG.SimpleGraph(edge_list)
            g2 = SG.SimpleGraphFromIterator(edge_list)
            g3 = SG.SimpleGraphFromIterator(edge_iter)
            g4 = SG.SimpleGraphFromIterator(edge_set)
            g5 = SG.SimpleGraphFromIterator(edge_set_any)

            @test nv(g1) == 4
            @test nv(g2) == 4
            @test nv(g3) == 4
            @test nv(g4) == 4
            @test nv(g5) == 4

            @test ne(g1) == 2
            @test ne(g2) == 2
            @test ne(g3) == 2
            @test ne(g4) == 2
            @test ne(g5) == 2
        end

        @testset "SimpleDiGraphFromIterator with self-loops and multiple edges, edgetype $(edgetype(g))" for g in testdigraphs(SG.SimpleDiGraph(0))

            E = edgetype(g)
            edge_list = E.([(4, 4),(1, 2),(4, 4),(1, 2),(4, 4),(2, 1),(0, 1),(1, 0),(0, 0)])
            edge_iter = (e for e in edge_list)
            edge_set = Set(edge_list)
            edge_set_any = Set{Any}(edge_list)

            g1 = @inferred SG.SimpleDiGraph(edge_list)
            g2 = SG.SimpleDiGraphFromIterator(edge_list)
            g3 = SG.SimpleDiGraphFromIterator(edge_iter)
            g4 = SG.SimpleDiGraphFromIterator(edge_set)
            g5 = SG.SimpleDiGraphFromIterator(edge_set_any)

            @test nv(g1) == 4
            @test nv(g2) == 4
            @test nv(g3) == 4
            @test nv(g4) == 4
            @test nv(g5) == 4

            @test ne(g1) == 3
            @test ne(g2) == 3
            @test ne(g3) == 3
            @test ne(g4) == 3
            @test ne(g5) == 3
        end

        # test for iterators where the type of the elements can only be determined at runtime
        g_undir = SG.SimpleGraph(0)
        @testset "SG.SimpleGraphFromIterator with edgelist of eltype Any" for g in testgraphs(g_undir)
            T = edgetype(g)
            edge_list_good = Any[ T.(1, 2), T.(3, 4) ]
            edge_list_bad =  Any[ T.(1, 2), Int64(1) ]

            g1 = SG.SimpleGraphFromIterator(edge_list_good)
            @test edgetype(g1) == T
            @test_throws DomainError SG.SimpleGraphFromIterator(edge_list_bad)
        end

        g_dir = SG.SimpleDiGraph(0)
        @testset "SimpleGraphDiFromIterator with edgelist of eltype Any" for g in testdigraphs(g_dir)
            T = edgetype(g)
            edge_list_good = Any[ T.(1, 2), T.(3, 4) ]
            edge_list_bad =  Any[ T.(1, 2), Int64(1) ]

            g1 = SG.SimpleDiGraphFromIterator(edge_list_good)
            @test edgetype(g1) == T
            @test_throws DomainError SG.SimpleDiGraphFromIterator(edge_list_bad)
        end


        @testset "SimpleGraphFromIterator with edgelist of eltype Any" begin
            # If there are edges of multiple types, the construction should fail
            edge_list_1 = Any[SG.SimpleEdge{Int8}(1, 2), SG.SimpleEdge{Int16}(3, 4)]
            edge_list_2 = Any[SG.SimpleEdge{Int16}(1, 2), SG.SimpleEdge{Int8}(3, 4)]
            @test_throws DomainError SG.SimpleGraphFromIterator(edge_list_1)
            @test_throws DomainError SG.SimpleGraphFromIterator(edge_list_2)
        end


        @testset "SimpleDiGraphFromIterator with edgelist of eltype Any" begin
            edge_list_1 = Any[SG.SimpleEdge{Int8}(1, 2), SG.SimpleEdge{Int16}(3, 4)]
            edge_list_2 = Any[SG.SimpleEdge{Int16}(1, 2), SG.SimpleEdge{Int8}(3, 4)]
            @test_throws DomainError SG.SimpleDiGraphFromIterator(edge_list_1)
            @test_throws DomainError SG.SimpleDiGraphFromIterator(edge_list_2)
        end
    end

    # test for rem_vertices!
    let
        comp5 = SGGEN.Complete(5)
        g_undir = SG.SimpleGraph(comp5)
        g_dir = SG.SimpleDiGraph(comp5)
        @testset "$g" for g in (testgraphs(g_undir) ∪ testdigraphs(g_dir))
            T = eltype(g)

            g5 = copy(g)
            vmap = @inferred SG.rem_vertices!(g5, T[], keep_order=true)
            @test g5 == g
            @test vmap == 1:5
            @test isvalid_simplegraph(g5)

            g4 = copy(g)
            vmap = SG.rem_vertices!(g4, T[3], keep_order=true)
            comp4 = SGGEN.Complete(T(4))
            @test g4 == (is_directed(g) ? SG.SimpleDiGraph(comp4) : SG.SimpleGraph(comp4))
            @test vmap == [1, 2, 4, 5]
            @test isvalid_simplegraph(g4)

            g4 = copy(g)
            SG.add_edge!(g4, 1, 1) # some self_loops
            SG.add_edge!(g4, 2, 2)
            vmap = SG.rem_vertices!(g4, T[1, 1, 1], keep_order=false)
            @test ne(g4) == (is_directed(g) ? 13 : 7)
            @test sort(vmap) == [2, 3, 4, 5]
            @test isvalid_simplegraph(g4)

            g2 = copy(g)
            vmap = SG.rem_vertices!(g2, T[2, 1, 4], keep_order=false)
            comp2 = SGGEN.Complete(T(2))
            @test g2 == (is_directed(g) ? SG.SimpleDiGraph(comp2) : SG.SimpleGraph(comp2))
            @test sort(vmap) == [3, 5]
            @test isvalid_simplegraph(g2)

            g0 = copy(g)
            vmap = SG.rem_vertices!(g0, T[1, 3, 2, 3, 5, 4], keep_order=false)
            @test g0 == (is_directed(g) ? SG.SimpleDiGraph(T(0)) : SG.SimpleGraph(T(0)))
            @test isempty(vmap)
            @test isvalid_simplegraph(g0)
            vmap = SG.rem_vertices!(g0, T[], keep_order=false)
            @test g0 == (is_directed(g) ? SG.SimpleDiGraph(T(0)) : SG.SimpleGraph(T(0)))
            @test isempty(vmap)
            @test isvalid_simplegraph(g0)

            g5 = copy(g)
            @test_throws ArgumentError SG.rem_vertices!(g5, T[2, 6], keep_order=true)
            g5 = copy(g)
            @test_throws ArgumentError SG.rem_vertices!(g5, T[3, 0], keep_order=false)
        end

        er10 = SGGEN.Binomial(10, 0.5)
        g_undir = SG.SimpleGraph(er10)
        g_dir = SG.SimpleDiGraph(er10)
        for u = 1:2:10
            SG.add_edge!(g_undir, u, u)
            SG.add_edge!(g_dir, u, u)
        end
        a = Random.randsubseq(1:10, 0.5)
        @testset "$g" for g in (testgraphs(g_undir) ∪ testdigraphs(g_dir))
            T = eltype(g)

            gt = copy(g)
            gf = copy(g)
            a_converted = convert(Vector{T}, a)
            vmap_t = SG.rem_vertices!(gt, a_converted, keep_order=true)
            vmap_f = SG.rem_vertices!(gf, a_converted, keep_order=false)
            @test issorted(vmap_t)
            @test allunique(vmap_t)
            @test allunique(vmap_f)
            @test sort(vmap_f) == vmap_t
            @test length(vmap_f) == nv(g) - length(a_converted)
            @test vmap_t == setdiff(collect(vertices(g)), a_converted)
            @test LightGraphs.Experimental.has_isomorph(gt, gf)
            gi = g[setdiff(collect(vertices(g)), a_converted)]
            @test LightGraphs.Experimental.has_isomorph(gf, gi)
            @test isvalid_simplegraph(gt)
            @test isvalid_simplegraph(gf)
        end

    end
    @testset "squash" begin
        wgen = SGGEN.Wheel(5)
        g5w = SimpleGraph(wgen); g5wd = SimpleDiGraph(wgen)
        @testset "$g" for g in testgraphs(g5w, g5wd)
            @test eltype(squash(g)) == UInt8
        end
    end
    # codecov for has_edge(::AbstractGraph, x, y)
    @test @inferred has_edge(DummySimpleGraph(), 1, 2)
end
