
(f,fio) = mktemp()
@test write(p1, f) == (46, 69)
@test write(p1, f; compress=false) == (46, 69)
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(write, p1)) == 461
@test length(sprint(write, p2)) == 51

rm(f)

_HAVE_LIGHTXML = try
        using LightXML
        true
    catch
        false
    end

if _HAVE_LIGHTXML
#Try reading in a GraphML file from the Rome Graph collection
#http://www.graphdrawing.org/data/
let Gs = read_graphml("data/grafo1853.13.graphml")
    @test length(Gs) == 1
    @test Gs[1][1] == "G" #Name of graph
    G = Gs[1][2]
    @test nv(G) == 13
    @test ne(G) == 15
end
end # _HAVE_LIGHTXML

