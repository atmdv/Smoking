# Define the stan-model
data {
  int n;
  int x;
}
parameters {
  real<lower=0, upper=1> p;
}
model {
  p ~ uniform(0, 1);
  x ~ binomial(n, p);
}

