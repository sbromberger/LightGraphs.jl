using LightGraphs 

sizesnbm1 = Int64[@allocated non_backtracking_matrix(CycleGraph(2^i))for i in 4:10]
sizesnbm2 = Int64[@allocated Nonbacktracking(CycleGraph(2^i)) for i in 4:10]


println("Relative Sizes:\n $(float(sizesnbm1./sizesnbm2))")

macro storetime(name, expression)
    ex = quote
        val = $expression;
        timeinfo[$name] = @elapsed $expression; 
        val
    end
    return ex
end

function bench(g)
    nbt = @storetime :Construction_Nonbacktracking  Nonbacktracking(g)
    x  = ones(Float64, size(nbt)[1])
    info("Cycle with $n vertices has nbt in R^$(size(nbt))")

    B, nmap = @storetime :Construction_Dense        non_backtracking_matrix(g)
    y  = @storetime :Multiplication_Nonbacktracking nbt*x
    z  = @storetime :Multiplication_Dense           B*x;
    S  = @storetime :Construction_DS                sparse(B)
    z  = @storetime :Multiplication_Sparse          z = S*x;
    Sp = @storetime :Construction_Sparse            sparse(nbt)
    z  = @storetime :Multiplication_Sparse          Sp*x
end

function report(timeinfo)
    info("Times")
    println("Function\t Constructors\t Multiplication")
    println("Dense   \t $(timeinfo[:Construction_Dense])\t $(timeinfo[:Multiplication_Dense])")
    println("Sparse  \t $(timeinfo[:Construction_Sparse])\t $(timeinfo[:Multiplication_Sparse])")
    println("Implicit\t $(timeinfo[:Construction_Nonbacktracking])\t $(timeinfo[:Multiplication_Nonbacktracking])")
    info("Implicit Multiplication is $(timeinfo[:Multiplication_Dense]/timeinfo[:Multiplication_Nonbacktracking]) faster than dense.")
    info("Sparse Multiplication is $(timeinfo[:Multiplication_Nonbacktracking]/timeinfo[:Multiplication_Sparse]) faster than implicit.")
    info("Direct Sparse Construction took $(timeinfo[:Construction_Sparse])
    Dense to Sparse took: $(timeinfo[:Construction_DS])")
end

n = 2^13
C = CycleGraph(n)
timeinfo = Dict{Symbol, Float64}()
bench(C)
report(timeinfo)
