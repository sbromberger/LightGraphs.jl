@testset "Operators" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)

    for g in testlargegraphs(g3)
        T = eltype(g)
        c = @inferred(complement(g))
        @test nv(c) == 5
        @test ne(c) == 6

        gb = @inferred(blockdiag(g, g))
        @test nv(gb) == 10
        @test ne(gb) == 8

        hp = PathGraph(2)
        h = Graph{T}(hp)
        @test @inferred(intersect(g, h)) == h

        hp = PathGraph(4)
        h = Graph{T}(hp)

        z = @inferred(difference(g, h))
        @test nv(z) == 5
        @test ne(z) == 1
        z = @inferred(difference(h, g))
        @test nv(z) == 4
        @test ne(z) == 0
        z = @inferred(symmetric_difference(h, g))
        @test z == symmetric_difference(g, h)
        @test nv(z) == 5
        @test ne(z) == 1

        h = Graph{T}(6)
        add_edge!(h, 5, 6)
        e = SimpleEdge(5, 6)

        z = @inferred(union(g, h))
        @test has_edge(z, e)
        @test z == PathGraph(6)

        # Check merge_vertices function.
        h = Graph{T}(7)
        add_edge!(h, 2, 5)
        add_edge!(h, 3, 6)
        add_edge!(h, 1, 7)
        add_edge!(h, 6, 5)

        vs = [2, 3, 7, 3, 3, 2]
        hmerged = merge_vertices(h, vs)
        @test neighbors(hmerged, 1) == [2]
        @test neighbors(hmerged, 2) == [1, 4, 5]
        @test neighbors(hmerged, 3) == []
        @test neighbors(hmerged, 4) == [2, 5]

        new_map = @inferred(merge_vertices!(h, vs))
        @test new_map == [1, 2, 2, 3, 4, 5, 2]
        @test neighbors(h, 1) == [2]
        @test neighbors(h, 2) == [1, 4, 5]
        @test neighbors(h, 3) == []
        @test neighbors(hmerged, 4) == [2, 5]
        @test hmerged == h

        h = Graph{T}(7)
        add_edge!(h, 1, 2)
        add_edge!(h, 2, 3)
        add_edge!(h, 2, 4)
        add_edge!(h, 3, 4)
        add_edge!(h, 3, 7)
        new_map = @inferred(merge_vertices!(h, [2, 3, 2, 2]))
        @test new_map == [1, 2, 2, 3, 4, 5, 6]
        @test neighbors(h, 2) == [1, 3, 6]
        @test neighbors(h, 1) == [2]
        @test neighbors(h, 3) == [2]
        @test neighbors(h, 4) == Int[]
        @test neighbors(h, 6) == [2]
        @test ne(h) == 3
        @test nv(h) == 6

        h2 = Graph{T}(7)
        add_edge!(h2, 1, 2)
        add_edge!(h2, 2, 3)
        add_edge!(h2, 2, 4)
        add_edge!(h2, 3, 4)
        add_edge!(h2, 3, 7)
        add_edge!(h2, 6, 7)
        new_map = @inferred(merge_vertices!(h2, [2, 7, 3, 2]))
        @test new_map == [1, 2, 2, 3, 4, 5, 2]
        @test neighbors(h2, 2) == [1, 3, 5]
        @test neighbors(h2, 1) == [2]
        @test neighbors(h2, 3) == [2]
        @test neighbors(h2, 4) == Int[]
        @test neighbors(h2, 5) == [2]
        @test ne(h2) == 3
        @test nv(h2) == 5

    end
    for g in testlargedigraphs(g4)
        T = eltype(g)
        c = @inferred(complement(g))
        @test nv(c) == 5
        @test ne(c) == 16

        h = DiGraph{T}(6)
        add_edge!(h, 5, 6)
        e = SimpleEdge(5, 6)

        z = @inferred(union(g, h))
        @test has_edge(z, e)
        @test z == PathDiGraph(6)

        # Check merge_vertices function.
        # h = DiGraph{T}(7)
        # add_edge!(h, 2, 5)
        # add_edge!(h, 3, 6)
        # add_edge!(h, 1, 7)
        # add_edge!(h, 4, 3)
        # add_edge!(h, 6, 5)
        # new_map = @inferred(merge_vertices!(h, [2, 3, 7, 3, 3, 2]))
        # @test new_map == [1, 2, 2, 4, 5, 3, 2]
        # @test inneighbors(h, 2) == [1, 4]
        # @test outneighbors(h, 2) == [3, 5]
        # @test outneighbors(h, 3) == [5]

    end

    re1 = Edge(2, 1)
    gr = @inferred(reverse(g4))
    for g in testdigraphs(gr)
        T = eltype(g)
        @test re1 in edges(g)
        @inferred(reverse!(g))
        @test g == DiGraph{T}(g4)
    end

    gx = CompleteGraph(2)

    for g in testlargegraphs(gx)
        T = eltype(g)
        hc = CompleteGraph(2)
        h = Graph{T}(hc)
        z = @inferred(blockdiag(g, h))
        @test nv(z) == nv(g) + nv(h)
        @test ne(z) == ne(g) + ne(h)
        @test has_edge(z, 1, 2)
        @test has_edge(z, 3, 4)
        @test !has_edge(z, 1, 3)
        @test !has_edge(z, 1, 4)
        @test !has_edge(z, 2, 3)
        @test !has_edge(z, 2, 4)
    end

    gx = SimpleGraph(2)
    for g in testgraphs(gx)
        T = eltype(g)
        h = Graph{T}(2)
        z = @inferred(join(g, h))
        @test nv(z) == nv(g) + nv(h)
        @test ne(z) == 4
        @test !has_edge(z, 1, 2)
        @test !has_edge(z, 3, 4)
        @test has_edge(z, 1, 3)
        @test has_edge(z, 1, 4)
        @test has_edge(z, 2, 3)
        @test has_edge(z, 2, 4)
    end

    px = PathGraph(10)
    for p in testgraphs(px)
        x = @inferred(p * ones(10))
        @test  x[1] == 1.0 && all(x[2:(end - 1)] .== 2.0) && x[end] == 1.0
        @test size(p) == (10, 10)
        @test size(p, 1) == size(p, 2) == 10
        @test size(p, 3) == 1
        @test sum(p, 1) == sum(p, 2)
        @test_throws ArgumentError sum(p, 3)
        @test sparse(p) == adjacency_matrix(p)
        @test length(p) == 100
        @test ndims(p) == 2
        @test issymmetric(p)
    end

    gx = SimpleDiGraph(4)
    add_edge!(gx, 1, 2); add_edge!(gx, 2, 3); add_edge!(gx, 1, 3); add_edge!(gx, 3, 4)
    for g in testdigraphs(gx)
        @test @inferred(g * ones(nv(g))) == [2.0, 1.0, 1.0, 0.0]
        @test sum(g, 1) ==  [0, 1, 2, 1]
        @test sum(g, 2) ==  [2, 1, 1, 0]
        @test sum(g) == 4
        @test @inferred(!issymmetric(g))
    end

    nx = 20; ny = 21
    gx = PathGraph(ny)
    for g in testlargegraphs(gx)
        T = eltype(g)
        hp = PathGraph(nx)
        h = Graph{T}(hp)
        c = @inferred(cartesian_product(g, h))
        gz = @inferred(crosspath(ny, PathGraph(nx)))
        @test gz == c
    end
    function crosspath_slow(len, h)
        g = h
        m = nv(h)
        for i in 1:(len - 1)
            k = nv(g)
            g = blockdiag(g, h)
            for v in 1:m
                add_edge!(g, v + (k - m), v + k)
            end
        end
        return g
    end

    gx = CompleteGraph(2)
    for g in testgraphs(gx)
        h = @inferred(cartesian_product(g, g))
        @test nv(h) == 4
        @test ne(h) == 4

        h = @inferred(tensor_product(g, g))
        @test nv(h) == 4
        @test ne(h) == 2
    end
    g2 = CompleteGraph(2)
    for g in testgraphs(g2)
        @test crosspath_slow(2, g) == crosspath(2, g)
    end
    for i in 3:4
        gx = PathGraph(i)
        for g in testgraphs(gx)
            @test length(connected_components(tensor_product(g, g))) == 2
        end
    end

    ## test subgraphs ##

    gb = smallgraph(:bull)
    for g in testgraphs(gb)
        n = 3
        h = @inferred(g[1:n])
        @test nv(h) == n
        @test ne(h) == 3

        h = @inferred(g[[1, 2, 4]])
        @test nv(h) == n
        @test ne(h) == 2

        h = @inferred(g[[1, 5]])
        @test nv(h) == 2
        @test ne(h) == 0
        @test typeof(h) == typeof(g)
    end

    gx = SimpleDiGraph(100, 200)
    for g in testdigraphs(gx)
        h = @inferred(g[5:26])
        @test nv(h) == 22
        @test typeof(h) == typeof(g)
        @test_throws ArgumentError g[[1, 1]]

        r = 5:26
        h2, vm = @inferred(induced_subgraph(g, r))
        @test h2 == h
        @test vm == collect(r)
        @test h2 == g[r]
    end

    g10 = CompleteGraph(10)
    for g in testgraphs(g10)
        sg, vm = @inferred(induced_subgraph(g, 5:8))
        @test nv(sg) == 4
        @test ne(sg) == 6

        sg2, vm = @inferred(induced_subgraph(g, [5, 6, 7, 8]))
        @test sg2 == sg
        @test vm[4] == 8

        elist = [
          SimpleEdge(1, 2), SimpleEdge(2, 3), SimpleEdge(3, 4),
          SimpleEdge(4, 5), SimpleEdge(5, 1)
        ]
        sg, vm = @inferred(induced_subgraph(g, elist))
        @test sg == CycleGraph(5)
        @test sort(vm) == [1:5;]
    end

    gs = StarGraph(10)
    distgs = fill(4.0, 10, 10)
    for g in testgraphs(gs)
        T = eltype(g)
        @test @inferred(egonet(g, 1, 0)) == Graph{T}(1)
        @test @inferred(egonet(g, 1, 3, distgs)) == Graph{T}(1)
        @test @inferred(egonet(g, 1, 1)) == g
        @test @inferred(ndims(g)) == 2
    end

    gx = SimpleGraph(100)
    for g in testgraphs(gx)
        @test length(g) == 10000
    end

    #Test for line graph of undirected graphs

    gx = SimpleGraph(10,20)
    for g in testgraphs(gx)
        lg = linegraph(g)
        sum_sq_deg = 0
        for u in vertices(g) sum_sq_deg += (degree(g,u)*degree(g,u)) end
        @test nv(lg) == ne(g)
        @test ne(lg) == ((sum_sq_deg/2)-ne(g))
    end

    #Test for line graph of directed graphs

    gy = SimpleDiGraph(10,20)
    for g in testdigraphs(gy)
        lg,lineV_graphE = linegraph(g,true)
        for e in edges(lg)
            uv = lineV_graphE[src(e)]
            vw = lineV_graphE[dst(e)]
            @test has_edge(g,uv) && has_edge(g,vw)
        end
    end

    gz = CompleteDiGraph(3)
    add_edge!(gz, 1, 1)
    for g in testdigraphs(gz)
        @test has_self_loops(linegraph(gz))
    end

    #Test get_root function for line graph

    g5 = CompleteGraph(5)
    rem_edge!(g5, 1, 4)
    rem_edge!(g5, 2, 5)
    rem_edge!(g5, 1, 5)

    is_isomorphic = LightGraphs.Experimental.has_isomorph
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    rem_edge!(g5, 2, 3)
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    add_edge!(g5, 1, 4)
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    add_edge!(g5, 1, 5)
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    rem_edge!(g5, 1, 2)
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    rem_edge!(g5, 4, 5)
    @test is_isomorphic(g5, get_root(linegraph(g5)))

    gx = SimpleGraph(5)
    add_edge!(gx, 1, 2)
    add_edge!(gx, 1, 3)
    add_edge!(gx, 2, 3)
    add_edge!(gx, 2, 4)
    add_edge!(gx, 2, 5)
    @test_throws ArgumentError get_root(gx)

    gy = CompleteGraph(5)
    rem_edge!(gy, 3, 5)
    rem_edge!(gy, 3, 4)

    @test is_isomorphic(gx, get_root(gy))

    add_edge!(gy, 3, 5)
    rem_edge!(gy, 4, 5)

    @test is_isomorphic(gx, get_root(gy))

    gx = CompleteGraph(6)
    @test is_isomorphic(gx, get_root(linegraph(gx)))

    gy = CompleteGraph(4)
    rem_edge!(gy, 1, 3)
    rem_edge!(gy, 1, 4)

    gx = CompleteGraph(4)
    rem_edge!(gx, 3, 4)
    @test is_isomorphic(gy, get_root(gx))

    gx = CompleteGraph(5)
    rem_edge!(gx, 3, 5)
    rem_edge!(gx, 4, 5)
    rem_edge!(gx, 3, 4)
    @test_throws ArgumentError get_root(gx)
end
