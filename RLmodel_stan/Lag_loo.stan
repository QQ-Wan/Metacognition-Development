data {
  int<lower=1> nTrials;
  int<lower=1,upper=2> choice[nTrials];  
  int<lower=1> trialX;
}

transformed data {
  vector[2] initQ;  // initial values for Lag
  initQ = rep_vector(0.0, 2);
}

parameters {
  real<lower=0,upper=20> tau;  
}

model {
  vector[2] lag; 
  lag = initQ;

  for (t in 1:nTrials) {
    if (t != trialX){
      choice[t] ~ categorical_logit( tau * lag );
      lag = lag+1;
      lag[choice[t]]=1;
    }
  }
}

generated quantities {
  vector[2] lag; 
  real log_lik;
  lag = initQ;
  
  for (t in 1:nTrials) {
    if (t == trialX){
      log_lik = categorical_logit_lpmf(choice[trialX] | tau * lag);
      lag = lag+1;
      lag[choice[trialX]]=1;
    }else{
      lag = lag+1;
      lag[choice[t]]=1;
    }
  }
}


