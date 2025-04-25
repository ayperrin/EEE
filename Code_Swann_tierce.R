####Packages####
install.packages("haven")
install.packages("dplyr")
install.packages("tidyr")
install.packages("stargazer")
install.packages("ggplot2")
install.packages("modelsummary")
install.packages("rstudioapi")
install.packages("plm")
install.packages("car")
install.packages("sandwich")
install.packages("lmtest")
library("haven")
library("dplyr")
library("tidyr")
library("stargazer")
library("ggplot2")
library("modelsummary")
library("plm")
library("car")
library("sandwich")
library("lmtest")
#####Repository####
setwd("~/Cours ENSAE 3A/Environmental Economics/wetransfer_for-students_2025-03-14_1338/for students/data")



####Question 1####
us_panel_short <- read_dta("us_panel_short_burkeemmerick.dta")
crop_x_county_shocks <- read.csv("crop_x_county_shocks.csv")
##We need to merge both the STATE_FIP and the CNTY_FIPS to get a merging key fips that is the same in both tables
crop_x_county_shocks$fips = sprintf("%02d%03d", crop_x_county_shocks$STATE_FIP, crop_x_county_shocks$CNTY_FIPS)
crop_x_county_shocks$fips = as.numeric(crop_x_county_shocks$fips)
##We only select the columns of interest in the data frame crop_x_county_shocks
crop_x_county_shocks_q1 <- crop_x_county_shocks[ , c(length(colnames(crop_x_county_shocks)),grep("139|115|130", names(crop_x_county_shocks)))]

##We are gonna restrict ourselves to the 1950s (before innovation in response to climate change can have an
##effect on yields)
crop_x_county_shocks_q1 <- crop_x_county_shocks_q1[ , c(1,grep("1950", names(crop_x_county_shocks_q1)))]
##So we need to aggregate the results in us_panel_short to get a result for the 1950s
us_panel_short_q1 <- us_panel_short %>% 
  filter(year >= 1950 & year <= 1959) %>% 
  group_by(fips) %>% 
  summarise(across(c(cornyield, soyyield, cottonyield, corn_area, soy_area, cotton_area), ~ mean(.x, na.rm = TRUE)))
##Now we merge the data sets
data_frame_q1 <- merge(us_panel_short_q1,crop_x_county_shocks_q1, by="fips")
model_cotton <- lm(cottonyield ~ X139_gddHot_1950 + cotton_area, data = data_frame_q1)
model_corn <- lm(cornyield ~ X115_gddHot_1950 + corn_area, data = data_frame_q1)
model_soy <- lm(soyyield ~ X130_gddHot_1950 + soy_area, data = data_frame_q1)

##Let's look at the estimated parameters
summary(model_cotton)
summary(model_corn)
summary(model_soy)

stargazer(model_cotton, type = "text")
stargazer(model_corn, type = "text")
stargazer(model_soy, type = "text")
stargazer(model_cotton,model_corn,model_soy, type="text")
##Notice that the coefficient for cotton is positive while we expect a negative sign
ggplot(data_frame_q1, aes(x = X139_gddHot_1950, y =cottonyield)) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(data_frame_q1, aes(x = X115_gddHot_1950, y =cornyield)) +
  geom_point() +
  geom_smooth(method = "lm")

##Let's do as in the paper with a regression with individual effect for each crop
table_cotton <- data_frame_q1 %>%
  mutate(yield = log(cottonyield),
         area = cotton_area,
         gddHot=X139_gddHot_1950,
         crop="cotton") %>%
  select(fips,crop,yield,area,gddHot)
table_corn <- data_frame_q1 %>%
  mutate(yield = log(cornyield),
         area = corn_area,
         gddHot=X115_gddHot_1950,
         crop="corn") %>%
  select(fips,crop,yield,area,gddHot)
table_soy <- data_frame_q1 %>%
  mutate(yield = log(soyyield),
         area = soy_area,
         gddHot=X130_gddHot_1950,
         crop="soy") %>%
  select(fips,crop,yield,area,gddHot)
table_final <- rbind(table_cotton,table_corn,table_soy)


model_q1_simple <- lm(yield ~ gddHot + area, data = table_final)
model_q1_fe_crop <- lm(yield ~ gddHot + area+as.factor(crop), data = table_final)
model_q1_fe_counties <- lm(yield ~ gddHot + area+as.factor(fips), data = table_final)
model_q1_fe_tot <- lm(yield ~ gddHot + area+as.factor(fips)+as.factor(crop), data = table_final)
##Let's look at the estimated parameters
stargazer(model_q1_simple,model_q1_fe_crop,model_q1_fe_counties, type = "text", omit = "as.factor\\(")
stargazer(model_q1_fe_crop,model_q1_fe_counties,model_q1_fe_tot, type = "text", omit = "as.factor\\(")
##Note that if we add both fixed effects, the coefficient estimate for gddHot becomes non significant
##The most relevant model would be the one with the fixed effect only on the crop because in order to estimate
##the fixed effect for counties, you only have 3 observations...


##What happens if we cluster the standard errors?
model_q1_fe_crop <- lm(yield ~ gddHot + area+as.factor(crop), data = table_final)
summary(model_q1_fe_crop)
clustered_standard_error <- vcovCL(model_q1_fe_crop, cluster = ~ crop)
coeftest(model_q1_fe_crop, vcov = clustered_standard_error)
##Note that if we cluster the standard errors, the estimate for gddHot becomes less significant















####Question2####
crop_level_data <- read_dta("crop_level_data.dta")
##We want the effect of heat exposure on new varieties 
##using a long-difference estimation based on the period 1970s-2000s
##Construction of the 2 variables of interest
crop_level_data_q2 <- crop_level_data %>%
  filter(year %in% c(1970, 2000))
##We keep the initial number of crops as a control
nb_crop_init <- crop_level_data %>%
  filter(year %in% c(1950)) %>%
  mutate(ncrop_init=ncrop) %>%
  select(id,ncrop_init)

##We need to transpose the data-frame to compute the difference between the 
##value for 1970 and the value for 2000
crop_level_data_q2 <- crop_level_data_q2 %>%
  select(id,year,ncrop, hot_gdd_panel, log_total_area, pre_avgtemp, pre_precip) %>%
  pivot_wider(names_from = year,
              values_from = c(ncrop, hot_gdd_panel))%>%
  mutate(ncrop = ncrop_2000 - ncrop_1970,
         hot_gdd_panel = hot_gdd_panel_2000 - hot_gdd_panel_1970)

crop_level_data_q2 <- merge(crop_level_data_q2,nb_crop_init,by="id")
print(min(crop_level_data_q2$ncrop))
##Note that the minimum evolution of the number of crops is strictly positive (use Poisson model?)

##Simple linear model
model_q2_1 <- lm(ncrop ~ hot_gdd_panel, data = crop_level_data_q2)
model_q2_2 <- lm(ncrop ~ hot_gdd_panel+log_total_area , data = crop_level_data_q2)
model_q2_3 <- lm(ncrop ~ hot_gdd_panel+log_total_area+ncrop_init, data = crop_level_data_q2)
model_q2_4 <- lm(ncrop ~ hot_gdd_panel+log_total_area+ncrop_init+pre_avgtemp+pre_precip, data = crop_level_data_q2)
stargazer(model_q2_1, model_q2_2, model_q2_3, model_q2_4, type = "text")



##Poisson model (you take into account the fact that the variable is strictly positive integers)
model_poiss_1 <- glm(ncrop ~ hot_gdd_panel, 
                     family = poisson(link = "log"), 
                     data = crop_level_data_q2)
model_poiss_2 <- glm(ncrop ~ hot_gdd_panel+log_total_area, 
                     family = poisson(link = "log"), 
                     data = crop_level_data_q2)
model_poiss_3 <- glm(ncrop ~ hot_gdd_panel+log_total_area+ncrop_init, 
                     family = poisson(link = "log"), 
                     data = crop_level_data_q2)
model_poiss_4 <- glm(ncrop ~ hot_gdd_panel+log_total_area+ncrop_init+pre_avgtemp+pre_precip, 
                     family = poisson(link = "log"), 
                     data = crop_level_data_q2)
stargazer(model_poiss_1, model_poiss_2, model_poiss_3, model_poiss_4, type = "text")
##Note that Poisson model coefficients are on the log scale, (you modelize the log of y) 
##This time even in the simpler model (the first one), the estimate for 
##hot_gdd_panel is significant


















####Question3####
county_level_data <- read_dta("county_level_data.dta")
##Quantile regression as in Figure VI
##Note that we need the counties to not move between quantiles in order to get an estimation
##So we are computing the quantiles on the average heat exposure over the full period
county_avg_ee <- county_level_data %>%
  group_by(id) %>%
  summarise(mean_ee = mean(ee, na.rm = TRUE))
quantiles <- quantile(county_avg_ee$mean_ee, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))
county_avg_ee <- county_avg_ee %>%
  mutate(ee_group = cut(mean_ee,
                        breaks = c(-Inf, quantiles, Inf),
                        labels = c("10th", "25th", "50th", "75th", "90th", "99th"),
                        right = TRUE))
county_level_data_q3 <- county_level_data %>%
  left_join(county_avg_ee %>% select(id, ee_group), by = "id")
##We run separate regression for each quantile
quant_reg <- lapply(levels(county_level_data_q3$ee_group)[1:6], function(group) {
  county_level_data_q3_quant <- dplyr::filter(county_level_data_q3, ee_group == group)
  lm(lland_value_acre ~ loo+as.factor(state_year)+as.factor(id)+area_init+avgtemp_loo+logprice_own, data = county_level_data_q3_quant)
})
##We now compute the confidence interval (90% and 95%) assuming normal distribution
coef_with_ci <- do.call(rbind, lapply(seq_along(quant_reg), function(i) {
  model <- quant_reg[[i]]
  s <- summary(model)
  coef <- s$coefficients["loo", "Estimate"]
  se <- s$coefficients["loo", "Std. Error"]
  data.frame(
    ee_group = levels(county_level_data_q3$ee_group)[i],
    estimate = coef,
    lower_95 = coef - 1.96 * se,
    upper_95 = coef + 1.96 * se,
    lower_90 = coef - 1.645 * se,
    upper_90 = coef + 1.645 * se
  )
}))
##Now we plot the graph to get similar presentation as in Figure VI
ggplot(coef_with_ci, aes(x = ee_group, y = estimate)) +
  geom_errorbar(aes(ymin = lower_95, ymax = upper_95),
                width = 0.2, size = 0.8, color = "black", linetype = "dotted") +
  geom_errorbar(aes(ymin = lower_90, ymax = upper_90),
                width = 0.2, size = 0.8, color = "black", linetype = "solid") +
  geom_point(size = 4, shape = 16, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey30", size = 0.8) +
  labs(x = "Extreme Heat  Exposure Quantile",
       y = "Marginal Effect of Innovation Exposure") +
  theme_classic() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.position = "right")



##Let's try with panel modelisation
##we use a fixed effects (within) estimator with two-way effects (county and year)
county_level_data <- read_dta("county_level_data.dta")
##Quantile regression as in Figure VI
##Note that we need the counties to not move between quantiles in order to get an estimation
##So we are computing the quantiles on the average heat exposure
county_avg_ee <- county_level_data %>%
  group_by(id) %>%
  summarise(mean_ee = mean(ee, na.rm = TRUE))
quantiles <- quantile(county_avg_ee$mean_ee, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))
county_avg_ee <- county_avg_ee %>%
  mutate(ee_group = cut(mean_ee,
                        breaks = c(-Inf, quantiles, Inf),
                        labels = c("10th", "25th", "50th", "75th", "90th", "99th"),
                        right = TRUE))
county_level_data_q3 <- county_level_data %>%
  left_join(county_avg_ee %>% select(id, ee_group), by = "id")
##We run separate regression for each quantile
quant_reg <- lapply(levels(county_level_data_q3$ee_group)[1:6], function(group) {
  county_level_data_q3_quant <- dplyr::filter(county_level_data_q3, ee_group == group)
  ##We create the structure for panel data
  pcounty_level_data_q3_quant <- pdata.frame(county_level_data_q3_quant, index = c("id", "year"))
  plm_model <- plm(lland_value_acre ~ loo + area_init + avgtemp_loo + logprice_own,
                   data = pcounty_level_data_q3_quant,
                   index = c("id", "year"),
                   model = "within",
                   effect = "twoways")
  return(plm_model)
})
##We now compute the confidence interval (90% and 95%) assuming normal distribution
coef_with_ci <- do.call(rbind, lapply(seq_along(quant_reg), function(i) {
  model <- quant_reg[[i]]
  s <- summary(model)
  coef <- s$coefficients["loo", "Estimate"]
  se <- s$coefficients["loo", "Std. Error"]
  data.frame(
    ee_group = levels(county_level_data_q3$ee_group)[i],
    estimate = coef,
    lower_95 = coef - 1.96 * se,
    upper_95 = coef + 1.96 * se,
    lower_90 = coef - 1.645 * se,
    upper_90 = coef + 1.645 * se
  )
}))
##Now we plot the graph to get similar presentation as in Figure VI
ggplot(coef_with_ci, aes(x = ee_group, y = estimate)) +
  geom_errorbar(aes(ymin = lower_95, ymax = upper_95),
                width = 0.2, size = 0.8, color = "black", linetype = "dotted") +
  geom_errorbar(aes(ymin = lower_90, ymax = upper_90),
                width = 0.2, size = 0.8, color = "black", linetype = "solid") +
  geom_point(size = 4, shape = 16, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey30", size = 0.8) +
  labs(x = "Extreme Heat  Exposure Quantile",
       y = "Marginal Effect of Innovation Exposure") +
  theme_classic() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.position = "right")
##We get quite similar results!



##Let's try with interaction terms and compute marginal effects for values of quantile of heat exposure
county_level_data <- read_dta("county_level_data.dta")
##We are computing the quantiles on the average heat exposure
county_avg_ee <- county_level_data %>%
  group_by(id) %>%
  summarise(mean_ee = mean(ee, na.rm = TRUE))
quantiles <- quantile(county_avg_ee$mean_ee, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))
county_avg_ee <- county_avg_ee %>%
  mutate(ee_group = cut(mean_ee,
                        breaks = c(-Inf, quantiles, Inf),
                        labels = c("10th", "25th", "50th", "75th", "90th", "99th"),
                        right = TRUE))
county_level_data_q3 <- county_level_data %>%
  left_join(county_avg_ee %>% select(id, ee_group), by = "id")
##Model with interactions
model_interact <- lm(lland_value_acre ~ loo + ee + loo*ee +
                       factor(state_year) + factor(id) +
                       area_init + avgtemp_loo + logprice_own ,
                     data = county_level_data_q3)

b_loo   <- coef(model_interact)["loo"]
b_loo_ee   <- coef(model_interact)["loo:ee"]
marginal_effects <- data.frame(
  ee_quantile = names(quantiles),
  ee_value    = as.numeric(quantiles),
  marginal_effect_loo = b_loo + b_loo_ee * as.numeric(quantiles)
)
##We compute standard errors with the delta method using the car package
standard_errors <- numeric(length(quantiles))
for(i in seq_along(quantiles)) {
  expr <- paste0("loo + `loo:ee` * ", quantiles[i])
  dm   <- deltaMethod(model_interact, expr, singular.ok = TRUE)
  standard_errors[i] <- dm$SE
}
marginal_effects$se_interact <- standard_errors
marginal_effects$ci_lower_95 <- marginal_effects$marginal_effect_loo - 1.96*marginal_effects$se_interact
marginal_effects$ci_upper_95 <- marginal_effects$marginal_effect_loo + 1.96*marginal_effects$se_interact
marginal_effects$ci_lower_90 <- marginal_effects$marginal_effect_loo - 1.645*marginal_effects$se_interact
marginal_effects$ci_upper_90 <- marginal_effects$marginal_effect_loo + 1.645*marginal_effects$se_interact

##Now we plot the graph to get similar presentation as in Figure VI
ggplot(marginal_effects, aes(x = ee_quantile, y = marginal_effect_loo)) +
  geom_errorbar(aes(ymin = ci_lower_95, ymax = ci_upper_95),
                width = 0.2, size = 0.8, color = "black", linetype = "dotted") +
  geom_errorbar(aes(ymin = ci_lower_90, ymax = ci_upper_90),
                width = 0.2, size = 0.8, color = "black", linetype = "solid") +
  geom_point(size = 4, shape = 16, color = "black") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey30", size = 0.8) +
  labs(x = "Extreme Heat  Exposure Quantile",
       y = "Marginal Effect of Innovation Exposure") +
  theme_classic() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        plot.title = element_text(hjust = 0.5, size = 16),
        legend.position = "right")
##But with the interaction model we get quite different results....