# internal function that copies the end element to position n within an array
# and then pops the end element, effectively removing element n from the
# array.
function _swapnpop!(a::AbstractArray, n::Int)
    n > length(a) && throw(BoundsError())
    a[n] = a[end]
    pop!(a)
end
