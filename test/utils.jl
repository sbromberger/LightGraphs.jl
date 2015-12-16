s = LightGraphs.sample!([1:10;], 3)
@test length(s) == 3
for  e in s
    @test 1 <= e <= 10
end

s = LightGraphs.sample!([1:10;], 6, exclude=[1,2])
@test length(s) == 6
for  e in s
    @test 2 <= e <= 10
end

@test start(nothing) == nothing
@test done(nothing, nothing) == true
@test next(nothing, nothing) == (nothing, nothing)
@test length(nothing) == 0
