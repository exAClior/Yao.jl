export CompositeBlock

"""
    CompositeBlock{N, T} <: MatrixBlock{N, T}

Abstract supertype which composite blocks will inherit from. Composite blocks
are blocks composited from other [`MatrixBlock`](@ref)s, thus it is a `MatrixBlock`
as well.
"""
abstract type CompositeBlock{N, T} <: MatrixBlock{N, T} end

"""
    AbstractContainer{N, T} <: CompositeBlock{N, T}

Abstract type for container block. Container blocks are blocks contain a single
block.
"""
abstract type AbstractContainer{N, T} <: CompositeBlock{N, T} end

"""
    block(x::AbstractContainer)

Return the contained block.
"""
block(x::AbstractContainer) = x.block

# NOTE: this is a holy trait, no overhead, don't use methods on this
abstract type PreserveStyle end
struct PreserveAll <: PreserveStyle end
struct PreserveProperty{F} <: PreserveStyle end
struct PreserveNothing <: PreserveStyle end

PreserveStyle(c::AbstractContainer) = PreserveNothing()

for METHOD in (:ishermitian, :isreflexive, :isunitary)
    @eval begin
        # forward to trait
        $METHOD(c::AbstractContainer) = $METHOD(PreserveStyle(x), c)
        # forward contained block property
        $METHOD(::PreserveAll, c::AbstractContainer) = $METHOD(block(c))
        # forward to default property by calculating the matrix
        $METHOD(::PreserveNothing, c::AbstractContainer) = $METHOD(mat(c))
    end
end

include("chain.jl")
include("kron.jl")
include("control.jl")
