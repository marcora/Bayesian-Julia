# # How to use Turing

# [**Turing**](http://turing.ml/) is a ecosystem of Julia packages for Bayesian Inference using
# [probabilistic programming](https://en.wikipedia.org/wiki/Probabilistic_programming).
# Turing provide an easy an intuitive way of specifying models.

# ## Probabilistic Programming

# What is a **probabilistic programming** (PP)? It is a **programming paradigm** in which probabilistic models
# are specified and inference for these models is performed **automatically** (Hardesty, 2015). In more clear terms,
# PP and PP Languages (PPLs) allows us to specify **variables as random variables** (like Normal, Binominal etc.) with
# **known or unknown parameters**. Then, we **construct a model** using these variables by specifying how the variables
#  related to each other, and finally **automatic inference of the variables' unknown parameters** is then performed.

# In a Bayesian approach this means specifying **priors**, **likelihoods** and let the PPL compute the **posterior**.
# Since the denominator in the posterior is often intractable, we use Markov Chain Monte Carlo[^MCMC] and some fancy
# algorithm that uses the posterior geometry to guide the MCMC proposal using Hamiltonian dynamics called
# Hamiltonian Monte Carlo (HMC) to approximate the posterior. This involves, besides a suitable PPL, automatic differentiation,
# MCMC chains interface, and also an efficient HMC algorithm implementation. In order to provide all of these features,
# Turing has a whole ecosystem to address each and everyone of these components.

# ## Turing's Ecosystem

# Before we dive into how to specify models in Turing. Let's discuss Turing's ecosystem.
# We have several Julia packages under the Turing's GitHub organization [TuringLang](https://github.com/TuringLang),
# but I will focus on 5 of those:

# * [`Turing.jl`](https://github.com/TuringLang/Turing.jl)
# * [`MCMCChains.jl`](https://github.com/TuringLang/MCMCChains.jl)
# * [`DynamicPPL.jl`](https://github.com/TuringLang/DynamicPPL.jl)
# * [`AdvancedHMC.jl`](https://github.com/TuringLang/AdvancedHMC.jl)
# * [`DistributionsAD.jl`](https://github.com/TuringLang/DistributionsAD.jl)

# The first one is [`Turing.jl`](https://github.com/TuringLang/Turing.jl) itself, the main package that we use to
# **interface with all the Turing ecosystem** of packages and the backbone of the PPL Turing.

# The second, [`MCMCChains.jl`](https://github.com/TuringLang/MCMCChains.jl), is an interface to summarizing MCMC
# simulations and has several utility functions for diagnostics and visualizations.

# The third package is [`DynamicPPL.jl`](https://github.com/TuringLang/DynamicPPL.jl) (Tarek, Xu, Trapp, Ge & Ghahramani, 2020)
# which specifies a domain-specific language and backend for Turing (which itself is a PPL). The main feature of `DynamicPPL.jl`
# is that is is entirely written in Julia and also it is modular.

# [`AdvancedHMC.jl`](https://github.com/TuringLang/AdvancedHMC.jl) provides a robust, modular and efficient implementation
# of advanced HMC algorithms. The state-of-the-art HMC algorithm is the **N**o-**U**-**T**urn **S**ampling
# (NUTS)[^MCMC] (Hoffman & Gelman, 2011) which is available in `AdvancedHMC.jl`.

# Finally, [`DistributionsAD.jl`](https://github.com/TuringLang/DistributionsAD.jl) defines the necessary functions to enable
# automatic differentiation (AD) of the `logpdf` function from [`Distributions.jl`](https://github.com/JuliaStats/Distributions.jl)
# using the packages [`Tracker.jl`](https://github.com/FluxML/Tracker.jl), [`Zygote.jl`](https://github.com/FluxML/Zygote.jl),
# [`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl) and [`ReverseDiff.jl`](https://github.com/JuliaDiff/ReverseDiff.jl).
# The main goal of `DistributionsAD.jl` is to make the output of `logpdf` differentiable with respect to all continuous parameters
# of a distribution as well as the random variable in the case of continuous distributions. This is the package that guarantees the
# "automatical inference" part of the definition of a PPL.

# Most of the time we will not be dealing with neither of these packages directly, since `Turing.jl` will take care of the interfacing
# for us. So let's talk about `Turing.jl`.

# ## `Turing.jl`

# `Turing.jl` is the main package in the Turing ecosystem and the backbone that glues all the other packages together.
# Turing's "workflow" begin with a model specification. We specify the model inside a macro `@model` where we can assign variables
# in two ways:

# * using `~`: which means that a variable follows some probability distribution (Normal, Binomial etc.) and its value is random under that distribution
# * using `=`: which means that a variable does not follow a probability distribution and its value is deterministic (like the normal `=` assignment in programming languages)

# Turing will perform automatic inference on all variables that you specify using `~`.
# Here is a simple example of how we would model a 6-sided dice. Note that a "fair" dice will be distributed as a discrete uniform
# probability with the lower bound as 1 and the upper bound as 6:

# $$ X \sim \text{Uniform}(1,6) \label{uniformdice} $$

# Note that the expectation of a random variable $X \sim \text{Uniform}(a,b)$ is:

# $$ E(X) = \frac{a+b}{2} = \frac{7}{2} = 3.5 \label{expectationdice} $$

# Graphically this means:

using Plots, StatsPlots, Distributions, LaTeXStrings

dice = DiscreteUniform(1, 6)
plot(dice,
    label="6-sided Dice",
    ms=5,
    xlabel=L"\theta",
    ylabel="Mass",
    ylims=(0, 0.3)
)
vline!([mean(dice)], lw=5, col=:red, label=L"E(\theta)")
savefig(joinpath(@OUTPUT, "dice.svg")); # hide

# \fig{dice}
# \center{*A "fair" 6-sided Dice: Discrete Uniform between 1 and 6*} \\

# So let's specify our first Turing model. It will be named `dice_throw` and will have a single parameter `y`
# which is a N-dimensional vector of integers representing the observed data, *i.e.* the outcomes of $N$ 6-sided dice throws:

using Turing

@model dice_throw(y) = begin
    #Our prior belief about the probability of each result in a 6-sided dice.
    #p is a vector of length 6 each with probability p that sums up to 1.
    p ~ Dirichlet(6, 1)

    #Each outcome of the 6-sided dice has a probability p.
    y .~ Categorical(p)
end;

# Here we are using the [Dirichlet distribution](https://en.wikipedia.org/wiki/Dirichlet_distribution) which
# is the multivariate generalization of the [Beta distribution](https://en.wikipedia.org/wiki/Beta_distribution).
# The Dirichlet distribution is often used as the conjugate prior for Categorical or Multinomial distributions. Since our dice
# is modelled as a [Categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution)
# with 6 possible results $y \in \{ 1, 2, 3, 4, 5, 6 \}$ with some probability vector
# $\mathbf{p} = (p_1, \dots, p_6)$. Since all outcomes must sum up to 1 to be a valid probability, we impose the constraint that
# all $p$s must sum up to 1 $\sum^n_{i=1} p_i = 1$. We could use a  vector o 6 Beta distributions but it would be hard and
# inefficient to enforce this constraint. Instead, I've opted for a Dirichlet with a weekly informative prior towards a
# "fair" dice which is encoded as a `Dirichlet(6,1)`. This is translated as a 6-dimensional vector of elements that sum to 1:

mean(Dirichlet(6, 1))

# Also, since the outcome of a [Categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution) is an integer
# and `y` is a 1,000-dimensional vector of integers we need to apply some sort of broadcasting here. This is
# done by adding the familiar dot `.` broadcasting operator in Julia: `y .~ Categorical` this means that all elements of `y` are
# distributed as a Categorical distribution.

# Now let's set a seed for the pseudo-random number generator and simulate 1,000 throws of a 6-sided dice:

using Random

Random.seed!(123)

data = rand(dice, 1_000); # remember dice = DiscreteUniform(1, 6)

# The vector `data` is a 1,000-length vector of `Int`s ranging from 1 to 6, like a regular 6-sided dice outcome would be:

first(data, 5)

# Once the model is specified we instantiate the model with the single parameter `y` as the simulated `data`:

model = dice_throw(data);

# and apply to it the Turing's `sample()` function that takes a Turing model as a first argument, along with a
# sampler as the second argument, and the third argument is the number of iterations. Here, I will use the `NUTS()` sampler from
# `AdvancedHMC.jl` and 2,000 iterations. Please note that as default Turing samplers will discard the first half of iterations as
# warmup. So the sampler will output 1,000 samples (`floor(2_000 / 2)`):

chain = sample(model, NUTS(), 2_000);

# Now let's inspect the chain. We can do that with the function `describe()` that will return a 2-element vector of
# `ChainDataFrame` (this is the type defined by `MCMCChains.jl` to store Markov chain's information regarding the inferred
# parameters). The first `ChainDataFrame` has information regarding the parameters' summary statistics (mean, std, r_hat, ...)
# and the second is the parameters' quantiles. Since `describe(chain)` returns a 2-element vector, I will output it to two variables:

summaries, quantiles = describe(chain);

# We won't be focusing on quantiles, so let's put it aside for now. Let's then take a look at the parameters' summary statistics:

summaries

# Here `p` is a 6-dimensional vector of probabilities, which each one associated with a mutually exclusive outcome of a 6-sided
# dice throw. As we expected, the probabilities are almost equal to $\frac{1}{6}$, like a "fair" 6-sided dice that we simulated
# data from (sampling from `DiscreteUniform(1, 6)`). Indeed, just for a sanity check, the mean of the estimates of `p` sums up to 1:

sum(summaries[:, :mean])

# And, finally let's compute the $E(\widetilde{X})$ using the standard expectation definition for a discrete random variable:

# $$ E(X) = \sum_{x \in X} x \cdot P(x) $$

sum([idx * i for (i, idx) in enumerate(summaries[:, :mean])])

# Bingo! The estimated expectation is very close to the theoretical expectation of $\frac{7}{2} = 3.5$ as we've show
# in \eqref{expectationdice}.

# ## Conlusion

# This is the basic overview of Turing usage. You see how simple and intuitive is to specify probabilistic models using Turing?!

# ## Footnotes
#
# [^MCMC]: see [5. **Markov Chain Monte Carlo (MCMC)**](/pages/5_MCMC/).

# ## References

# Ge, H., Xu, K., & Ghahramani, Z. (2018). Turing: A Language for Flexible Probabilistic Inference. International Conference on Artificial Intelligence and Statistics, 1682–1690. http://proceedings.mlr.press/v84/ge18b.html
#
# Hardesty (2015).  "Probabilistic programming does in 50 lines of code what used to take thousands". phys.org. April 13, 2015. Retrieved April 13, 2015. https://phys.org/news/2015-04-probabilistic-lines-code-thousands.html
#
# Hoffman, M. D., & Gelman, A. (2011). The No-U-Turn Sampler: Adaptively Setting Path Lengths in Hamiltonian Monte Carlo. Journal of Machine Learning Research, 15(1), 1593–1623. Retrieved from http://arxiv.org/abs/1111.4246
#
# Tarek, M., Xu, K., Trapp, M., Ge, H., & Ghahramani, Z. (2020). DynamicPPL: Stan-like Speed for Dynamic Probabilistic Models. ArXiv:2002.02702 [Cs, Stat]. http://arxiv.org/abs/2002.02702
