Chains MCMC chain (2000×21×4 Array{Float64, 3}):

Iterations        = 1001:1:3000
Number of chains  = 4
Samples per chain = 2000
Wall duration     = 32.55 seconds
Compute duration  = 62.67 seconds
parameters        = α, β[1], β[2], β[3], β[4], σ, τ, zⱼ[1], zⱼ[2]
internals         = lp, n_steps, is_accept, acceptance_rate, log_density, hamiltonian_energy, hamiltonian_energy_error, max_hamiltonian_energy_error, tree_depth, numerical_error, step_size, nom_step_size

Summary Statistics
  parameters       mean       std   naive_se      mcse         ess      rhat   ess_per_sec
      Symbol    Float64   Float64    Float64   Float64     Float64   Float64       Float64

           α    70.8868    3.6980     0.0413    0.1201    944.4853    1.0052       15.0713
        β[1]     3.1683    1.2649     0.0141    0.0277   1599.3589    1.0034       25.5211
        β[2]   -11.6644    1.2595     0.0141    0.0234   2311.3091    1.0028       36.8818
        β[3]     7.0896    1.2638     0.0141    0.0289   1824.2196    1.0026       29.1093
        β[4]     1.1516    1.2785     0.0143    0.0262   1210.2260    1.0041       19.3117
           σ     6.0035    0.2758     0.0031    0.0049   2900.7301    1.0017       46.2873
           τ     5.3971    3.0013     0.0336    0.1287    339.9252    1.0099        5.4242
       zⱼ[1]    -0.8373    0.7752     0.0087    0.0165   1754.7860    1.0000       28.0013
       zⱼ[2]     0.8637    0.7866     0.0088    0.0226   1167.2946    1.0059       18.6266

Quantiles
  parameters       2.5%      25.0%      50.0%      75.0%     97.5%
      Symbol    Float64    Float64    Float64    Float64   Float64

           α    63.1206    68.8006    70.8514    73.0677   78.9521
        β[1]     0.7887     2.2889     3.1632     4.0150    5.6652
        β[2]   -14.0890   -12.5424   -11.6937   -10.7988   -9.1833
        β[3]     4.6131     6.2141     7.1102     7.9595    9.5283
        β[4]    -1.3032     0.2904     1.1481     2.0148    3.6623
           σ     5.4889     5.8138     5.9893     6.1812    6.5681
           τ     1.9159     3.2325     4.5453     6.6889   13.4013
       zⱼ[1]    -2.4647    -1.3441    -0.7969    -0.3060    0.6232
       zⱼ[2]    -0.5411     0.2982     0.8235     1.3713    2.5196
