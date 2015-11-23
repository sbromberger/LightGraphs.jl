"normalised mutual information"
function nmi(pa::Vector{Int}, pb::Vector{Int})
    length(pa) == length(pb) || error("Two partitions have different number of nodes !")
    n = length(pa)
    qa = maximum(pa)
    qb = maximum(pb)
    if qa==1 && qb==1
        return 0.0
    end
    ga = zeros(Int, qa)
    gb = zeros(Int, qb)
    A = Array(Vector{Int}, qa)
    B = Array(Vector{Int}, qa)
    for i=1:qa
        A[i] = Int[]
        B[i] = Int[]
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
        if ga[q] == 0
            continue
        end
        prob = ga[q]/n
        Ha += prob*log(prob)
    end
    Hb = 0.0
    for q=1:qb
        if gb[q] == 0
            continue
        end
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
    -2.0*Iab/(Ha+Hb)
end

"normalised variation of information"
function nvoi(pa::Vector{Int}, pb::Vector{Int})
    length(pa) == length(pb) || error("Two partitions have different number of nodes !")
    n = length(pa)
    qa = maximum(pa)
    qb = maximum(pb)
    if qa==1 && qb==1
        return 0.0
    end
    ga = zeros(Int, qa)
    gb = zeros(Int, qb)
    A = Array(Vector{Int}, qa)
    B = Array(Vector{Int}, qa)
    for i=1:qa
        A[i] = Int[]
        B[i] = Int[]
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
        if ga[q] == 0
            continue
        end
        prob = ga[q]/n
        Ha += prob*log(prob)
    end
    Hb = 0.0
    for q=1:qb
        if gb[q] == 0
            continue
        end
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
	-(Ha + Hb - 2Iab)/log(length(pa))
end

"normalised mutual information and normalised variation of information"
function nminvoi(pa::Vector{Int}, pb::Vector{Int})
    length(pa) == length(pb) || error("Two partitions have different number of nodes !")
    n = length(pa)
    qa = maximum(pa)
    qb = maximum(pb)
    if qa==1 && qb==1
        return 0.0
    end
    ga = zeros(Int, qa)
    gb = zeros(Int, qb)
    A = Array(Vector{Int}, qa)
    B = Array(Vector{Int}, qa)
    for i=1:qa
        A[i] = Int[]
        B[i] = Int[]
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
        if ga[q] == 0
            continue
        end
        prob = ga[q]/n
        Ha += prob*log(prob)
    end
    Hb = 0.0
    for q=1:qb
        if gb[q] == 0
            continue
        end
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
	-2.0*Iab/(Ha+Hb), -(Ha + Hb - 2Iab)/log(length(pa))
end

"relative normalised mutual information"
function rnmi(pa::Vector{Int}, pb::Vector{Int})
    length(pa) == length(pb) || error("Two partitions have different number of nodes !")
    n = length(pa)
    qa = maximum(pa)
    qb = maximum(pb)
    if qa==1 && qb==1
        return 0.0
    end
    ga = zeros(Int, qa)
    gb = zeros(Int, qb)
    A = Array(Vector{Int}, qa)
    B = Array(Vector{Int}, qa)
    for i=1:qa
        A[i] = Int[]
        B[i] = Int[]
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
        if ga[q] == 0
            continue
        end
        prob = ga[q]/n
        Ha += prob*log(prob)
    end
    Ha *= -1
    Hb = 0.0
    for q=1:qb
        if gb[q] == 0
            continue
        end
        prob = gb[q]/n
        Hb += prob*log(prob)
    end
    Hb *= -1
    Iab = 0.0
    for q=1:qa
        for idx=1:length(A[q])
            prob = B[q][idx]/n
            Iab += prob*log(prob)
        end
    end
    Iab *= -1
    Iab = Ha + Hb - Iab
    corr = (qa*qb-qa-qb+1.0)/2n
    2.0*(Iab-corr)/(Ha+Hb)
end

function rnmi(p1::Vector{Int}, p2::Vector{Int}, N::Int)
    pa = copy(p1)
    pb = copy(p2)
    agtb = length(pa) > length(pb)
    the_nmi = compute_nmi(pa, pb)
    tot_nmi = 0.0
    for i=1:N
        nmi = 0.0
        if agtb
            shuffle!(pb)
            nmi = compute_nmi(pa, pb)
        else
            shuffle!(pa)
            nmi = compute_nmi(pb, pa)
        end
        tot_nmi += nmi
    end
    tot_nmi /= N
    the_nmi - tot_nmi
end