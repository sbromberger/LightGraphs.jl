@testset "Operators" begin
    g3 = PathGraph(5)
    g4 = PathDiGraph(5)

    for g in testlargegraphs(g3)
        T = eltype(g)
        c = complement(g)
        @test @inferred(nv(c)) == 5
        @test @inferred(ne(c)) == 6

        gb = blkdiag(g, g)
        @test @inferred(nv(gb)) == 10
        @test @inferred(ne(gb)) == 8

        hp = PathGraph(2)
        h = Graph{T}(hp)
        @test intersect(g, h) == h

        hp = PathGraph(4)
        h = Graph{T}(hp)

        z = difference(g, h)
        @test @inferred(nv(z)) == 5
        @test @inferred(ne(z)) == 1
        z = difference(h, g)
        @test @inferred(nv(z)) == 4
        @test @inferred(ne(z)) == 0
        z = symmetric_difference(h,g)
        @test z == symmetric_difference(g,h)
        @test @inferred(nv(z)) == 5
        @test @inferred(ne(z)) == 1

        h = Graph{T}(6)
        add_edge!(h, 5, 6)
        e = SimpleEdge(5, 6)

        z = union(g, h)
        @test has_edge(z, e)
        @test z == PathGraph(6)
    end
    for g in testlargedigraphs(g4)
        T = eltype(g)
        c = complement(g)
        @test @inferred(nv(c)) == 5
        @test @inferred(ne(c)) == 16

        h = DiGraph{T}(6)
        add_edge!(h, 5, 6)
        e = SimpleEdge(5, 6)

        z = union(g, h)
        @test has_edge(z, e)
        @test z == PathDiGraph(6)
    end

    re1 = Edge(2, 1)
    gr = reverse(g4)
    for g in testdigraphs(gr)
        T = eltype(g)
        @test re1 in edges(g)
        reverse!(g)
        @test g == DiGraph{T}(g4)
    end

    gx = CompleteGraph(2)

    for g in testlargegraphs(gx)
        T = eltype(g)
        hc = CompleteGraph(2)
        h = Graph{T}(hc)
        z = blkdiag(g, h)
        @test @inferred(nv(z)) == nv(g) + nv(h)
        @test @inferred(ne(z)) == ne(g) + ne(h)
        @test has_edge(z, 1, 2)
        @test has_edge(z, 3, 4)
        @test !has_edge(z, 1, 3)
        @test !has_edge(z, 1, 4)
        @test !has_edge(z, 2, 3)
        @test !has_edge(z, 2, 4)
    end

    gx = Graph(2)
    for g in testgraphs(gx)
        T = eltype(g)
        h = Graph{T}(2)
        z = join(g, h)
        @test @inferred(nv(z)) == nv(g) + nv(h)
        @test @inferred(ne(z)) == 4
        @test !has_edge(z, 1, 2)
        @test !has_edge(z, 3, 4)
        @test has_edge(z, 1, 3)
        @test has_edge(z, 1, 4)
        @test has_edge(z, 2, 3)
        @test has_edge(z, 2, 4)
    end

    px = PathGraph(10)
    for p in testgraphs(px)
        x = p*ones(10)
        @test @inferred( x[1]) ==1.0 && all(x[2:end-1].==2.0) && x[end]==1.0
        @test @inferred(size(p)) == (10,10)
        @test size(p, 1) == size(p, 2) == 10
        @test size(p, 3) == 1
        @test @inferred(sum(p,1)) == sum(p,2)
        @test_throws ErrorException sum(p,3)
        @test @inferred(sparse(p)) == adjacency_matrix(p)
        @test @inferred(length(p)) == 100
        @test @inferred(ndims(p)) == 2
        @test issymmetric(p)
    end

    gx = DiGraph(4)
    add_edge!(gx,1,2); add_edge!(gx,2,3); add_edge!(gx,1,3); add_edge!(gx,3,4)
    for g in testdigraphs(gx)
        @test g * ones(nv(g)) == [2.0, 1.0, 1.0, 0.0]
        @test sum(g, 1) ==  [0, 1, 2, 1]
        @test sum(g, 2) ==  [2, 1, 1, 0]
        @test @inferred(sum(g)) == 4
        @test !issymmetric(g)
    end

    nx = 20; ny = 21
    gx = PathGraph(ny)
    for g in testlargegraphs(gx)
        T = eltype(g)
        hp = PathGraph(nx)
        h = Graph{T}(hp)
        c = cartesian_product(g, h)
        gz = crosspath(ny, PathGraph(nx));
        @test @inferred(gz) == c
    end
    function crosspath_slow(len, h)
        g = h
        m = nv(h)
        for i in 1:len-1
            k = nv(g)
            g = blkdiag(g,h)
            for v in 1:m
                add_edge!(g, v+(k-m), v+k)
            end
        end
        return g
    end

    gx = CompleteGraph(2)
    for g in testgraphs(gx)
        h = cartesian_product(g, g)
        @test @inferred(nv(h)) == 4
        @test @inferred(ne(h)) == 4

        h = tensor_product(g, g)
        @test @inferred(nv(h)) == 4
        @test @inferred(ne(h)) == 1
    end
    g2 = CompleteGraph(2)
    for g in testgraphs(g2)
        @test crosspath_slow(2, g) == crosspath(2, g)
    end

    ## test subgraphs ##

    gb = smallgraph(:bull)
    for g in testgraphs(gb)
        n = 3
        h = g[1:n]
        @test @inferred(nv(h)) == n
        @test @inferred(ne(h)) == 3

        h = g[[1,2,4]]
        @test @inferred(nv(h)) == n
        @test @inferred(ne(h)) == 2

        h = g[[1,5]]
        @test @inferred(nv(h)) == 2
        @test @inferred(ne(h)) == 0
        @test @inferred(typeof(h)) == typeof(g)
    end

    gx = DiGraph(100,200)
    for g in testdigraphs(gx)
        h = g[5:26]
        @test @inferred(nv(h)) == 22
        @test @inferred(typeof(h)) == typeof(g)
        @test_throws ErrorException g[[1,1]]

        r = 5:26
        h2, vm = induced_subgraph(g, r)
        @test @inferred(h2) == h
        @test @inferred(vm) == collect(r)
        @test @inferred(h2) == g[r]
    end

    g10 = CompleteGraph(10)
    for g in testgraphs(g10)
        sg, vm = induced_subgraph(g, 5:8)
        @test @inferred(nv(sg)) == 4
        @test @inferred(ne(sg)) == 6

        sg2, vm = induced_subgraph(g, [5,6,7,8])
        @test @inferred(sg2) == sg
        @test @inferred(vm[4]) == 8

        elist = [
          SimpleEdge(1, 2), SimpleEdge(2, 3), SimpleEdge(3, 4),
          SimpleEdge(4, 5),SimpleEdge(5, 1)
        ]
        sg, vm = induced_subgraph(g, elist)
        @test @inferred(sg) == CycleGraph(5)
        @test @inferred(sort(vm)) == [1:5;]
    end

    gs = StarGraph(10)
    for g in testgraphs(gs)
        T = eltype(g)
        @test egonet(g, 1, 0) == Graph{T}(1)
        @test egonet(g, 1, 1) == g
        @test @inferred(ndims(g)) == 2
    end
end
