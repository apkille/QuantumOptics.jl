module quantumbases

export Basis, GenericBasis, FockBasis, CompositeBasis, compose, multiplicable

abstract Basis

type GenericBasis <: Basis
    shape::Vector{Int}
end

type CompositeBasis <: Basis
    shape::Vector{Int}
    bases::Vector{Basis}
end

type FockBasis <: Basis
    shape::Vector{Int} 
    N0::Int
    N1::Int
    FockBasis(N0::Int, N1::Int) = N0 <= N1 ? new([N1-N0+1], N0, N1) : throw(DimensionError())
end

FockBasis(N::Int) = FockBasis(1,N)


compose(b1::Basis, b2::Basis) = CompositeBasis([prod(b1.shape), prod(b2.shape)], [b1, b2])
compose(b1::CompositeBasis, b2::CompositeBasis) = CompositeBasis([b1.shape, b2.shape], [b1.bases, b2.bases])
compose(b1::CompositeBasis, b2::Basis) = CompositeBasis([b1.shape, prod(b2.shape)], [b1.bases, b2])
compose(b1::Basis, b2::CompositeBasis) = CompositeBasis([prod(b1.shape), b2.shape], [b1, b2.bases])

Base.length(b::Basis) = prod(b.shape)

function equal_shape(a::Vector{Int64}, b::Vector{Int64})
    if a === b
        return true
    end
    if length(a) != length(b)
        return false
    end
    for i=1:length(a)
        if a[i]!=b[i]
            return false
        end
    end
    return true
end

function equal_bases(a::Vector{Basis}, b::Vector{Basis})
    if a===b
        return true
    end
    for i=1:length(a.shape)
        if a[i]!=b[i]
            return false
        end
    end
    return true
end

==(b1::Basis, b2::Basis) = false
==(b1::GenericBasis, b2::GenericBasis) = equal_shape(b1.shape,b2.shape)
==(b1::CompositeBasis, b2::CompositeBasis) = equal_shape(b1.shape,b2.shape) && equal_bases(b1.bases,b2.bases)
==(b1::FockBasis, b2::FockBasis) = b1.N0==b2.N0 && b1.N1==b2.N1

multiplicable(b1::Basis, b2::Basis) = b1==b2
function multiplicable(b1::CompositeBasis, b2::CompositeBasis)
    if !equal_shape(b1.shape,b2.shape)
        return false
    end
    for i=1:length(b1.shape)
        if !multiplicable(b1.bases[i], b2.bases[i])
            return false
        end
    end
    return true
end

end