# Bayesian optimisation

The BO pipeline proposed in the BOMoD package focuses specifically on real-world modular design optimisation problems.
There are two significant differences compared to the classical Bayesian optimisation setup:

1) The input is discrete and is represented as a string of characters, containing no numerical information.
2) In wet-lab experiments, it is beneficial to analyse multiple data points simultaneously. This requires the need of a batch sampling algorithm instead of a sequential one.

The BOMoD pipeline can be divided into three stages:

1) First sampling step
2) Surrogate model
3) Batch sampling step


Every step will be discussed, and examples will be given.
All examples start from a previous constructed design space.


````julia
julia> using BOMoD

julia> using BOMoD: sample

julia>
l = 3;
3

julia> order = true;
true

julia> m = groupmod(["a", "b", "c", "d"]);
{GroupMod}{"a", "b", "c", "d"}

julia> design = constructdesign(m,l , order=order);
Used modules : {GroupMod}{"a", "b", "c", "d"}
allowed length : 3
constraints : BOMoD.NoConstraint{Nothing}(nothing)
	 	 designspace
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 64

julia> full_space = getspace(design);
 spacetype | BOMoD.FullOrderedSpace{BOMoD.Mod{String}}
 generated constructs | BOMoD.OrderedConstruct{BOMoD.Mod{String}}
 n_consturcts | 64

````





## First sampling step

The first step of the BOMoD pipeline is sampling the first $n$ data points, which are used to fit the surrogate model of stage two.
In the current version of the package, only a  algorithm that samples uniformly at random is available.


````julia
julia> # sample three random data points
n = 3
3

julia> first_sample = sample(full_space,n)
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "d", "a"]
 {OrderedConstruct}["d", "c", "a"]
 {OrderedConstruct}["d", "d", "b"]

````





### Surrogate model

In the package, GPs are used as surrogate models.
Other packages are integrated to handle different steps in the model procedure:
The [Stheno package](https://github.com/willtebbutt/Stheno.jl) was used to fit the GP models efficiently.
The package was chosen over other GP packages because custom made kernels can be easily integrated.
The [StringDistances package](https://github.com/matthieugomez/StringDistances.j) is used to calculate string distances between different constructs.
The obtained distances are used in the custom kernels, to fit nicely in the Stheno framework .
The [Optim package](https://github.com/JuliaNLSolvers/Optim.jl) is the package used for hyperparameter optimisation of the GP models.


The BOMoD package is designed to be simple and straightforward in its use.
The well-known fit- and predict workflow was implemented for the GP models.
The package provides a way to combine different functionalities of the above-mentioned packages.
As a consequence of the easy-to-use philosophy, it is impossible to integrate the full capacity of the given packages.
The current version of the BOMoD focuses on the integration of some case-specific functions.
This section will first cover how a GP model can be fitted using BOMoD, and afterwards, the prediction for new test data is covered.

#### The fit_gp function
There is one function `fit_gp` that fits the entire GP model. The term "fit" indicates that the model is conditioned on the given training data and the posterior distribution is obtained.
It requires multiple input arguments; some are trivial, others need some additional explanation.

**arg**: x\_train, y\_train, k::Kernel,mod::GroupMod

**kwarg**: ``\theta =[1]``, $\sigma^2_n = 10^{-6}$, optimise=false

##### x\_train and y\_train`

`x_train` is a vector containing all constructs that have been evaluated.
This means that every construct has a corresponding activity stored in the `y_train` vector.
A construct is represented as a vector of strings, which is obtained from a previous sampling step.
No additional transformation of the data is required. The model ensures that for all used functions the proper datatype is given as input.
It is advised to store both vectors, `x_train` and `y_train`, in a dataframe, using the DataFrames package \footnote{\url{https://github.com/JuliaData/DataFrames.jl``. This allows for a well-organised data flow between different iterations of the model.
Additionally, a dataframe can be exported to a CSV file for long-term storage.

````julia
julia> using DataFrames

julia> # sample some random x_train samples
x_train = sample(full_space,3);
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["b", "d", "d"]
 {OrderedConstruct}["c", "a", "c"]
 {OrderedConstruct}["a", "a", "b"]

julia> # sample some random activity values
y_train = randn(length(x_train));
3-element Array{Float64,1}:
 0.355016080112298
 0.17486131913864977
 0.4317700578229935

julia> # Store the both in a dataframe
df = DataFrame(x_train=x_train ,y_train=y_train);
3×2 DataFrames.DataFrame
│ Row │ x_train                           │ y_train  │
│     │ BOMoD.OrderedConstruct…           │ Float64  │
├─────┼───────────────────────────────────┼──────────┤
│ 1   │ {OrderedConstruct}["b", "d", "d"] │ 0.355016 │
│ 2   │ {OrderedConstruct}["c", "a", "c"] │ 0.174861 │
│ 3   │ {OrderedConstruct}["a", "a", "b"] │ 0.43177  │

````






##### k::Kernel

The kernel that is used has a substantial effect on the prediction capacity of the model. It tries to find structure among the different training data points. Depending on the problem, different kernels are preferred.
Various kernels are implemented in the package. All of them were developed to deal with the specific modular design input, a vector containing a vector of strings.
The general idea of the BOMoD package is to keep everything as simple as possible. Every kernel has received its custom type.
The `Kernel` abstract type of Stheno was reexported, and all custom kernels were brought under this abstract type, which is mandatory to fit a GP in the Stheno ecosystem.
Different kernel options are implemented and discussed below:

a) Transformation to a vector embedding.

The first kernel type transforms the string vector in a numbered vector using a bag-of-words algorithm.
These vectors can be used in the standard kernels implemented in Stheno.
The package has been tested using the linear kernel of the Stheno package.
However, this approach should make all Stheno base-kernels available.
The linear kernel can be used with given structure:

````julia
julia> k = Linear();
Stheno.Linear()

````





b) Edit distances kernel

The `EditDistancesKernel` is a custom kernel type for kernels based on the edit distance between all input vectors.
The StringDistances package is used to calculate the edit distance.
In the current version of the package, only the Levenshtein distance has been tested.
The calculated Levenshtein distance between $\mathbf{x}_i$ and $\mathbf{x}_j$ is transformed in a kernel using:

```math
K(\mathbf{x}_i,\mathbf{x}_j) = e^{\text{lev}| \mathbf{x}_i,\mathbf{x}_j|}
```
The kernel is designed to work with all other edit distances available in the StringDistances package. This is still in an experimental phase and errors could occur.
In the general case, `EditDistancesKernel` takes one argument: the chosen edit distance.

````julia
julia> using StringDistances

julia> k = EditDistancesKernel(Levenshtein());
BOMoD.EditDistancesKernel{StringDistances.Levenshtein}(StringDistances.Levenshtein())

````


It should be noted that the edit distance takes the relative position of different combinations into account as illustrated in the given example:
````julia
julia> using StringDistances

julia> example1 = [:a, :b, :c];
3-element Array{Symbol,1}:
 :a
 :b
 :c

julia> example2 = [:a, :c, :b];
3-element Array{Symbol,1}:
 :a
 :c
 :b

julia> example3 = [:a, :c, :d];
3-element Array{Symbol,1}:
 :a
 :c
 :d

julia>
# The Levenshteinkernel of two identical constructs is 1)
identical = -evaluate(Levenshtein(),example1,example1) |> exp
1.0

julia>
#The Levenshtein of two constructs with only a position shift is exp(2)
shift = -evaluate(Levenshtein(),example1,example2) |> exp
0.1353352832366127

julia>
#The Levenshtein of two constructs with shift and change is again exp(2)
change = -evaluate(Levenshtein(),example1,example3) |> exp
0.1353352832366127

````






As a consequence, this kernel is suited to deal with `OrderedConstruct` combinations.

c) q-gram kernel

The `QGramKernel` uses q-gram similarities between constructs to obtain a useful kernel.
q-gram similarities between two constructs are calculated based on the presence of mutual sub-strings, independent of their specific position.
The "q" value refers to the length of the sub-string that is evaluated.
In the given setup of the package, only the cosine similarity with q = 1 is used.

To calculate the cosine similarities, the StringDistances package is used. This function internally handles the bag-of-words transformation and the constructs can be used as input.
The obtained distances are transformed into the corresponding kernel by:

```math
k(\mathbf{x}_i,\mathbf{x}_j)= 1 - \text{cosine}|\mathbf{x}_i,\mathbf{x}_j|
```
where $\mathbf{x}_i$, $\mathbf{x}_j$ are two constructs.
The StringDistances package provides a range of q-gram distances, all can be transformed into a similarity value. The cosine distance with q = 1 is the only q-gram distance that was tested.
Again the other q-gram distances available in the StringDistances package can be used, but this is still in an experimental phase, and errors could occur.

````julia
julia> k = QGramKernel(StringDistances.Cosine(1))
BOMoD.QGramKernel{StringDistances.Cosine}(StringDistances.Cosine(1))

````





The cosine similarity counts the occurrence of every module, as a result all position information is lost.
This is a large difference compared to the Levenshtein distance. This is illustrated with the same example as used in the case of the Levenshtein distance.

````julia
julia> using StringDistances

julia> example1 = [:a, :b, :c];
3-element Array{Symbol,1}:
 :a
 :b
 :c

julia> example2 = [:a, :c, :b];
3-element Array{Symbol,1}:
 :a
 :c
 :b

julia> example3 = [:a, :c, :d];
3-element Array{Symbol,1}:
 :a
 :c
 :d

julia>
# "The Cosine similarity of two identical constructs is 1
identical = 1 - evaluate(StringDistances.Cosine(1),example1,example1) |> x ->  round(x,digits = 3)
1.0

julia>
# "The Cosine similarity constructs with only a position shift is 1
twisted  = 1 - evaluate(StringDistances.Cosine(1),example1,example2) |>  x ->  round(x,digits = 3)
1.0

julia>
#"The Cosine similarity constructs with only a position shift and change is again 0.667
change = 1 - evaluate(StringDistances.Cosine(1),example1,example3) |>  x -> round(x,digits = 3)
0.667

````






As a consequence, this kernel is suited to deal with `UnorderedConstruct` types and can be used for `OrderedConstruct` types depending on the given problem.

d) Composed Kernels

Multiplication or concatenation of different kernels result in newly composed kernels.
In BOMoD, the main focus is on combining the `QGramKernel` and `EditDistancesKernel`.
As seen in the examples above, both discover different patterns in the same constructs. If they are used together, the strengths of both kernels are combined.

An example of a composed kernel is:
````julia
julia> k = EditDistancesKernel(Levenshtein()) + QGramKernel(StringDistances.Cosine(1));
Stheno.Sum{BOMoD.EditDistancesKernel{StringDistances.Levenshtein},BOMoD.QGramKernel{StringDistances.Cosine}}(BOMoD.EditDistancesKernel{StringDistances.Levenshtein}(StringDistances.Levenshtein()), BOMoD.QGramKernel{StringDistances.Cosine}(StringDistances.Cosine(1)))

````





Unfortunately, the current implementation of the linear kernel in Stheno requires a unique input structure. This makes it not possible to combine it with the other given string kernels.

##### mod::GroupMod

The `mod` argument contains the input modules, and they are used to transform the data into a vector embedding, if needed.

````julia
julia> m = groupmod(["a", "b", "c", "d"]);
{GroupMod}{"a", "b", "c", "d"}

````




Above, the four mandatory arguments to fit a GP model were discussed.
The other arguments are optional keyword arguments with a given default value. Still, these parameters can have a significant effect on the performance of the model.

##### θ (default = [1])

The $\theta$ vector contains the hyperparameter of the GP model.
Only one hyperparameter is used for all different kernels to reduce the complexity of the models.
In all cases, this is the scaling parameter $\alpha$ of the GP model.
```math
y = \alpha * GP
```
Still, it is important that the parameter is given as a vector.
The $\theta $ vector is ignored if `optimise=true`


#### $\sigma^2_n$ (default = [$10^{-6}$])

``\sigma^2_n`` is the noise parameter of the GP model. The Stheno model requires a low noise factor for numerical stability.
The noise factor can have two different inputs:

1) One single noise factor for all training data
2) A vector containing a value for every training data point separately. The length of the vector equals the length of `x_train`.


##### optimise (default = [false])

The `optimise` argument takes a boolean input, true or false. If the argument is set to true the `fit_gp` function will optimise the hyperparameter of the GP model.
The optimal hyperparameter is obtained after maximisation of the log marginal likelihood implemented in Stheno.
The optimisation uses the Golden section algorithm  from the Optim package.
Golden section is used because it avoids the calculation of gradients and is sufficient because only a single hyperparameter needs to be optimised.
The initial upper and lower boundary of the algorithm is $[\text{e}^{-5},\text{e}^{10}]$. This ensures numerical stability of the model that is calculated during the optimisation procedure.

Bringing all the above mentioned arguments together in the `fit_gp` function gives:
````julia
julia> a_gp_model = fit_gp(x_train,y_train,EditDistancesKernel(Levenshtein()),m);
````

The output is a `GPModel` structure containing  three arguments:

* ``\hat{f}``: The Stheno object of the fitted GP model.
* K: A kernel object of the used kernel in the GP model.
* ``\theta``: A dictionary containing the used hyperparameter and the noise parameter with their corresponding values.


#### experimental function: `fit_gp_graph``

 A `fit_gp_graph` function is available in the package.
 The kernels used in this function are based on an underlying graph structure. Of course, this requires first the construction of a graph containing all different combinations.
 These combinations are positioned in a weighted graph where the weights of the edges are calculated based on the string distance between the two constructs they connect.
 Because a graph containing all constructs is constructed first, the inputs of the `fit_gp_graph` function deviate slightly from the classical `fit_gp` function.


 **arg**: S, x\_train, y\_train, k::KernelGraph,  edgerule::EdgeRule

 **kwarg**: $\theta= [1]$, $\sigma^2_n = 10^{-6}$, optimise = false


##### S : The Design space

 `S` is the entire design space of the modular design problem and is needed to construct the underlying graph, which is used to compute the kernel.

###### x_train and y_train

The kernel value between the two constructs is no longer independent of all other possible combinations.
The entire graph network is used to calculate the kernel value between two constructs, which has as consequence that the entire graph and the corresponding kernel have to be precomputed to fit the GP model correctly.
All kernel values between all combinations of the design space `S`  are stored in a large matrix and afterwards transformed in a `Precomputed` structure to fit the GP model.
An important side effect of using precomputed kernels is that the indices of the x_train values are required and not the constructs themselves.
An error will occur when the wrong input is used.

For `EffSpace` the indices can be obtained setting the `with_index` argument to true.
The returned tuple contains the constructs and the corresponding indices.

````julia
julia> first_sample,indexes = sample(full_space,n,with_index = true);
(BOMoD.OrderedConstruct{BOMoD.Mod{String}}[{OrderedConstruct}["a", "b", "a"], {OrderedConstruct}["a", "a", "b"], {OrderedConstruct}["a", "b", "c"]], [5, 2, 7])

````






For all other space types, the indices are returned by default as the second argument.

If the design space is stored in an array, it is advised to sample from all possible indices and not from the design space directly.
The corresponding construct can then be obtained using the given indices.
````julia
julia> explicit_space = collect(full_space);
64-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "c", "a"]
 {OrderedConstruct}["a", "c", "b"]
 ⋮
 {OrderedConstruct}["d", "b", "d"]
 {OrderedConstruct}["d", "c", "a"]
 {OrderedConstruct}["d", "c", "b"]
 {OrderedConstruct}["d", "c", "c"]
 {OrderedConstruct}["d", "c", "d"]
 {OrderedConstruct}["d", "d", "a"]
 {OrderedConstruct}["d", "d", "b"]
 {OrderedConstruct}["d", "d", "c"]
 {OrderedConstruct}["d", "d", "d"]

julia> indexes = sample(1:length(explicit_space),n);;
3-element Array{Int64,1}:
 15
  2
 38

julia> contructs = explicit_space[indexes]
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "d", "c"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["c", "b", "b"]

````





The vector `y_train` still contains the activity value of the given `x_train` inputs.

##### EdgeRule

A new type, `EdgeRule`, is introduced, to set the desired weight on the edges of the graph.
As for the different kernels, the string distances from the StringDistances package were transformed into similarities and then used as weights on edges of the graph.
Currently, the Levenshtein distance and the cosine distance are implemented, which are used with the following structures.

````julia
julia> levenstein_edgerule = LevRule();
BOMoD.LevRule()

julia> cosine_edgerule = CosRule();
BOMoD.CosRule()

````






The edge rules are used to construct the adjacency matrix, which allows for the calculation of the normalised Laplacian $\tilde{\mathcal{L}}$.
These steps are all done automatically in the package with an internal function: `setupgraph`.
The normalised Laplacian is then used to obtain the kernel.

##### k::KernelGraph

The kernels used on a graph received a specific abstract type `KernelGraph`.
BOMoD provides two kernels which use a graph structure, both are in an experimental phase.

The first kernel is the diffusion kernel:

$$K = e^{\beta \tilde{\mathcal{L}}}$$

where $\beta$ is the hyperparameter of the kernel.
The diffusion kernel can be used with the
`DiffusionKernel()` structure.

````julia
julia> k = DiffusionKernel();
BOMoD.DiffusionKernel()

````





The second kernel is the $p$-random walk kernel:

$$K = (aI - \tilde{\mathcal{L}})^p$$

where $I$ is the identity matrix, $ a \le 2$ and $ p > 1$.

The $p$-random walk kernel can be used with the `PRandomKernel(p)` setting.
````julia
julia> using BOMoD: PRandomKernel

julia>
 k = PRandomKernel(2);
BOMoD.PRandomKernel(2)

````





More information regarding the kernels is given in:

Risi Imre Kondor and John D. Lafferty. 2002. Diffusion Kernels on Graphs and Other Discrete Input Spaces.
In Proceedings of the Nineteenth International Conference on Machine Learning (ICML ’02).
Morgan Kaufmann Publishers Inc., San Francisco, CA, USA, 315–322.

Smola A.J., Kondor R. (2003) Kernels and Regularisation on Graphs.
In: Schölkopf B., Warmuth M.K. (eds) Learning Theory and Kernel Machines.
Lecture Notes in Computer Science, vol 2777. Springer, Berlin, Heidelberg


The given key word arguments have the same explanation as for the standard `fit_gp` function and are not repeated.

An example is given to fit a GP model using a kernel on a graph.
The Levenshtein distance, `LevRule()`, is used to obtain the weight of the edges and the diffusion kernel, `DiffusionKernel()`, is used.

````julia
julia> using BOMoD: fit_gp_graph

julia> first_sample,indexes = sample(full_space,3,with_index = true);
(BOMoD.OrderedConstruct{BOMoD.Mod{String}}[{OrderedConstruct}["d", "b", "d"], {OrderedConstruct}["a", "c", "d"], {OrderedConstruct}["c", "c", "a"]], [56, 12, 41])

julia> x_train_graph = indexes;
3-element Array{Int64,1}:
 56
 12
 41

julia> eltype(indexes);
Int64

julia> y_train = randn(3);
3-element Array{Float64,1}:
 -0.20641673601235763
  0.46901778102928354
  1.7723410453635258

julia> S = collect(full_space);
64-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "c", "a"]
 {OrderedConstruct}["a", "c", "b"]
 ⋮
 {OrderedConstruct}["d", "b", "d"]
 {OrderedConstruct}["d", "c", "a"]
 {OrderedConstruct}["d", "c", "b"]
 {OrderedConstruct}["d", "c", "c"]
 {OrderedConstruct}["d", "c", "d"]
 {OrderedConstruct}["d", "d", "a"]
 {OrderedConstruct}["d", "d", "b"]
 {OrderedConstruct}["d", "d", "c"]
 {OrderedConstruct}["d", "d", "d"]

julia> fit_gp_graph(S,x_train_graph,y_train,DiffusionKernel(),LevRule());
````



#### The predict_gp function

The `predict_gp` function is a straightforward wrapper to fit the desired `x_test` values in the Stheno framework.
There are two different options to use the function.

##### Prediction for all unseen data

The first option provides a tool to predict the activity values for all unseen constructs.
The filter step filters the training data from the design space which is done within the function.
The function takes four arguments, which were all obtained in the previous stages of the BOMoD process.

S: the whole search space `S`
x_train: a data set of all previously evaluated data points
model: `GPmodel` object obtained from `gp_fit` function
m: `GroupMod` object containing all modules, used to transform the data.

````julia
julia> S = collect(full_space);
64-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "b"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "c", "a"]
 {OrderedConstruct}["a", "c", "b"]
 ⋮
 {OrderedConstruct}["d", "b", "d"]
 {OrderedConstruct}["d", "c", "a"]
 {OrderedConstruct}["d", "c", "b"]
 {OrderedConstruct}["d", "c", "c"]
 {OrderedConstruct}["d", "c", "d"]
 {OrderedConstruct}["d", "d", "a"]
 {OrderedConstruct}["d", "d", "b"]
 {OrderedConstruct}["d", "d", "c"]
 {OrderedConstruct}["d", "d", "d"]

julia> prediction = predict_gp(S,x_train,a_gp_model,m);
````

For the prediction of models using kernels on a graph, the provided design space `S` should contain all indices and not the constructs themselves, because `x_train` contains all indices of the given data points. See `fit_gp_graph` for more information.

##### Prediction user-defined test set

A second option is to make predictions for a user-defined test set of constructs.
First, these selected constructs are transformed to fit smoothly in the BOMoD ecosystem.

````julia
julia> # our two construct  user-defined-test-constructs.
c₁= ["b", "b", "b", "d"]
4-element Array{String,1}:
 "b"
 "b"
 "b"
 "d"

julia> c₂ = ["a", "a", "c", "c"]
4-element Array{String,1}:
 "a"
 "a"
 "c"
 "c"

julia> #
x_test_costume = [OrderedConstruct([Mod(m) for m in cᵢ]) for cᵢ in [c₁,c₂]]
2-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["b", "b", "b", "d"]
 {OrderedConstruct}["a", "a", "c", "c"]

````


Then the `x_test_custom` can be used in the `predict_gp` function:

````julia
julia> prediction_costume = predict_gp(x_test_costume,a_gp_model,m);
````





The output of the `predict_gp` function is a `GPpredict` object containing two elements:
* ``\hat{f}_pred``: contains the Stheno object that holds the prediction values.
*   * x_test: contains the array of all constructs whose prediction values are available.

### Batch sampling`

The final step in the BOMoD process is to select the best batch of data points, which needs to be evaluated in the lab.
Five different sampling methods are available in the package.
The first three are based on well-known acquisition functions: probability of improvement (PI), expected improvement (EI), GP process upper confidence bound (GP-UCB).
The fourth option is Thompson sampling (TS).
As a final option, one can use a random sampling algorithm.
All sampling approaches are explained in detail below.

#### Probability of improvement (PI)

The PI of a construct $\mathbf{x}$ with $\hat{\mu}_r(\mathbf{x})$ the mean prediction value and
$\hat{\sigma}_r(\mathbf{x})$ the predicted standard deviation of construct $\mathbf{x}$ at iteration $r$ is given by:

```math
\Phi \left(\dfrac{\hat{\mu}_r(\mathbf{x}) - f(\mathbf{x}^+) - \epsilon}{\hat{\sigma}_r(\mathbf{x})}\right) \,,
```
were $\Phi$ indicates the CDF of the standard normal distribution, and $f(\mathbf{x}^+)$ is the current highest observed value.
$\epsilon$ is a hyperparameter to balance the exploration and exploitation properties of the sampling algorithm.

The sampler can be used with the `pi_sampler` function, which takes four arguments:

**arg**:
* f\_pre: `GPpredict` object from the `predict_gp` function
* ``b``: number of newly sampled data points
* fmax: current highest observed activity value.

**kwarg**:
* ``\epsilon``: hyperparameter to balance the exploration and exploitation properties of the sampling algorithm. A higher $\epsilon$ value results in a more exploratory sampling algorithm. The default value is zero.
The batch of $b$ samples is obtained, after sorting the constructs from high to low given their PI value. The first $b$ data points are returned as a batch.

````julia
julia> b = 3 ;
3

julia> fmax = maximum(y_train);
1.7723410453635258

julia> batch_pi = pi_sampler(prediction,b,fmax)
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "d", "a"]
 {OrderedConstruct}["b", "b", "b"]

````






#### Expected improvement (EI)

The EI of a construct $\mathbf{x}$ with $\hat{\mu}_r(\mathbf{x})$ the mean prediction value  and
$\hat{\sigma}_r(\mathbf{x})$ the predicted standard deviation of construct $\mathbf{x}$ at iteration $r$ is given by:

```math
    EI(\mathbf{x}) = \begin{cases}(\hat{\mu}_r(\mathbf{x})- f(\mathbf{x}^+) - \epsilon)\Phi(z(\mathbf{x})) +\hat{\sigma}_r(\mathbf{x})\phi(z(\mathbf{x})) &\text{ , if } {\hat{\sigma}_r}(\mathbf{x}) > 0 \\
		0  &\text{, if } \hat{\sigma}_r(\mathbf{x}) = 0\\
		\end{cases}
```

```math

    z(\mathbf{x}) = \dfrac{\hat{\mu}_r(\mathbf{x})- f(\mathbf{x}^+) - \epsilon}{\hat{\sigma}_r(\mathbf{x})} \,,
```



where $\Phi$ indicates the CDF of the standard normal distribution, $\phi$ indicates the PDF of the standard normal distribution and
$f(\mathbf{x}^+)$ is the current highest observed value. $\epsilon$ is a hyperparameter to balance the exploration and exploitation properties of the sampling algorithm.
$\hat{\sigma}_r > 0$ is always true because the GP models from Stheno package  require a minimal noise parameter $\sigma^2_n$.

The sampler can be used with the `ei_sampler` function, which takes four arguments:

**arg**
* f\_pre: `GPpredict` object from the `predict_gp` function
* ``b``: number of newly sampled data points
* fmax: current highest observed activity value.

**kwarg**
* ``\epsilon``: hyperparameter to balance the exploration and exploitation properties of the sampling algorithm. A higher $\epsilon$ value results in a more exploratory sampling algorithm. The default value is zero.

The batch of $b$ samples is obtained, after sorting the constructs from high to low based on their EI values. The first $b$ data points are returned as a batch.

````julia
julia> b = 3
3

julia> fmax = maximum(y_train)
1.7723410453635258

julia> batch_pi = ei_sampler(prediction,b,fmax)
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "d", "a"]
 {OrderedConstruct}["b", "b", "b"]

````



#### Gaussian process upper confidence bound (GP-UCB)

The GP-UCB of a construct $\mathbf{x}$ with $\hat{\mu}_r(\mathbf{x})$ the mean prediction value and
$\hat{\sigma}_r(\mathbf{x})$ the predicted standard deviation of construct $\mathbf{x}$ at iteration $r$ is given by:

```math
\text{GP-UBC} =  \hat{\mu}_r(\mathbf{x}) - \sqrt{\beta} \hat{\sigma}_r(\mathbf{x}) \,.
```
where $\beta$ is the hyperparameter to balance the exploration and exploitation properties of the algorithm.

The algorithm can be used with `gpubc_sampler` function, which takes three arguments:

**arg**
* f\_pre: `GPpredict` object from the `predict_gp` function
* ``b``: number of newly sampled data points.

**kwarg**
* ``\beta``: hyperparameter to balance the exploration and exploitation properties of the sampler, the default value is 1.

The batch of $b$ samples is obtained, after sorting the constructs from high to low given their GP-UCB values. The first $b$ data points are returned as a batch.

````julia
julia> batch_pi = gpucb_sampler(prediction,3)
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["b", "a", "b"]
 {OrderedConstruct}["a", "d", "b"]

````





An extra feature is introduced in BOMoD. For a sequential GP-UBC, a value of $\beta$ can be obtained that bounds the cumulative regret with high probability:

```math
 \beta =  2 \ln(\dfrac{|x_train|t^2π^2}{6\delta})
```
with $|\text{x_train}|$ the number of used training data points, $r$ the current iteration and $ \delta$ a parameter between zero and one.
For more information, see the theoretical derivation described by:
Srinivas, Niranjan et al. “Information-Theoretic Regret Bounds for Gaussian Process Optimization in the Bandit Setting.”
IEEE Transactions on Information Theory 58.5 (2012): 3250–3265.


The above mentioned formula is implemented in the `optimal_β$` function that takes three input arguments:

**arg**
* ``n``: number of training data points
* ``r``: current iteration number

**kwarg**
* ``\delta``: parameter of the function between zero and one. The default value is 0.2.

There is less theoretical support that the given $\beta$ is also useful for batch sampling, but the option to use this value is made available and was used before in a batch sampling setting

#### Thompson sampling (TS)

The TS algorithm works differently compared to the above acquisition functions.
It is based on a stochastic sampling procedure that is repeated $b$ times:

```math
\text{sample }y_{i} \sim \mathcal{N}(\hat{\mu}_r(\mathbf{x}),\hat{\sigma}_r(\mathbf{x}))
```

```math
	\mathbf{x}_{n+1} = \underset{\mathbf{x} \in S \setminus \mathbf{X}}{\text{argmax}}(y_{i})\,.
```

with $\hat{\mu}_r(\mathbf{x})$ the mean prediction value and $\hat{\sigma}_r(\mathbf{x})$
the predicted standard deviation of construct $\mathbf{x}$ at iteration $r$ of the BOMoD algorithm.

**arg**
* f\_pre: GPpredict object from the `predict_gp` function
* ``b``: number of data points in a batch

````julia
julia> b = 3
3

julia> batch_pi = ts_sampler(prediction,b)
3-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["b", "a", "d"]
 {OrderedConstruct}["d", "a", "d"]
 {OrderedConstruct}["a", "b", "d"]

````





#### Random sampling

The final sampling algorithm is a simple random sampling algorithm. In this case, the construction of a model is, of course not needed.

#### Combination of samplers

The use of the random sampling algorithm as single sampler should be avoided, but it can be used in combination with one of the other samplers.
This depends on the desired properties of the obtained batch because the new data points have two different functions:
1) obtain highly active constructs
2) improve the prediction capacities of the GP model to sample better constructs in the next iteration cycle
Using different samplers with different properties can result in a batch that contributes to these two functionalities.

The current version of BOMoD does not directly combine different samplers.
Still, with a small addition of code, combinations can be made.
A small example is given:
Let $b$ be the size of the batch, then one can use the EI algorithm to fill the first half of the batch. Afterwards, one can continue with random sampling to explore the design space.


````julia
julia> # inputs
b = 4
4

julia> fmax = maximum(y_train)
1.7723410453635258

julia> # split the batch
b_ei = round(b/2) |> Int
2

julia> b_random = b - b_ei |> Int
2

julia> #  sample EI
new_construct_ei = ei_sampler(prediction,b_ei,fmax)
2-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "d", "a"]

julia> #  filter, avoid resampling
x_test = filter(x-> !(x in new_construct_ei) ,prediction.x_test)
59-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "a", "a"]
 {OrderedConstruct}["a", "a", "c"]
 {OrderedConstruct}["a", "a", "d"]
 {OrderedConstruct}["a", "b", "a"]
 {OrderedConstruct}["a", "b", "b"]
 {OrderedConstruct}["a", "b", "c"]
 {OrderedConstruct}["a", "c", "a"]
 {OrderedConstruct}["a", "c", "b"]
 {OrderedConstruct}["a", "c", "c"]
 {OrderedConstruct}["a", "c", "d"]
 ⋮
 {OrderedConstruct}["d", "b", "d"]
 {OrderedConstruct}["d", "c", "a"]
 {OrderedConstruct}["d", "c", "b"]
 {OrderedConstruct}["d", "c", "c"]
 {OrderedConstruct}["d", "c", "d"]
 {OrderedConstruct}["d", "d", "a"]
 {OrderedConstruct}["d", "d", "b"]
 {OrderedConstruct}["d", "d", "c"]
 {OrderedConstruct}["d", "d", "d"]

julia> # sampler random
new_random = sample(x_test,b_random)
2-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["c", "b", "a"]
 {OrderedConstruct}["a", "a", "d"]

julia> # Concatend both batches
[new_construct_ei;new_random]
4-element Array{BOMoD.OrderedConstruct{BOMoD.Mod{String}},1}:
 {OrderedConstruct}["a", "b", "d"]
 {OrderedConstruct}["a", "d", "a"]
 {OrderedConstruct}["c", "b", "a"]
 {OrderedConstruct}["a", "a", "d"]

````





### Iteration

The BOMoD algorithm is an iterative procedure. The final two steps should be repeated after evaluating the newly proposed data points.
The GP model is then fitted on a more extensive training set, which improves the prediction capacity of the model.
Afterwards, the updated model is used in a batch sampling algorithm to propose a new batch of data points.
The number of iterations depends on the goal of the research and on the available budget.
