// Define the stan-model
data {
  int<lower=0> N; // The number of respondents - size of the sample
  int<lower=1> K; // Number of covariates in x
  matrix[N, K] x; // Initialize matrix of covariates
  int<lower=0, upper=1> y[N]; // initialize variable for whether person is a smoker
}
parameters {
  vector[K] beta; // Parameter vector
}
model {
  beta ~ normal(0, 0.25); // trying a different prior for fun
  y ~ bernoulli_logit(x * beta); // sampling statement for data (vectorized - could have used loop over y[n])
}




