using Benchmarks
function bcolon(a, val)
    a[:] = val
end
function bloop(a, val)
    for i in 1:length(a)
        a[i] = val
    end
end
function bfill(a, val)
    fill!(a, val)
end

function bcolonr(a, val)
    a[:] = val
    a
end
function bloopr(a, val)
    for i in 1:length(a)
        a[i] = val
    end
    a
end
function bfillr(a, val)
    fill!(a, val)
    a
end
a = zeros(Int, 10)
bcolon(a,1)
bloop(a,1)
bfill(a,1)
bcolonr(a,1)
bloopr(a,1)
bfillr(a,1)
a = zeros(Int, 10^5)
@benchmark bcolon(a,1)
@benchmark bloop(a,1)
@benchmark bfill(a,1)
@benchmark bcolonr(a,1)
@benchmark bloopr(a,1)
@benchmark bfillr(a,1)
