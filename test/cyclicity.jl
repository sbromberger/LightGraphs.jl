complete = CompleteDiGraph(4)
path = PathDiGraph(5)
triangle = random_regular_graph(3,2)
quadrangle = random_regular_graph(4,2)
pentagon = random_regular_graph(5,2)

@test maxsimplecycles(path) == 0
@test maxsimplecycles(complete) == 20
@test maxsimplecycles(4) == 20
@test maxsimplecycles(path, false) == 84

@test length(simplecycles(complete)) == 20
@test simplecycles(complete) == simplecycles_iter(complete)
@test simplecyclescount(complete) == 20
@test simplecycleslength(complete) == ([0,6,8,6], 20)

@test simplecyclescount(path) == 0
@test length(simplecycles(path)) == 0
@test isempty(simplecycles(path)) == true
@test isempty(simplecycles_iter(path)) == true
@test simplecycleslength(path) == (zeros(5), 0)

@test simplecyclescount(complete, 10) == 10
@test simplecycleslength(complete, 10)[2] == 10

@test simplecyclescount(path, 10) == 0
@test isempty(simplecycles_iter(path, 10)) == true
@test simplecycleslength(path, 10) == (zeros(5), 0)

trianglelengths, triangletotal = simplecycleslength(DiGraph(triangle))
@test sum(trianglelengths) == triangletotal

quadranglelengths, quadrangletotal = simplecycleslength(DiGraph(quadrangle))
@test sum(quadranglelengths) == quadrangletotal
@test simplecycles(DiGraph(quadrangle)) == simplecycles_iter(DiGraph(quadrangle))

pentagonlengths, pentagontotal = simplecycleslength(DiGraph(pentagon))
@test sum(pentagonlengths) == pentagontotal
