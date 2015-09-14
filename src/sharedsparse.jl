type SharedSparseMatrixCSC{Tv,Ti<:Integer} <: AbstractSparseMatrix{Tv,Ti}
    m::Int
    n::Int
    colptr::SharedArray{Ti,1}
    rowval::SharedArray{Ti,1}
    nzval::SharedArray{Tv,1}
    pids::Vector{Int}
end
SharedSparseMatrixCSC(m,n,colptr,rowval,nzval;pids=workers()) = SharedSparseMatrixCSC(m,n,colptr,rowval,nzval,pids)
sdata(A::SharedSparseMatrixCSC) = SparseMatrixCSC(A.m,A.n,A.colptr.s,A.rowval.s,A.nzval.s)
display(A::SharedSparseMatrixCSC) = display(sdata(A))
size(A::SharedSparseMatrixCSC) = (A.m,A.n)
nfilled(A::SharedSparseMatrixCSC) = length(A.nzval)

function share{T,N}(a::AbstractArray{T, N};kwargs...)
    sh = SharedArray(T, size(a);kwargs...)
    for i=1:length(a)
        sh.s[i] = a[i]
    end
    return sh
end
share(A::SparseMatrixCSC,pids::AbstractVector{Int}) = SharedSparseMatrixCSC(A.m,A.n,share(A.colptr,pids=pids),share(A.rowval,pids=pids),share(A.nzval,pids=pids),pids)
share(A::SparseMatrixCSC) = share(A::SparseMatrixCSC,workers())
share(A::SharedSparseMatrixCSC,pids::AbstractVector{Int}) = (pids==A.pids ? A : share(sdata(A),pids))
share(A::SharedArray,pids::AbstractVector{Int}) = (pids==A.pids ? A : share(sdata(A),pids))
