rm(list=ls())

pacman::p_load(haven, dplyr, ggplot2)

# Load raw data from SIF
danskernes_rygevaner <- read_dta("C:/Users/Andreas Tyge Moller/Google Drive/Rygefrekvenser/DR_samlet.dta")

# After 1997 data are available annually
danskernes_rygevaner <- danskernes_rygevaner[which(danskernes_rygevaner$year>1997), ]

# Recode variables
danskernes_rygevaner$female <- danskernes_rygevaner$KOEN - 1
class(danskernes_rygevaner$female) <- "logical"

danskernes_rygevaner$smoker <- abs(danskernes_rygevaner$ryger_du - 2)
class(danskernes_rygevaner$smoker) <- "logical"

# Sample smoking prevalence
sample_smoking_prevalence <- danskernes_rygevaner %>%
  group_by(year) %>%
  summarise(sample_smoking_prevalence=mean(smoker, na.rm=T)*100)

# Plot of sample smoking prevalence
ggplot(sample_smoking_prevalence, aes(year, sample_smoking_prevalence, group=1)) +
  geom_line() +
  theme_classic() +
  xlab("") + scale_x_discrete(breaks=seq(1998, 2016, 2)) +
  ylab("Sample smoking prevalence (percent)")

# Young smokers, ages 16-25
danskernes_rygevaner$young <- danskernes_rygevaner$alder7 %in% c(1, 2)

# After 2008 data are consistent until 2016
danskernes_rygevaner <- danskernes_rygevaner[which(danskernes_rygevaner$year>2008), ]

# Sample smoking prevalence, by young/not young. Age groups are only consistent after 2007.
sample_smoking_prevalence_grouped <- danskernes_rygevaner %>%
  group_by(year, young) %>%
  summarise(sample_smoking_prevalence=mean(smoker, na.rm=T)*100, group_size=n(), se=sqrt(var(smoker, na.rm = T)/n())*100)

# Plot of sample smoking prevalence, by young/not young. Age groups are only consistent after 2007.
ggplot(sample_smoking_prevalence_grouped, aes(year, sample_smoking_prevalence)) +
  geom_line(aes(color=young, group=young)) +
  geom_errorbar(aes(ymin=sample_smoking_prevalence-se, ymax=sample_smoking_prevalence+se, color=young), width=.1) +
  theme_classic() +
  theme(legend.position = c(0.9, 0.9)) +
  labs(color = "", x="", y="Sample smoking prevalence (percent)") + 
  scale_color_hue(labels = c("Rest of sample", "Young people"))

# Add data from the Danish Cancer Society
year <- c("2015", "2016")
daily_smokers <- c(0.13, 0.15)
daily_weekly_smokers <- c(0.18, 0.22)
cancer_data <- data.frame(year, daily_smokers, daily_weekly_smokers, stringsAsFactors = F)

cancer_data$se_daily_smokers <- sqrt(daily_smokers*(1-daily_smokers)/(2000-1))
cancer_data$se_daily_weekly_smokers <- sqrt(daily_weekly_smokers*(1-daily_weekly_smokers)/(2000-1))
cancer_data$group <- "cancer"

# Combine SIF data with Cancer Society Data - smoking prevalence measured by daily and weekly smokers
cancer_data$sample_smoking_prevalence <- cancer_data$daily_weekly_smokers*100
cancer_data$se <- cancer_data$se_daily_weekly_smokers*100
sample_smoking_prevalence_grouped$group <- as.character(sample_smoking_prevalence_grouped$young)

combined_smoking_stats <- rbind(sample_smoking_prevalence_grouped[, c("year", "group", "sample_smoking_prevalence", "se")],
                                    c(cancer_data[, c("year", "group", "sample_smoking_prevalence", "se")]))

# Plot of sample smoking prevalence, including data points from the Danish Cancer Society.
ggplot(combined_smoking_stats, aes(year, sample_smoking_prevalence)) +
  geom_line(aes(color=group, group=group)) +
  geom_point(aes(color=group, group=group)) +
  geom_errorbar(aes(ymin=sample_smoking_prevalence-se, ymax=sample_smoking_prevalence+se, color=group), width=.1) +
  labs(color = "", x="", y="Sample smoking prevalence (percent)") + 
  theme_classic() +
  theme(legend.position = c(0.9, 0.9), legend.key.height=unit(2,"line")) +
  scale_color_hue(labels = c("Young people\n(Cancer Society data)", "Young people\n(Dep. Health data)", "Rest of sample\n(Dep. Health data)"))
  
# Fuck sample weighting
# Prepare data for sample weighting using sex, age, level of education, income
# rygefrekvens_grouped <- danskernes_rygevaner %>%
#  group_by(year, kvinde, indkomst_13) %>%
#  summarise(rygefrekvens_group=mean(ryger, na.rm=T))




