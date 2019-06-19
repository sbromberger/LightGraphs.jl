@testset "Transitivity" begin
    nvertices = 4

    # Tests on DiGraphs
    @testset "DiGraph" begin
        
        # Null DiGraph should not be affected by the transitive closure.
        nullgraph = DiGraph(2)
        @testset "Null Graph $null" for null in testgraphs(nullgraph)
            T = eltype(null)
            nulldg = DiGraph{T}(nullgraph)
            @testset "no self-loops" begin
                null = @inferred(transitiveclosure(nulldg))
                @test null == nulldg
                @test ne(null) == 0
                c = copy(null)
                @test null == @inferred(transitiveclosure!(c))
            end
            
            loopednulldg = copy(nulldg)
            for i in vertices(loopednulldg)
                add_edge!(loopednulldg, i, i)
            end
            @testset "self-loops" begin
                nulllooped = @inferred(transitiveclosure(nulldg, true))
                @test nulllooped == loopednulldg
                @test ne(nulllooped) == 2
                c = copy(nulllooped)
                @test nulllooped == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(nulllooped) == 2
            end
        end
        
        # DiGraph with one edge should not change with the transitive closure.
        refone = PathDiGraph(2)
        @testset "DiGraph with one edge $one" for one in testgraphs(refone)
            T = eltype(one)
            onedg = DiGraph{T}(refone)
            @testset "no self-loops" begin
                one = @inferred(transitiveclosure(onedg))
                @test one == onedg
                @test ne(one) == 1
                c = copy(one)
                @test one == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(one) == 1
            end
            loopedonedg = copy(onedg)
            for i in vertices(loopedonedg)
                add_edge!(loopedonedg, i, i)
            end
            @testset "self-loops" begin
                loopedone = @inferred(transitiveclosure(loopedonedg, true))
                @test loopedone == loopedonedg
                @test ne(loopedone) == 3
                c = copy(loopedone)
                @test loopedone == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(loopedone) == 3
            end
        end

        
        # A circle should be transformed into a complete digraph.
        completedg = CompleteDiGraph(nvertices)
        circledg = CycleDiGraph(nvertices)
        @testset "$circle" for circle in testgraphs(circledg)
            T = eltype(circle)
            complete = DiGraph{T}(completedg)
            @testset "no self-loops" begin
                newcircle = @inferred(transitiveclosure(circle))
                @test newcircle == complete
                @test ne(circle) == nvertices
                c = copy(circle)
                @test newcircle == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newcircle) == (nvertices * (nvertices - 1))
            end

            loopedcomplete = copy(complete)
            for i in vertices(loopedcomplete)
                add_edge!(loopedcomplete, i, i)
            end
            @testset "self-loops" begin
                newcircle = @inferred(transitiveclosure(circle, true))
                @test newcircle == loopedcomplete
                @test ne(circle) == nvertices
                c = copy(circle)
                @test newcircle == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(newcircle) == (nvertices^2)
            end
        end
    
        # Two unconnected components should remained unconnected with the transitive closure.
        doublecircledg = blockdiag(circledg, circledg)
        doublecompletedg = blockdiag(completedg, completedg)

        @test ne(doublecompletedg) == 2 * (nvertices * (nvertices - 1))
        @test ne(doublecircledg) == 2 * nvertices
        
        
        @testset "double circle $doublecircle" for doublecircle in testgraphs(doublecircledg)
            T = eltype(doublecircle)
            doublecomplete = DiGraph{T}(doublecompletedg)
            @testset "no self-loops" begin
                newdoublecircle = @inferred(transitiveclosure(doublecircle))
                @test newdoublecircle == doublecomplete
                @test ne(doublecircle) == 2 * nvertices
                c = copy(doublecircle)
                @test newdoublecircle == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newdoublecircle) == (2 * nvertices * (nvertices - 1))
            end

            loopeddoublecomplete = copy(doublecompletedg)
            for i in vertices(loopeddoublecomplete)
                add_edge!(loopeddoublecomplete, i, i)
            end
            @testset "self-loops" begin
                loopeddoublecircle = @inferred(transitiveclosure(doublecircle, true))
                @test loopeddoublecircle == loopeddoublecomplete
                @test ne(doublecircle) == 2 * nvertices
                c = copy(doublecircle)
                @test loopeddoublecircle == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(loopeddoublecircle) == (2 * nvertices * nvertices)
            end
        end

        circleonedg = copy(circledg)
        add_vertices!(circleonedg, 2)
        add_edge!(circleonedg, nvertices + 1, nvertices + 2)

        completeonedg = copy(completedg)
        add_vertices!(completeonedg, 2)
        add_edge!(completeonedg, nvertices + 1, nvertices + 2)

        @testset "circle and one $circleone" for circleone in testgraphs(circleonedg)
            T = eltype(circleone)
            completeone = DiGraph{T}(completeonedg)
            @testset "no self-loops" begin
                newcircleone = @inferred(transitiveclosure(circleone))
                @test newcircleone == completeone
                @test ne(circleone) == (nvertices + 1)
                c = copy(circleone)
                @test newcircleone == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newcircleone) == (nvertices * (nvertices - 1) + 1)
            end

            loopedcompleteone = copy(completeone)
            for i in vertices(loopedcompleteone)
                add_edge!(loopedcompleteone, i, i)
            end
            @testset "self-loops" begin
                loopedcircleone = @inferred(transitiveclosure(circleone, true))
                @test loopedcircleone == loopedcompleteone
                @test ne(circleone) == (nvertices + 1)
                c = copy(circleone)
                @test loopedcircleone == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(loopedcircleone) == (nvertices * nvertices + 2 + 1)
            end
        end
    end
    
    ### Tests on graph
    
    @testset "Graph" begin
        # Null graph should not be affected by the transitive closure.
        nullgraph = Graph(2)
        @testset "Null Graph $null" for null in testgraphs(nullgraph)
            T = eltype(null)
            nullg = Graph{T}(nullgraph)
            @testset "no self-loops" begin
                null = @inferred(transitiveclosure(nullg))
                @test null == nullg
                @test ne(null) == 0
                c = copy(null)
                @test null == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(null) == 0
            end
            
            loopednullg = copy(nullg)
            for i in vertices(loopednullg)
                add_edge!(loopednullg, i, i)
            end
            @testset "self-loops" begin
                nulllooped = @inferred(transitiveclosure(nullg, true))
                @test nulllooped == loopednullg
                @test ne(nulllooped) == 2
                c = copy(nulllooped)
                @test nulllooped == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(nulllooped) == 2
            end
        end
        
        # Graph with one edge should not change with the transitive closure.
        refone = PathGraph(2)
        @testset "Graph with one edge $one" for one in testgraphs(refone)
            T = eltype(one)
            onedg = Graph{T}(refone)
            @testset "no self-loops" begin
                one = @inferred(transitiveclosure(onedg))
                @test one == onedg
                @test ne(one) == 1
                c = copy(one)
                @test one == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(one) == 1
            end
            loopedonedg = copy(onedg)
            for i in vertices(loopedonedg)
                add_edge!(loopedonedg, i, i)
            end
            @testset "self-loops" begin
                loopedone = @inferred(transitiveclosure(loopedonedg, true))
                @test loopedone == loopedonedg
                @test ne(loopedone) == 3
                c = copy(loopedone)
                @test loopedone == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(loopedone) == 3
            end
        end

        # A circle graph should be turned into a complete graph with the transitive closure
        completeg = CompleteGraph(nvertices)
        circleg = CycleGraph(nvertices)
        @testset "circle $circle" for circle in testgraphs(circleg)
            T = eltype(circle)
            complete = Graph{T}(completeg)
            @testset "no self-loops" begin
                newcircle = @inferred(transitiveclosure(circle))
                @test newcircle == complete
                @test ne(circle) == nvertices
                c = copy(circle)
                @test newcircle == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newcircle) == binomial(nvertices, 2)
            end

            loopedcomplete = copy(complete)
            for i in vertices(loopedcomplete)
                add_edge!(loopedcomplete, i, i)
            end
            @testset "self-loops" begin
                newcircle = @inferred(transitiveclosure(circle, true))
                @test newcircle == loopedcomplete
                @test ne(circle) == nvertices
                c = copy(circle)
                @test newcircle == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(newcircle) == (binomial(nvertices, 2) + nvertices)
            end
        end

        # Two unconnected components should remained unconnected with the transitive closure.
        doublecircleg = Graph(2 * nvertices)
        for i in 1:3
            add_edge!(doublecircleg, i, i + 1)
            add_edge!(doublecircleg, i + nvertices, i + nvertices + 1)
        end
        add_edge!(doublecircleg, nvertices, 1)
        add_edge!(doublecircleg, 2 * nvertices, nvertices + 1) 

        doublecompleteg = copy(doublecircleg)
        for i in 1:(nvertices - 2)
            for j in i+2:nvertices
                add_edge!(doublecompleteg, i, j)
                add_edge!(doublecompleteg, nvertices + i, nvertices + j)
            end
        end

        @testset "double circle $doublecircle" for doublecircle in testgraphs(doublecircleg)
            T = eltype(doublecircle)
            doublecomplete = Graph{T}(doublecompleteg)
            @testset "no self-loops" begin
                newdoublecircle = @inferred(transitiveclosure(doublecircle))
                @test newdoublecircle == doublecomplete
                @test ne(doublecircle) == 2 * nvertices
                c = copy(doublecircle)
                @test newdoublecircle == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newdoublecircle) == 2 * binomial(nvertices, 2)
            end

            loopeddoublecomplete = copy(doublecomplete)
            for i in vertices(loopeddoublecomplete)
                add_edge!(loopeddoublecomplete, i, i)
            end
            @testset "self-loops" begin
                loopeddoublecircle = @inferred(transitiveclosure(doublecircle, true))
                @test loopeddoublecircle == loopeddoublecomplete
                @test ne(doublecircle) == 2 * nvertices
                c = copy(doublecircle)
                @test loopeddoublecircle == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(loopeddoublecircle) == 2 * (binomial(nvertices, 2) + nvertices)
            end
        end

        circleonedg = copy(circleg)
        add_vertices!(circleonedg, 2)
        add_edge!(circleonedg, nvertices + 1, nvertices + 2)

        completeonedg = copy(completeg)
        add_vertices!(completeonedg, 2)
        add_edge!(completeonedg, nvertices + 1, nvertices + 2)

        @testset "circle and one $circleone" for circleone in testgraphs(circleonedg)
            T = eltype(circleone)
            completeone = Graph{T}(completeonedg)
            @testset "no self-loops" begin
                newcircleone = @inferred(transitiveclosure(circleone))
                @test newcircleone == completeone
                @test ne(circleone) == (nvertices + 1)
                c = copy(circleone)
                @test newcircleone == @inferred(transitiveclosure!(c))
                @test ne(c) == ne(newcircleone) == (binomial(nvertices, 2) + 1)
            end

            loopedcompleteone = copy(completeone)
            for i in vertices(loopedcompleteone)
                add_edge!(loopedcompleteone, i, i)
            end
            @testset "self-loops" begin
                loopedcircleone = @inferred(transitiveclosure(circleone, true))
                @test loopedcircleone == loopedcompleteone
                @test ne(circleone) == (nvertices + 1)
                c = copy(circleone)
                @test loopedcircleone == @inferred(transitiveclosure!(c, true))
                @test ne(c) == ne(loopedcircleone) == (binomial(nvertices, 2) + nvertices + 2 + 1)
            end
        end
    end
end
