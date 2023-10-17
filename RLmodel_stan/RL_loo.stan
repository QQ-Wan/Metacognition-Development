data {
  int<lower=1> nTrials;
  int<lower=1,upper=2> choice[nTrials];
  real<lower=0> reward[nTrials];
}

transformed data {
  vector[2] initV; // initial values for V
  vector[2] initL; // initial values for Lag
  initV = rep_vector(0.0, 2);
  initL = rep_vector(0.0, 2);
}

parameters {
  real<lower=0, upper=1> lr; // learning rate
  real<lower=0, upper=20> beta; // inverse temperature
  real<lower=0, upper=1> phi; // weight between V and Lag
}

model {
  vector[2] v;
  vector[2] l;
  real pe;
  v = initV;
  l = initL;
  
  for (t in 1:nTrials) {
    choice[t] ~ categorical_logit(beta * (v * (1 - phi) + l * phi));
    pe = reward[t] - v[choice[t]];
    v[choice[t]] += lr * pe;
    
    // Update the lag
    l = l + 1;
    l[choice[t]] = 1;
  }
}

generated quantities {
  real log_lik[nTrials]; // Log-likelihood for each trial
  vector[2] v;
  vector[2] l;
  real pe;
  v = initV;
  l = initL;
  
  for (t in 1:nTrials) {
    log_lik[t] = categorical_logit_lpmf(choice[t] | beta * (v * (1 - phi) + l * phi));
    pe = reward[t] - v[choice[t]];
    v[choice[t]] += lr * pe;
    
    // Update the lag
    l = l + 1;
    l[choice[t]] = 1;
  }
}
