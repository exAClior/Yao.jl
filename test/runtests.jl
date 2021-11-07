using YaoToEinsum
using Test, OMEinsum, OMEinsumContractionOrders
using Yao

@testset "YaoToEinsum.jl" begin
    n = 5
    for c in [put(n, 2=>Y), put(n, (5,3)=>SWAP), put(n, (4,2)=>ConstGate.CNOT), put(n, (2,3,1)=>kron(ConstGate.CNOT, X)), put(n, 2=>Z), control(n, -3, 2=>X), control(n, 3, 2=>X), control(n, (2, -1), 3=>Y), control(n, (4,1,-2), 5=>Z)]
        @show c
        #C = chain([put(n, i=>Rx(rand()*2π)) for i=1:n]..., c)
        C = chain(c)
        code, xs = yao2einsum(C)
        optcode = optimize_code(code, uniformsize(code, 2), GreedyMethod())
        @test reshape(optcode(xs...; size_info=uniformsize(code, 2)), 1<<n, 1<<n) ≈ mat(C)
    end
end
