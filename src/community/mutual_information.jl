"normalised mutual information"
function mutual_information(pa::Vector{Int}, pb::Vector{Int}; normalized=false)
    length(pa) == length(pb) || error("Two partitions have different number of nodes !")
    n = length(pa)
    qa = maximum(pa) # group number of partition a
    qb = maximum(pb) # group number of partition b
    (qa==1 && qb==1) && return 0.0
    ga = zeros(Int, qa)
    gb = zeros(Int, qb)
    A = Array(Vector{Int}, qa)
    B = Array(Vector{Int}, qa)
    for i=1:qa
        A[i] = Vector{Int}()
        B[i] = Vector{Int}()
    end
    for i=1:n
        q = pa[i]
        t = pb[i]
        ga[q] += 1
        gb[t] += 1
        idx = 0
        for j=1:length(A[q])
            if A[q][j] == t
                idx = j
                break
            end
        end
        if idx == 0
            push!(A[q], t)
            push!(B[q], 1)
        else
            B[q][idx] += 1
        end
    end
    Ha = 0.0
    for q=1:qa
    	ga[q] == 0 && continue
        prob = ga[q]/n
        Ha += prob*log(prob)
    end
    Hb = 0.0
    for q=1:qb
        gb[q] == 0 && continue
        prob = gb[q]/n
        Hb += prob*log(prob)
    end
    Iab = 0.0
    for q=1:qa
        for idx=1:length(A[q])
            prob = B[q][idx]/n
            t = A[q][idx]
            Iab += prob*log(prob/(ga[q]/n*gb[t]/n))
        end
    end
    normalized ? -2.0*Iab/(Ha+Hb) : Iab
end