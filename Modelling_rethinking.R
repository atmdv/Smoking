# Load Stan and additional packages
pacman::p_load(dplyr, rstan, ggmcmc, rethinking)

# Recommended settings and utilities (see Betancourt)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# source(pipe(paste("wget -O -", "https://github.com/betanalpha/knitr_case_studies/blob/master/rstan_workflow/stan_utility.R")))
# lsf.str()

# Data manipulation
# Categories are input as integers
# Only complete data points are useable in the model
danskernes_rygevaner$age_group <- coerce_index(danskernes_rygevaner$alder7)
danskernes_rygevaner$smoker <- danskernes_rygevaner$smoker*1
danskernes_rygevaner$year <- coerce_index(danskernes_rygevaner$year)
danskernes_rygevaner$female <- danskernes_rygevaner$female*1
# danskernes_rygevaner$female <- ifelse(danskernes_rygevaner$female==TRUE, 1, -1)

model_data <- danskernes_rygevaner %>% 
  select(smoker, female, age_group, year) %>% 
  filter(complete.cases(.))

model_data <- data.frame(model_data)

# Model #1 - Smoking frequency as a constant
model.1 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a,
    a ~ dnorm(0,1)
  ),
  data=model_data
)

precis(model.1)

# Average frequency (parameter estimate is log odds ratio)
exp(-1.24)/(1+exp(-1.24))

# Model #2 - Smoking frequency with slopes varying by gender
model.2 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a + bf*female,
    a ~ dnorm(0,1),
    bf ~ dnorm(0,10)
  ),
  data=model_data
  )

precis(model.2)

compare(model.1, model.2)

# Model #3 - Smoking frequency within age group
model.3 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a[age_group],
    a[age_group] ~ dnorm(0,10)
  ),
  data=model_data
)

precis(model.3, depth=2)

# Model #4 - Smoking frequency within age group, slopes varying by gender
model.4 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a[age_group] + bf*female,
    a[age_group] ~ dnorm(0,10),
    bf ~ dnorm(0,10)
  ),
  data=model_data
)

precis(model.4, depth=2)

compare(model.1, model.2, model.3, model.4)

# Model #5 - Smoking frequency partially pooled over age group
model.5 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a[age_group],
    a[age_group] ~ dnorm(a,sigma),
    a ~ dnorm(0,1),
    sigma ~ dcauchy(0,1)
  ),
  data=model_data,
  chains=4
)

precis(model.5, depth=2)

# Model #6 - Smoking frequency partially pooled over age group, slopes varying by gender
model.6 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a[age_group] + bf*female,
    a[age_group] ~ dnorm(a,sigma),
    a ~ dnorm(0,1),
    sigma ~ dcauchy(0,1),
    bf ~ dnorm(0,10)
  ),
  data=model_data,
  chains=4,
  cores=2
)

precis(model.6, depth=2)

# Model #7 - Smoking frequency partially pooled over age group, slopes varying by gender
# Model 6, but modelled as divergences from mean
model.7 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a + a_age[age_group] + bf*female,
    a_age[age_group] ~ dnorm(a,sigma_age),
    bf ~ dnorm(0,10),
    c(a, a_age) ~ dnorm(0,1),
    sigma_age ~ dcauchy(0,1)
  ),
  data=model_data,
  chains=4,
  cores=2
)

precis(model.7, depth=2)

# Model #8 - Smoking frequency and slopes partially pooled over age group, effect of gender varies by age group
# keep parameterization non-centered as in model 7
model.8 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- a_age[age_group] + bf_age[age_group]*female,
    c(a_age, bf_age)[age_group] ~ dmvnorm2(c(a, bf), sigma_age, Rho),
    a ~ dnorm(0,1),
    bf ~ dnorm(0,1),
    sigma_age ~ dcauchy(0, 2),
    Rho ~ dlkjcorr(2)
  ),
  data=model_data,
  warmup=1000, 
  iter=1000,
  chains=4,
  cores=3,
  control=list(adapt_delta=0.9)
)

precis(model.8, depth=2)
plot(precis(model.8, pars=c("a_age"), depth=2))

# plot(model.8)
# pairs(model.8, pars=c("a", "Rho"))
# check_n_eff(model.8)
# check_treedepth(model.8)


# Model #9 - Smoking frequency and slopes partially pooled over age group, effect of gender varies by age group
# non-centered parameterization
model.9 <- map2stan(
  alist(
    smoker ~ dbinom(1, p),
    logit(p) <- AGE + (BF + BY*BF)*female,
    AGE <- a + a_age[age_group] + a_year[year],
    BF <- bf + bf_age[age_group] + bf_year[year],
    BY <- by + by_age[age_group] + by_year[year],
    c(a_age, bf_age, by_age)[age_group] ~ dmvnormNC(sigma_age_group, Rho_age_group),
    c(a_year, bf_year, by_year)[year] ~ dmvnormNC(sigma_year, Rho_year),
    c(a, bf, by) ~ dnorm(0,1),
    sigma_age_group ~ dcauchy(0, 2),
    sigma_year ~ dcauchy(0, 2),
    Rho_age_group ~ dlkjcorr(4),
    Rho_year ~ dlkjcorr(4)
  ),
  data=model_data,
  warmup=1000, 
  iter=4000,
  chains=3,
  cores=3
)

p.9 <- link(model.9)
p.9_mean <- apply(p.9$AGE, 2, mean)
p.9_PI <- apply(p.9$AGE, 2, PI, prob=0.95)

precis(model.9, depth=2)
plot(model.9)
save(model.9, file="model9")
load("model9")

# models <- list(model.1, model.2, model.3, model.4, model.5, model.6, model.7)
# save(models, file="temp_models")

# # aarsdummies <- as.data.frame(model.matrix(~ year, modeldata))
# # indkomstdummies <-  as.data.frame(model.matrix(~ factor(indkomst_13), modeldata))
# # uddannelsesdummies <-  as.data.frame(model.matrix(~ factor(grundudd_sa), modeldata)) #ingen komplette uddannelsesvariable
# 
# # Prepare data for stan (use = instead of <-)
# data_list <- list(
#   N = nrow(modeldata),
#   # x <- sum(pull(modeldata, "smoker")) # generates aggregrate number for binomial
#   x = cbind(aarsdummies, aldersdummies, indkomstdummies),
#   K = ncol(data_list$x),
#   y = pull(modeldata, "smoker") # generates a vector of y/n for smokers
#   )
# 
# # Run stan
# results <- stan(file = "model_logit.stan",
#           data = data_list)
# 
# # Save model results so it's not necessary to continually rerun
# #save(results, file="model_results.rda")
# 
# # Performance checks - additional checks can be conducted with the ggmcmc-package
# traceplot(results)
# 
# # Analysis of model results
# print(results)
# 
# plot(results)
# parameterdraws <- rstan::extract(results) 
# hist(parameterdraws$beta)
# 
# 
# 
