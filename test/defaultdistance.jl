    @testset "DefaultDistance" begin
        @test size(LightGraphs.DefaultDistance()) == (typemax(Int), typemax(Int))
        d = @inferred(LightGraphs.DefaultDistance(3))
        @test size(d) == (3, 3)
        @test d[1, 1] == getindex(d, 1, 1) == 1
        @test d[1:2, 1:2] == LightGraphs.DefaultDistance(2)
        @test d == transpose(d) == adjoint(d)
        @test sprint(show, d) ==
            stringmime("text/plain", d) ==
            "$(d.nv) × $(d.nv) default distance matrix (value = 1)"
    end
