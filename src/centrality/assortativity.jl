
"""
(degree) assortativity - undirected: 

see equation (4) in M. E. J. Newman: Assortative mixing in networks, Phys. Rev. Lett. 89, 208701 (2002), 
http://arxiv.org/abs/cond-mat/0205405/
"""
function assortativity_coefficient(g::Graph, sjk, sj, sk, sjs, sks, nue)
    return res = (sjk/nue - ((sj + sk)/(2*nue))^2)/((sjs + sks)/(2*nue) - ((sj + sk)/(2*nue))^2)
end

"""
(degree) assortativity - directed: 

see equation (21) in M. E. J. Newman: Mixing patterns in networks, Phys. Rev. E 67, 026126 (2003), 
http://arxiv.org/abs/cond-mat/0209450
"""
function assortativity_coefficient(g::DiGraph, sjk, ssj, sk, sjs, sks, nue)
    return res = (sjk - sj*sk/nue)/sqrt((sjs - sj^2/nue)*(sks - sk^2/nue))
end

"""
graph degree assortativity:

see equation (2) in M. E. J. Newman: Mixing patterns in networks, Phys. Rev. E 67, 026126 (2003), 
http://arxiv.org/abs/cond-mat/0209450
"""
function assortativity_degree(g)
    nue  = ne(g)
    sjk = 0
    sj  = 0
    sk  = 0
    sjs = 0
    sks = 0

    for (u,v) in edges(g)
        j   = outdegree(g,u) - 1;
        k   = indegree(g,v)  - 1;
        sjk += j*k
        sj  += j
        sk  += k
        sjs += j^2
        sks += k^2
    end

    res = assortativity_coefficient(g, sjk, sj, sk, sjs, sks, nue)

    return res
end


"""
local degree assortativity: 

see Piraveenan, M., M. Prokopenko, and A. Y. Zomaya. 
Local assortativeness in scale-free networks. 
EPL (Europhysics Letters) 84.2, 28002 (2008).
"""
function local_assortativity_degree(g::Graph)
    M = ne(g)

    mu = 0;
    for v in vertices(g)
        mu += (degree(g,v) - 1) * degree(g,v)/(2 * M)
    end

    si = 0
    for v in vertices(g)
        si += degree(g,v)/(2 * M) * ((degree(g,v) - 1) - mu)^2
    end

    lr = Float64[]

    for v in vertices(g)
        kb = mean([(degree(g,n) - 1) for n in neighbors(g,v)])
        a  = (degree(g,v) * (degree(g,v) - 1) * kb)/(2 * M)
        b  = (degree(g,v) * mu^2)/(2 * M)
        p  = (a - b)/si
        push!(lr,p)
    end

    return lr
end

function local_assortativity_degree(g::DiGraph)
    M = ne(g)

    mui = 0;
    for v in vertices(g)
        mui += indegree(g,v) * indegree(g,v)/(2 * M)
    end

    muo = 0;
    for v in vertices(g)
        muo += outdegree(g,v) * outdegree(g,v)/(2 * M)
    end

    sii = 0
    for v in vertices(g)
        sii += indegree(g,v)/(2 * M) * (indegree(g,v) - mui)^2
    end

    sio = 0
    for v in vertices(g)
        sio += outdegree(g,v)/(2 * M) * (outdegree(g,v) - muo)^2
    end

    lr    = Float64[]
    for v in vertices(g)
        kbi  = mean([indegree(g,n) for n in neighbors(g,v)])
        kbo  = mean([outdegree(g,n) for n in neighbors(g,v)])
        jout = outdegree(g,v)^2
        jin  = indegree(g,v)^2
        num  = jout * (kbi - mui) + jin * (kbo -  muo)
        den  = 2 * M * sqrt(sii) * sqrt(sio)
        push!(lr,num/den)
    end

    return lr
end

### graph assortativity with one mapping
function assortativity(g, cat)
    return assortativity(g, cat, cat)
end

""" categorical assortativity:
"""
function assortativity(g::SimpleGraph, cat1, cat2)
    nue  = ne(g)
    sjk = 0
    sj  = 0
    sk  = 0
    sjs = 0
    sks = 0

    for (u,v) in edges(g)
        j   = cat1[u]
        k   = cat2[v]
        sjk += j*k
        sj  += j
        sk  += k
        sjs += j^2
        sks += k^2
    end

    return  assortativity_coefficient(g, sjk, sj, sk, sjs, sks, nue)
end

function nominal_assortativity_coefficient(g::DiGraph, sumaibi, sumeii)
    return (sumeii - sumaibi) / (1.0 - sumaibi)
end

function nominal_assortativity_coefficient(g::Graph, sumaibi, sumeii)
    sumaibi /= 4.0
    sumeii  /= 2.0

    return (sumeii - sumaibi) / (1.0 - sumaibi)
end

""" nominal assortativity:
"""
function assortativity_nominal(g,cat)
    uc  = unique(values(cat))
    nue = ne(g)
    ai  = Dict()
    bi  = Dict()
    eii = Dict()
    sumaibi = 0
    sumeii  = 0

    for (u,v) in edges(g)
        ai[cat[u]]  = get(ai,cat[u],0) + 1
        bi[cat[v]]  = get(bi,cat[v],0) + 1
        cat[u] != cat[v] && continue
        eii[cat[u]] = get(eii,cat[u],0) + 1
    end
    for c in uc
        sumaibi += (ai[c]/nue) * (bi[c]/nue);
        sumeii  += try (eii[c]/nue) catch 0 end;
    end

    res = nominal_assortativity_coefficient(sumaibi, sumeii)
    return res
end
