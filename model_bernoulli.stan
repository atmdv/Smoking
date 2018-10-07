// Define the stan-model
data {
  int<lower=0> N; // initialize a variable indicating the number of elements in x - size of the sample
  int<lower=0, upper=1> y[N]; // initialize variable for the number of smokers
}
parameters {
  real<lower=0, upper=1> p; // mean of the data-generating population
}
model {
  beta ~ normal(0.5, 0.25); // prior on beta
  y ~ bernoulli_logit(x * beta); // vectorized likelihood
}


