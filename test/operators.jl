@testset "Operators" begin
    g3 = path_graph(5)
    g4 = path_digraph(5)

    @testset "$g" for g in testlargegraphs(g3)
        T = eltype(g)
        @testset "complement" begin
            c = @inferred(complement(g))
            @test nv(c) == 5
            @test ne(c) == 6
        end

        @testset "blockdiag" begin
            gb = @inferred(blockdiag(g, g))
            @test nv(gb) == 10
            @test ne(gb) == 8
        end

        @testset "intersect" begin
            hp = path_graph(2)
            h = Graph{T}(hp)
            @test @inferred(intersect(g, h)) == h
        end

        @testset "difference / symmetric difference" begin
            hp = path_graph(4)
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
        end

        @testset "symmetric difference for Digraph" begin
            g1 = path_digraph(2)
            g2 = path_digraph(4)

            y = symmetric_difference2(g1, g2)
            y == symmetric_difference2(g2, g1)
            ne(y) == 2
            nv(y) == 4
        end
    
        @testset "union" begin
            h = Graph{T}(6)
            add_edge!(h, 5, 6)
            e = SimpleEdge(5, 6)

            z = @inferred(union(g, h))
            @test has_edge(z, e)
            @test z == path_graph(6)
        end

        @testset "merge vertices" begin
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

            g2 = path_graph(5)
            h2 = merge_vertices(g, [2, 3])
            @test neighbors(h2, 1) == [2]
            @test neighbors(h2, 2) == [1, 3]
            @test neighbors(h2, 3) == [2, 4]
            @test neighbors(h2, 4) == [3]

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

        @testset "merge vertices digraph" begin
            d0 = path_digraph(10)
            merge_vertices!(d0, [6,4,5,5,4,5,6,5,4,6])
            @test length(edges(d0)) == 7
            d1 = path_digraph(10)
            merge_vertices!(d1, [4,5,6])
            @test length(edges(d1)) == 7

            @test d0 == d1
        end
    end

    @testset "$g" for g in testlargegraphs(g4)
        T = eltype(g)
        @testset "complement" begin
            c = @inferred(complement(g))
            @test nv(c) == 5
            @test ne(c) == 16
        end

        @testset "union" begin
            h = DiGraph{T}(6)
            add_edge!(h, 5, 6)
            e = SimpleEdge(5, 6)

            z = @inferred(union(g, h))
            @test has_edge(z, e)
            @test z == path_digraph(6)
        end
    end

    re1 = Edge(2, 1)
    gr = @inferred(reverse(g4))
    @testset "Reverse $g" for g in testdigraphs(gr)
        T = eltype(g)
        @test re1 in edges(g)
        @inferred(reverse!(g))
        @test g == DiGraph{T}(g4)
    end

    gx = complete_graph(2)

    @testset "Blockdiag $g" for g in testlargegraphs(gx)
        T = eltype(g)
        hc = complete_graph(2)
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
    @testset "Join $g" for g in testgraphs(gx)
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

    px = path_graph(10)
    @testset "Matrix operations: $p" for p in testgraphs(px)
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
    @testset "Matrix operations: $g" for g in testdigraphs(gx)
        @test @inferred(g * ones(nv(g))) == [2.0, 1.0, 1.0, 0.0]
        @test sum(g, 1) ==  [0, 1, 2, 1]
        @test sum(g, 2) ==  [2, 1, 1, 0]
        @test sum(g) == 4
        @test @inferred(!issymmetric(g))
    end

    nx = 20; ny = 21
    gx = path_graph(ny)
    @testset "Cartesian Product / Crosspath: $g" for g in testlargegraphs(gx)
        T = eltype(g)
        hp = path_graph(nx)
        h = Graph{T}(hp)
        c = @inferred(cartesian_product(g, h))
        gz = @inferred(crosspath(ny, path_graph(nx)))
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

    gx = complete_graph(2)
    @testset "Cartesian Product / Tensor Product: $g" for g in testgraphs(gx)
        h = @inferred(cartesian_product(g, g))
        @test nv(h) == 4
        @test ne(h) == 4

        h = @inferred(tensor_product(g, g))
        @test nv(h) == 4
        @test ne(h) == 2
    end
    g2 = complete_graph(2)
    @testset "Crosspath: $g" for g in testgraphs(g2)
        @test crosspath_slow(2, g) == crosspath(2, g)
    end
    for i in 3:4
        gx = path_graph(i)
        @testset "Tensor Product: $g" for g in testgraphs(gx)
            @test length(connected_components(tensor_product(g, g))) == 2
        end
    end

    ## test subgraphs ##

    gb = smallgraph(:bull)
    @testset "Subgraphs: $g" for g in testgraphs(gb)
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
    @testset "Subgraphs: $g" for g in testdigraphs(gx)
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

    g10 = complete_graph(10)
    @testset "Induced Subgraphs: $g" for g in testgraphs(g10)
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
        @test sg == cycle_graph(5)
        @test sort(vm) == [1:5;]
    end

    gs = star_graph(10)
    distgs = fill(4.0, 10, 10)
    @testset "Egonet: $g" for g in testgraphs(gs)
        T = eltype(g)
        @test @inferred(egonet(g, 1, 0)) == Graph{T}(1)
        @test @inferred(egonet(g, 1, 3, distgs)) == Graph{T}(1)
        @test @inferred(egonet(g, 1, 1)) == g
        @test @inferred(ndims(g)) == 2
    end

    gx = SimpleGraph(100)
    @testset "Length: $g" for g in testgraphs(gx)
        @test length(g) == 10000
    end
end
