complete = CompleteDiGraph(4)

@test maxsimplecycles(g4) == 0
@test maxsimplecycles(complete) == 20
@test maxsimplecycles(4) == 20
@test maxsimplecycles(g4, false) == 84

@test length(simplecycles(complete)) == 20
@test simplecycles(complete) == simplecycles_iter(complete)
@test simplecyclescount(complete) == 20
@test simplecycleslength(complete) == ([0,6,8,6], 20)

@test simplecyclescount(g4) == 0
@test length(simplecycles(g4)) == 0
@test isempty(simplecycles(g4)) == true
@test isempty(simplecycles_iter(g4)) == true
@test simplecycleslength(g4) == (zeros(5), 0)

@test simplecyclescount(complete, 10) == 10
@test simplecycleslength(complete, 10)[2] == 10

@test simplecyclescount(g4, 10) == 0
@test isempty(simplecycles_iter(g4, 10)) == true
@test simplecycleslength(g4, 10) == (zeros(5), 0)

trianglelengths, triangletotal = simplecycleslength(DiGraph(triangle))
@test sum(trianglelengths) == triangletotal

quadranglelengths, quadrangletotal = simplecycleslength(DiGraph(quadrangle))
@test sum(quadranglelengths) == quadrangletotal
@test simplecycles(DiGraph(quadrangle)) == simplecycles_iter(DiGraph(quadrangle))

pentagonlengths, pentagontotal = simplecycleslength(DiGraph(pentagon))
@test sum(pentagonlengths) == pentagontotal

