"""
Computes the maximum multiroute flow (for any real number of routes)
between the source and target vertexes in a flow graph using the
[Extended Multiroute Flow algorithm](http://dx.doi.org/10.1016/j.disopt.2016.05.002).
If a number of routes is given, returns the value of the multiroute flow as
well as the final flow matrix, along with a multiroute cut if
Boykov-Kolmogorov max-flow algorithm is used as a subroutine.
Otherwise, it returns the vector of breaking points of the parametric
multiroute flow function.
Use a default capacity of 1 when the capacity matrix isn\'t specified.
Requires arguments:
- flow_graph::DiGraph                    # the input graph
- source::Int                            # the source vertex
- target::Int                            # the target vertex
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
- flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
- routes::Int                            # keyword argument for routes
"""

# EMRF (Extended Multiroute Flow) algorithms
function emrf{T<:AbstractFloat,R<:Number}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2},   # edge flow capacities
  flow_algorithm::AbstractFlowAlgorithm, # keyword argument for algorithm
  routes::R = 0
  )
  breakingpoints = breakingPoints(flow_graph,source,target,capacity_matrix)
  if routes > zero(R)
    x,f = intersection(breakingpoints,routes)
    return maximum_flow(flow_graph,source,target,capacity_matrix,
      algorithm=flow_algorithm,restriction=x)
  end
  return breakingpoints
end

"""
Output a set of (point,slope) that compose the restricted max-flow function.
One point by possible slope is enough (hence O(λ*max_flow) complexity).
Requires arguments:
- flow_graph::DiGraph                    # the input graph
- source::Int                            # the source vertex
- target::Int                            # the target vertex
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""

function auxiliaryPoints{T<:AbstractFloat}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2}    # edge flow capacities
  )
  # Problem descriptors
  λ = maximum_flow(flow_graph,source,target)[1] # Connectivity
  n = nv(flow_graph) # number of nodes
  r1, r2 = minmaxCapacity(capacity_matrix) # restriction left (1) and right (2)
  auxpoints = fill((0.,0.),λ+1)

  # Initialisation of left side (1)
  f1, F1, cut1 = maximum_flow(flow_graph,source,target,capacity_matrix,
                        algorithm=BoykovKolmogorovAlgorithm(),restriction=r1)
  s1 = slope(flow_graph,capacity_matrix,cut1,r1) # left slope
  auxpoints[λ + 1 - s1] = (r1,f1) # Add left initial auxiliary point

  # Initialisation of right side (2)
  f2, F2, cut2 = maximum_flow(flow_graph,source,target,capacity_matrix,
                        algorithm=BoykovKolmogorovAlgorithm(),restriction=r2)
  s2 = slope(flow_graph,capacity_matrix,cut2,r2) # right slope
  auxpoints[λ + 1 - s2] = (r2,f2) # Add right initial auxiliary point

  # Loop if the slopes are distinct by at least 2
  if s1 > s2 + 1
    queue = [((f1,s1,r1),(f2,s2,r2))]

    while !isempty(queue)
      # Computes an intersection (middle) with a new associated slope
      (f1,s1,r1),(f2,s2,r2) = pop!(queue)
      r, expectedflow = intersection(r1,f1,s1,r2,f2,s2)
      f, F, cut = maximum_flow(flow_graph,source,target,capacity_matrix,
                        algorithm=BoykovKolmogorovAlgorithm(),restriction=r)
      s = slope(flow_graph,capacity_matrix,max(cut,1),r) # current slope
      auxpoints[λ + 1 - s] = (r,f)
      # If the flow at the intersection (middle) is as expected
      if expectedflow ≈ f
        for k in (s1 - 1):(s2 + 1)
          auxpoints[λ + 1 - k] = (r, f) # add all points between left and right
        end
      else
        # if the slope difference between (middle) and left is at least 2
        # push (left),(middle)
        if s1 > s + 1 && (r2,f2) ≉ (r,f) # if the slope between intersection
          q = (f1,s1,r1),(f,s,r)
          push!(queue,q)
        end
        # if the slope difference between (middle) and right is at least 2
        # push (middle),(right)
        if s > s2 + 1 && (r1,f1) ≉ (r,f)
          q = (f,s,r),(f2,s2,r2)
          push!(queue,q)
        end
      end
    end
  end
  return auxpoints
end

"""
Calculates the breaking of the restricted max-flow from a set of auxiliary points.
Requires arguments:
- flow_graph::DiGraph                    # the input graph
- source::Int                            # the source vertex
- target::Int                            # the target vertex
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""

function breakingPoints{T<:AbstractFloat}(
  flow_graph::DiGraph,                   # the input graph
  source::Int,                           # the source vertex
  target::Int,                           # the target vertex
  capacity_matrix::AbstractArray{T,2}    # edge flow capacities
  )
  auxpoints = auxiliaryPoints(flow_graph,source,target,capacity_matrix)
  λ = length(auxpoints) - 1
  left_index = 1
  breakingpoints = Vector{Tuple{T,T,Int}}()

  for (id,point) in enumerate(auxpoints)
    if id == 1
      push!(breakingpoints,(0.,0.,λ))
    else
      pleft = breakingpoints[left_index]
      if point[1] != 0
        x, y = intersection(pleft[1],pleft[2],pleft[3],point[1],point[2], λ + 1 - id)
        push!(breakingpoints,(x, y, λ + 1 - id))
        left_index += 1
      else
        push!(breakingpoints,(-1.,-1.,λ + 1 - id))
      end
    end
  end
  return breakingpoints
end

"""
Function to get the nonzero min and max function of a Matrix
Requires argument:
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""

# Function to get the nonzero min and max function of a Matrix
function minmaxCapacity{T<:AbstractFloat}(capacity_matrix::AbstractArray{T,2})
  cmin, cmax = typemax(T), typemin(T)
  for c in capacity_matrix
    if c > zero(T)
      cmin = min(cmin,c)
    end
    cmax = max(cmax,c)
  end
  return cmin, cmax
end

"""
Function to get the slope of the restricted flow. The slope is initialized at 0
and is incremented for each non saturated edge in the restricted min-cut.
Requires argument:
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""
# Function to get the slope of the restricted flow
function slope{T<:AbstractFloat}(
  flow_graph::DiGraph,                   # the input graph
  capacity_matrix::AbstractArray{T,2},   # edge flow capacities
  cut::Vector{Int},                      # cut information for vertices
  restriction::T                         # value of the restriction
  )
  slope = 0
  for e in edges(flow_graph)
    if cut[dst(e)] - cut[src(e)] > 0 &&
      capacity_matrix[src(e),dst(e)] > restriction
        slope += 1
    end
  end
  return slope
end

"""
Computes the intersection bewtween:
1) Two lines
2) A set of segment and a linear function of slope k passing by the origin.
Requires argument:
1) - x1,y1,a1,x2,y2,a2::T<:AbstractFloat # Coordinates/slopes
2) - points::Vector{Tuple{T,T,Int}}      # vector of points with T<:AbstractFloat
   - k::R<:Number                        # number of route (slope of the line)
"""

# Compute the (expected) intersection of two lines
function intersection(x1,y1,a1,x2,y2,a2)
  b1 = y1 - a1 * x1
  b2 = y2 - a2 * x2
  x = (b2 - b1)/(a1 - a2)
  y = a1 * x + b1
  return (x,y)
end
# Compute the intection between a set of segment and a line of slope k passing by the origin
function intersection{T<:AbstractFloat,R<:Number}(
  points::Vector{Tuple{T,T,Int}},
  k::R
  )
  λ = length(points) - 1
  if k == λ
    return points[2]
  end
  for (id,p) in enumerate(points[2:end-1])
    x,y = intersection(p[1],p[2],p[3],0,0,k)
    if p[1] ≤ x ≤ points[id][1]
      return x,y
    end
  end
  p = points[end]
  return intersection(p[1],p[2],p[3],0,0,k)
end

"""
Redefinition of ≈ (isapprox) for a pair of Number
Requires argument:
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""
function ≈{T<:Number}(a::Tuple{T,T},b::Tuple{T,T})
  return a[1] ≈ b[1] && a[2] ≈ b[2]
end
