// Define the stan-model
data {
  int n; // initialize a variable indicating the number of elements in x - size of the sample
  int x; // initialize variable for the number of smokers
}
parameters {
  real<lower=0, upper=1> p; // mean of the data-generating population
}
model {
  p ~ uniform(0, 1); // prior on p
  //p ~ normal(0.5, 0.25); // trying a different prior for fun
  x ~ binomial(n, p); // sampling statement for data
}


