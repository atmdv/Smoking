# Load Stan
pacman::p_load(rstan)

# Recommended settings
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Source useful utilities
#source_url("https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R")
source(pipe(paste("wget -O -", "https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R")))
lsf.str()

# Prepare data for stan
data_list <- list(n = 30, x = 10)

# Run stan
results <- stan(file = "Model.stan",
          data = data_list)

# Analysis of model results
print(s)

traceplot(s)

plot(s)

a <- extract(s, permuted = FALSE) 


