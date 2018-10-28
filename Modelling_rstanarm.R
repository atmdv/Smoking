# Load Stan and additional packages
pacman::p_load(dplyr, rstanarm, ggmcmc, rethinking, ggplot2)

################################################################################
# Throw out all unneeded data in the dataset
# Only complete data points are useable in the model
danskernes_rygevaner$smoker <- danskernes_rygevaner$smoker
danskernes_rygevaner$year <- as.factor(danskernes_rygevaner$year)
danskernes_rygevaner$female <- danskernes_rygevaner$female
danskernes_rygevaner$age_group <- as.factor(danskernes_rygevaner$alder7)
model_data <- danskernes_rygevaner %>% 
  select(smoker, female, age_group, year) %>% 
  filter(complete.cases(.))
model_data <- data.frame(model_data)

################################################################################
# Model fitting

# Intercept model
m1 <- stan_glmer(formula = smoker ~ 1 + (1 | year),
                family = binomial(link = "logit"),
                data = model_data,
                seed = 1234)
prior_summary(object = m1)
# save(m1, file="rstanarm_m1.RData")
# load("rstanarm_m1.RData")

m2 <- stan_glmer(formula = smoker ~ female + (1 | year),
                 family = binomial(link = "logit"),
                 data = model_data,
                 seed = 1234)
prior_summary(object = m2)
save(m2, file="rstanarm_m2.RData")
# load("rstanarm_m2.RData")

m3 <- stan_glmer(formula = smoker ~ 1 + year + (1 + year | age_group),
                 family = binomial(link = "logit"),
                 data = model_data,
                 seed = 1234)
prior_summary(object = m3)
save(m3, file="rstanarm_m3.RData")
# load("rstanarm_m3.RData")

m4 <- stan_glmer(formula = smoker ~ female + (1 + female + age_group | year),
                 family = binomial(link = "logit"),
                 data = model_data,
                 seed = 1234)
prior_summary(object = m4)
save(m4, file="rstanarm_m2.RData")
# load("rstanarm_m4.RData")

################################################################################
# Posterior checks of m1
m1
summary(m1, 
        pars = c("(Intercept)", "sigma", "Sigma[year:(Intercept),(Intercept)]"),
        probs = c(0.025, 0.975),
        digits = 2)
# exp(-1.24)/(1+exp(-1.24))
m1.sims <- as.matrix(m1)

# Posterior mean and SD of each alpha
# draws for overall mean
m1.mu_a_sims <- as.matrix(m1, 
                       pars = "(Intercept)")
# draws for error
m1.u_sims <- as.matrix(m1, 
                    regex_pars = "b\\[\\(Intercept\\) year\\:")
# draws for 73 schools' varying intercepts               
m1.a_sims <- plogis(as.numeric(m1.mu_a_sims) + m1.u_sims)
# Posterior mean and SD of each alpha
m1.mean <- apply(X = m1.a_sims,     # posterior mean
                 MARGIN = 2,
                 FUN = mean)
m1.sd <- apply(X = m1.a_sims,       # posterior SD
               MARGIN = 2,
               FUN = sd)
# Posterior median and 95% credible interval
m1.quant <- apply(X = m1.a_sims,
                  MARGIN = 2,
                  FUN = quantile,
                  probs = c(0.025, 0.50, 0.975))
m1.quant <- data.frame(t(m1.quant))
names(m1.quant) <- c("Q2.5", "Q50", "Q97.5")

# Combine summary statistics of posterior simulation draws
m1.df <- data.frame(m1.mean, m1.sd, m1.quant)
m1.df$year <- substring(rownames(m1.df), 20, 23)

# Plot sample smoking prevalence and overlay estimated intercepts
sample_smoking_prevalence <- model_data %>%
  group_by(year) %>%
  summarise(sample_smoking_prevalence=mean(smoker)*100,
            group_size=n(),
            se=sqrt(var(smoker)/n())*100)

ggplot(data = sample_smoking_prevalence,
       aes(year, sample_smoking_prevalence, group=1)) +
  geom_line(color="blue") +
  theme_classic() +
  geom_line(data = m1.df,
            aes(year, m1.mean*100, group=1)) +
  geom_ribbon(aes(x = year,
                  ymin = (m1.mean - m1.sd)*100,
                  ymax = (m1.mean + m1.sd)*100), alpha=0.2) +
  xlab("") + scale_x_discrete(breaks=seq(2009, 2016, 1)) +
  ylab("Sample smoking prevalence (percent)") +
  geom_text(aes(label = "Sample mean", x = 1, y = 23.7), color="blue") +
  geom_text(aes(label = "Regularized \n estimate", x = 1, y = 22.7))

################################################################################
# Posterior checks of m2





