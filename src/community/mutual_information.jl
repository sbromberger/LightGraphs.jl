function entropy(membership::Vector{Int})
    n = length(membership)
    nb_comms = maximum(membership)
    groups = Array(Set{Int}, nb_comms)
    for i=1:nb_comms
        groups[i] = Set{Int}()
    end
    for i=1:n
        push!(groups[membership[i]], i)
    end
    h = 0.0
    for grp in groups
        n_c = length(grp)
        h += -(n_c/n)log(n_c/n)
    end
    h
end

function mutual_information(m1::Vector{Int}, m2::Vector{Int})
    length(m1) == length(m2) || error("membership must be equal length")
    n = length(m1)

    groups1 = Dict{Int, Set{Int}}()
    groups2 = Dict{Int, Set{Int}}()

    for i=1:n
        comm1 = m1[i]
        comm2 = m2[i]
        if haskey(groups1, comm1)
            push!(groups1[comm1], i)
        else
            groups1[comm1] = Set(i)
        end
        if haskey(groups2, comm2)
            push!(groups2[comm2], i)
        else
            groups2[comm2] = Set(i)
        end
    end

    I = 0.0
    for grp1 in values(groups1)
        for grp2 in values(groups2)
            n_1 = length(grp1)
            n_2 = length(grp2)
            n_12 = length(intersect(grp1, grp2))
            if n_12 > 0
                I += (n_12/n)*log(n * n_12 / (n_1 * n_2) )
            end
        end
    end
    I
end

"normalised mutual information"
function nmi(m1::Vector{Int}, m2::Vector{Int})
    2*mutual_information(m1, m2)/(entropy(m1)+entropy(m2))
end

function variation_of_information(m1::Vector{Int}, m2::Vector{Int})
    entropy(m1)+entropy(m2)-2*mutual_information(m1,m2)
end

"normalised variation of information"
function nvi(m1::Vector{Int}, m2::Vector{Int})
    variation_of_information(m1,m2)/log(length(m1))
end