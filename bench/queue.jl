
function f(a, n::Int)
    for i in 1:n
        push!(a, i)
    end
end

n = 10^2
a = Vector{Int}()
f(a, n)
n = 10^5
a = Vector{Int}()
@time f(a, n)
a = Vector{Int}()
sizehint!(a, n)
@time f(a, n)
