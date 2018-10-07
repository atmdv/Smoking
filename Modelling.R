# Load Stan and additional packages
pacman::p_load(dplyr, rstan, ggmcmc)

# Recommended settings
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# Source useful utilities
#source_url("https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R")
source(pipe(paste("wget -O -", "https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R")))
lsf.str()

# Data manipulation
modeldata <- danskernes_rygevaner[!is.na(danskernes_rygevaner$smoker), ]

aarsdummies <- as.data.frame(model.matrix(~ year, modeldata))
aldersdummies <-  as.data.frame(model.matrix(~ factor(alder7), modeldata))
indkomstdummies <-  as.data.frame(model.matrix(~ factor(indkomst_13), modeldata))
# uddannelsesdummies <-  as.data.frame(model.matrix(~ factor(grundudd_sa), modeldata)) #ingen komplette uddannelsesvariable

# Prepare data for stan (use = instead of <-)
data_list <- list(
  N = nrow(modeldata),
  # x <- sum(pull(modeldata, "smoker")) # generates aggregrate number for binomial
  x = cbind(aarsdummies, aldersdummies, indkomstdummies),
  K = ncol(data_list$x),
  y = pull(modeldata, "smoker") # generates a vector of y/n for smokers
  )

# Run stan
results <- stan(file = "model_logit.stan",
          data = data_list)

# Save model results so it's not necessary to continually rerun
#save(results, file="model_results.rda")

# Performance checks - additional checks can be conducted with the ggmcmc-package
traceplot(results)

# Analysis of model results
print(results)

plot(results)
parameterdraws <- rstan::extract(results) 
hist(parameterdraws$beta)



