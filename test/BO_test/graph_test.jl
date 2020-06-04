
G = [0 1 0 0 1 0 ;
         1 0 1 0 1 0 ;
         0 1 0 1 0 0 ;
         0 0 1 0 1 1 ;
         1 1 0 1 0 0 ;
         0 0 0 1 0 0 ;
        ]

L = [2 -1 0 0 -1 0;
        -1 3 -1 0 -1 0 ;
        0 -1 2 -1 0 0;
        0 0 -1 3 -1 -1;
        -1 -1 0 -1 3 0;
        0 0 0 -1 0 1]


D = Diagonal([2,3,2,3,3,1])

L_norm = (D^-0.5)*L*(D^-0.5)

@testset "graphs" begin
        @test degree(G) == D
        @test laplacian(G) == L
        @test norm_laplacian(G) ≈ L_norm
end
