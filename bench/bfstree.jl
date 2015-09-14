using LightGraphs
using MatrixDepot
function symetrize(A)
    println("Symmetrizing ")
    tic()
    if !issym(A) 
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
    A = matrixdepot(matname, :read)
    A = symetrize(A)
    g = Graph(A)
    toc()
    println(STDERR, "size(A) = $(size(A))")
    return g
end


names = ["Newman/football" , "Newman/cond-mat-2003", "SNAP/amazon0302", "SNAP/roadNet-CA"]
for matname in names
    g = loadmat(matname)
    seed = 1
    println("bfs_tree")
    # woah bfs_tree allocates a lot of memory
    @time t = LightGraphs.bfs_tree(g, seed)
    println(t)
    # using a dict is much faster but still a non constant amount of allocation.
    @time t = LightGraphs.bfs_tree_dict(g, seed)
    # preallocating the output tree reduces the number of allocations.
    # much faster
    visitor = LightGraphs.TreeBFSVisitorVector(zeros(Int, nv(g)))
    @time t = LightGraphs.bfs_tree!(visitor, g, seed)
end
