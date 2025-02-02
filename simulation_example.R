# rstan is required.
# if rstan package is not installed, please uncomment and run the folowings: 
# install.packages("rstan", dependencies=TRUE)
# install.packages("ggplot2", dependencies=TRUE)

# load bayesvl package
library(bayesvl)

###############################
# feed the example dataset, provided alongside with this package

data1<-read.csv("D:/project/bayesvl-master/data/Legends201.csv",header = TRUE,stringsAsFactors = TRUE)
keeps <- c("O","Lie","Viol","VB","VC","VT","Int1","Int2")
data1 <- data1[keeps]
data1<-na.omit(data1) 
str(data1)

###########################
# Design the model, and its flow of logic
###########################
model <- bayesvl()
## add the observed data nodes
model <- bvl_addNode(model, "O", "binom")
model <- bvl_addNode(model, "Lie", "binom")
model <- bvl_addNode(model, "Viol", "binom")
model <- bvl_addNode(model, "VB", "binom")
model <- bvl_addNode(model, "VC", "binom")
model <- bvl_addNode(model, "VT", "binom")
model <- bvl_addNode(model, "Int1", "binom")
model <- bvl_addNode(model, "Int2", "binom")

## add the tranform data nodes and arcs as part of the model
model <- bvl_addNode(model, "B_and_Viol", "trans")
model <- bvl_addNode(model, "C_and_Viol", "trans")
model <- bvl_addNode(model, "T_and_Viol", "trans")
model <- bvl_addArc(model, "VB",        "B_and_Viol", "*")
model <- bvl_addArc(model, "Viol",      "B_and_Viol", "*")
model <- bvl_addArc(model, "VC",        "C_and_Viol", "*")
model <- bvl_addArc(model, "Viol",      "C_and_Viol", "*")
model <- bvl_addArc(model, "VT",        "T_and_Viol", "*")
model <- bvl_addArc(model, "Viol",      "T_and_Viol", "*")
model <- bvl_addArc(model, "B_and_Viol",  "O", "slope")
model <- bvl_addArc(model, "C_and_Viol",  "O", "slope")
model <- bvl_addArc(model, "T_and_Viol",  "O", "slope")
model <- bvl_addArc(model, "Viol",   "O", "slope")
model <- bvl_addNode(model, "B_and_Lie", "trans")
model <- bvl_addNode(model, "C_and_Lie", "trans")
model <- bvl_addNode(model, "T_and_Lie", "trans")
model <- bvl_addArc(model, "VB",       "B_and_Lie", "*")
model <- bvl_addArc(model, "Lie",      "B_and_Lie", "*")
model <- bvl_addArc(model, "VC",       "C_and_Lie", "*")
model <- bvl_addArc(model, "Lie",      "C_and_Lie", "*")
model <- bvl_addArc(model, "VT",       "T_and_Lie", "*")
model <- bvl_addArc(model, "Lie",      "T_and_Lie", "*")
model <- bvl_addArc(model, "B_and_Lie",  "O", "slope")
model <- bvl_addArc(model, "C_and_Lie",  "O", "slope")
model <- bvl_addArc(model, "T_and_Lie",  "O", "slope")
model <- bvl_addArc(model, "Lie",   "O", "slope")
model <- bvl_addNode(model, "Int1_or_Int2", "trans", fun = "({0} > 0 ? 1 : 0)", out_type = "int", lower = 0, test = c(0, 1))
model <- bvl_addArc(model, "Int1", "Int1_or_Int2", "+")
model <- bvl_addArc(model, "Int2", "Int1_or_Int2", "+")

model <- bvl_addArc(model, "Int1_or_Int2", "O", "varint", priors = c("a0_ ~ normal(0,5)", "sigma_ ~ normal(0,5)"))

# review the model's diagram, that is a network of model components as declared above
bvl_bnPlot(model)

# check the generated Stan model's code
model_string <- bvl_model2Stan(model)
cat(model_string)

# detect the number of cores of your CPU
options(mc.cores = parallel::detectCores())

# fit the model using appropriate technical parameters
model <- bvl_modelFit(model, data1, warmup = 3000, iter = 10000, chains = 4)

#############################
# plots the result
#############################
# plot the mcmc chains
bvl_plotTrace(model)

# Rhat models
bvl_plotGelmans(model, NULL, 4, 3)

# Autocorrelation models
bvl_plotAcfs(model, NULL, 4, 3)

# plot the uncertainty intervals computed from posterior draws
bvl_plotIntervals(model)

#Param models
bvl_plotParams(model, 4, 3)

#Evaluate the lie factor group coefficients separately
bvl_plotIntervals(model, c("b_B_and_Lie_O", "b_C_and_Lie_O", "b_T_and_Lie_O", "b_Lie_O"))

# plot the distributions of coefficients involved "Lie"
bvl_plotDensity(model, c("b_B_and_Lie_O", "b_C_and_Lie_O", "b_T_and_Lie_O", "b_Lie_O"))

#Evaluate the violence factor coefficients separately
bvl_plotIntervals(model, c("b_B_and_Viol_O", "b_C_and_Viol_O", "b_T_and_Viol_O", "b_Viol_O"))
# plot the distributions of coefficients involved violent actions
bvl_plotDensity(model, c("b_B_and_Viol_O", "b_C_and_Viol_O", "b_T_and_Viol_O", "b_Viol_O"))

#Correlation between violence and lying
bvl_plotDensity2d(model, "b_Lie_O","b_Viol_O")

# plot specific pairs of coefficients
#viol
bvl_plotDensity2d(model, "b_B_and_Viol_O", "b_C_and_Viol_O", color_scheme = "orange")
bvl_plotDensity2d(model, "b_B_and_Viol_O", "b_T_and_Viol_O", color_scheme = "orange")
bvl_plotDensity2d(model, "b_C_and_Viol_O", "b_T_and_Viol_O", color_scheme = "skyblue")

#lie
bvl_plotDensity2d(model, "b_B_and_Lie_O", "b_C_and_Lie_O", color_scheme = "skyblue")
bvl_plotDensity2d(model, "b_B_and_Lie_O", "b_T_and_Lie_O", color_scheme = "orange")
bvl_plotDensity2d(model, "b_C_and_Lie_O", "b_T_and_Lie_O", color_scheme = "lightblue")

#Comparison with and without impact
bvl_plotTest(model, "O", "Int1_or_Int2_1")
bvl_plotTest(model, "O", "Int1_or_Int2_2")

# plot the distributions of coefficients a_Int1_or_Int2[1] and a_Int1_or_Int2[2]
bvl_plotDensity(model, c("a_Int1_or_Int2[1]", "a_Int1_or_Int2[2]"), labels = c("a_Int1_or_Int2[0]", "a_Int1_or_Int2[1]"))
bvl_plotDensity2d(model, "a_Int1_or_Int2[1]", "a_Int1_or_Int2[2]", color_scheme = "orange", labels = c("a_Int1_or_Int2[1]", "a_Int1_or_Int2[2]"))

#summary and more details the model
summary(model)
#######
#load lib loo
# Extract pointwise log-likelihood
# as of loo v2.0.0 we can optionally provide relative effective sample sizes
# when calling loo, which allows for better estimates of the PSIS effective
# sample sizes and Monte Carlo error
library(loo)
log_lik <- extract_log_lik(model@stanfit, parameter_name = "log_lik_O", merge_chains = FALSE)
r_eff <- relative_eff(exp(log_lik))
loo_result <- loo(log_lik, r_eff = r_eff, cores = 2)
print(loo_result)