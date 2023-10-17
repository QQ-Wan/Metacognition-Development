data {
  vector[2] initQ;
  int<lower=1> nTrials;
  int<lower=1,upper=2> choice[nTrials]; 
}

model {
    
}

generated quantities {
  real log_lik[nTrials];
  for (t in 1:nTrials) {
    log_lik[t] = categorical_logit_lpmf(choice[t] | initQ);
  }
}


