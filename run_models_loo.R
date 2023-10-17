library(rstan)
library(ggplot2)
library(R.matlab)
library("loo")
library(gplots)
#load("~/Documents/Allison'stask/model/bayesian/results/W1_inprogress.RData")
options(mc.cores = parallel::detectCores()) 
setwd("~/Documents/Allison'stask/model/bayesian")
# read in wave1 data
w1 = subset(test1,test1$wave==1)
w1$subj <- as.factor(w1$subj)
w1_list = split(w1,w1$subj)
trialNo_list <- sapply(w1_list, function(x) x[9][1,])
names(trialNo_list) <- NULL
choice_game <-sapply(w1_list,function(x) x$c_game)
names(choice_game) <- NULL
choice_side <-sapply(w1_list,function(x) x$c_side)
names(choice_side) <- NULL
maxEff_r <-sapply(w1_list,function(x) x$overach_ratio)
names(maxEff_r) <- NULL
minEff_r <-sapply(w1_list,function(x) x$lazy_ratio)
names(minEff_r) <- NULL
fb_list <-sapply(w1_list,function(x) x$acc)
names(fb_list) <- NULL

nSubjects <- length(w1_list)
nTrials   <- trialNo_list

# init values
inits_RL <-function(){
    return (list(lr=runif(1),tau=runif(1,0,3)))
}
inits_lag <-function(){
    return (list(tau=runif(1,0,3)))
}
# loop over the subjects in a wave 
# create datalists for stan input

rstan_options(auto_write = TRUE)
options(mc.cores = 2)
RL <- "~/Documents/Allison'stask/model/bayesian/RL_loo.stan"
Random <- "~/Documents/Allison'stask/model/bayesian/random_loo.stan"
Lag <- "~/Documents/Allison'stask/model/bayesian/Lag_loo.stan"
nIter     <- 5000
nChains   <- 4
nWarmup   <- floor(nIter/2)
nWarmup_random   <- 0
nThin     <- 1
#p_matrix = matrix(0, nSubjects, 5) # probability matrix, the probability of the model better than random 
for (s in 42:nSubjects){
    save.image("~/Documents/Allison'stask/model/bayesian/results/W1_inprogress.RData")
    prob = rep(0,5)
    for (x in 1:nTrials[s]){
        dataList_fb <- list(nTrials=nTrials[s], 
                            choice= array(unlist(choice_game[s])),
                            reward=array(unlist(fb_list[s])),
                            trialX = x)
        dataList_min <- list(nTrials=nTrials[s], 
                             choice= array(unlist(choice_game[s])),
                             reward=array(unlist(minEff_r[s])),
                             trialX = x)
        dataList_max <- list(nTrials=nTrials[s], 
                             choice= array(unlist(choice_game[s])),
                             reward=array(unlist(maxEff_r[s])),
                             trialX = x)
        dataList_Lgame <- list(nTrials=nTrials[s], 
                               choice= array(unlist(choice_game[s])),
                               trialX = x)
        dataList_Lside <- list(nTrials=nTrials[s], 
                               choice= array(unlist(choice_side[s])),
                               trialX = x)
        dataList_random <- list(initQ = c(0,0),
                                nTrials=nTrials[s], 
                                choice= array(unlist(choice_game[s])),
                                trialX = x)
        
        fit_random <- stan(Random, 
                           data    = dataList_random, 
                           chains  = 1,
                           iter    = nIter,
                           warmup  = 0,
                           thin    = nThin,
                           algorithm = c("Fixed_param"),
                           verbose = FALSE,
                           control = list(adapt_delta = 0.99)
        )
        sink()
        rand_summary = summary(fit_random, pars = c("log_lik"))$summary
        log_lik_rand <- rand_summary[, c("mean")]
        
        fit_fb <- stan(RL, 
                       data    = dataList_fb, 
                       chains  = nChains,
                       iter    = nIter,
                       warmup  = nWarmup,
                       thin    = nThin,
                       init    = inits_RL,
                       verbose = FALSE,
                       control = list(adapt_delta = 0.99)
        )
        sink()
        fb_summary = summary(fit_fb, pars = c("log_lik"))$summary
        log_lik_fb <- fb_summary[, c("mean")]
        if (log_lik_fb>log_lik_rand) prob[1]=prob[1]+1
        Sys.sleep(0.5)
        
        fit_min <- stan(RL, 
                        data    = dataList_min, 
                        chains  = nChains,
                        iter    = nIter,
                        warmup  = nWarmup,
                        thin    = nThin,
                        init    = inits_RL,
                        verbose = FALSE,
                        control = list(adapt_delta = 0.99)
        )
        sink()
        min_summary = summary(fit_min, pars = c("log_lik"))$summary
        log_lik_min <- min_summary[, c("mean")]
        if (log_lik_min>log_lik_rand) prob[2]=prob[2]+1
        Sys.sleep(0.5)
        
        fit_max <- stan(RL, 
                        data    = dataList_max, 
                        chains  = nChains,
                        iter    = nIter,
                        warmup  = nWarmup,
                        thin    = nThin,
                        init    = inits_RL,
                        verbose = FALSE,
                        control = list(adapt_delta = 0.99)
        )
        sink()
        max_summary = summary(fit_max, pars = c("log_lik"))$summary
        log_lik_max <- max_summary[, c("mean")]
        if (log_lik_max>log_lik_rand) prob[3]=prob[3]+1
        Sys.sleep(0.5)
        
        fit_lg <- stan(Lag, 
                       data    = dataList_Lgame, 
                       chains  = nChains,
                       iter    = nIter,
                       warmup  = nWarmup,
                       thin    = nThin,
                       init    = inits_lag,
                       verbose = FALSE,
                       control = list(adapt_delta = 0.99)
        )
        sink()
        lg_summary = summary(fit_lg, pars = c("log_lik"))$summary
        log_lik_lg <- lg_summary[, c("mean")]
        if (log_lik_lg>log_lik_rand) prob[4]=prob[4]+1
        Sys.sleep(0.5)
        
        fit_ls <- stan(Lag, 
                       data    = dataList_Lside, 
                       chains  = nChains,
                       iter    = nIter,
                       warmup  = nWarmup,
                       thin    = nThin,
                       init    = inits_lag,
                       verbose = FALSE,
                       control = list(adapt_delta = 0.99)
        )
        sink()
        ls_summary = summary(fit_ls, pars = c("log_lik"))$summary
        log_lik_ls <- ls_summary[, c("mean")]
        if (log_lik_ls>log_lik_rand) prob[5]=prob[5]+1
        Sys.sleep(0.5)
    }
    t_prob = prob/nTrials[s]
    p_matrix[s,] = t_prob
}

write.csv(p_matrix, "w1.csv")
