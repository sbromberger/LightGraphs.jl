using LightGraphs
using MatrixDepot
function symmetrize(A)
    println("Symmetrizing ")
    tic()
    if !issymmetric(A)
        println(STDERR, "the matrix is not symmetric using A+A'")
        A = A + A'
    end
    if isa(A, Base.LinAlg.Symmetric)
        A.data.nzval = abs(A.data.nzval)
    else
        A.nzval = abs(A.nzval)
    end
    #= spA = abs(sparse(A)) =#
    toc()
    return A
end

function loadmat(matname)
    println("Reading MTX for $matname")
    tic()
    try
        info = matrixdepot(matname, :get)
    end
    A = matrixdepot(matname, :read)
    A = symmetrize(A)
    g = Graph(A)
    toc()
    println(STDERR, "size(A) = $(size(A))")
    return g
end

function vec2tree(v::Vector{Int})
    nv = length(v)
    I = Vector{Int}()
    J = Vector{Int}()
    for i in 1:nv
        if v[i] > 0
            push!(I, i)
            push!(J, v[i])
        end
    end
    #= @assert length(I) == length(J) =#
    ncolumns = max(maximum(J), maximum(I))
    nentries = length(J)
    n = ncolumns
    return sparse(I,J, fill(1, nentries), n,n)
end


names = ["Newman/football" , "Newman/cond-mat-2003", "SNAP/amazon0302", "SNAP/roadNet-CA"]
for matname in names
    g = loadmat(matname)
    seed = 1
    println("bfs_tree original")
    # woah bfs_tree allocates a lot of memory
    @time tdg = LightGraphs.bfs_tree(g, seed)
    println(tdg)
    # preallocating the output tree reduces the number of allocations.
    # much faster
    println("bfs_tree!(vector)")
    visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int, nv(g)))
    @time tvec = LightGraphs.bfs_tree!(visitor, g, seed)
    println("converting to Sparse")
    @time m = vec2tree(visitor.tree)
    println("converting to DiGraph")
    @time h = DiGraph(m)
end
