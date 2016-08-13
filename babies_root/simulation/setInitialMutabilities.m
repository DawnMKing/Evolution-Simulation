%% setInitialMutabilities.m
% [bnrange] = setInitialMutabilities(SIMOPTS)
% Sets up the mutability(ies) of the initial population
% Inputs:
% IPOP = initial population size
% bnoise = mutability for single mu simulations (arranged [mu1 pop, mu2 pop; mu1 mu2])
% exp_type = experiment type
% range = max range of mutabilities for competition
% bi = two mutabilities and their initial populations
% Output:
% bnrange = column vector of each indiv's mutability
function [bnrange] = setInitialMutabilities()
global SIMOPTS;
if SIMOPTS.exp_type==0 || SIMOPTS.exp_type==3,  %no competition (all get same mutability)
  bnrange = SIMOPTS.mu*ones(SIMOPTS.IPOP,1);
elseif SIMOPTS.exp_type==1,  %competition (assign random mutability within range, r)
  bnrange = SIMOPTS.range*rand(SIMOPTS.IPOP,1);
elseif SIMOPTS.exp_type==2,  %two competitors
  bnrange = SIMOPTS.bi(1,1)*ones(SIMOPTS.bi(2,1),1);
  bnrange = [bnrange; SIMOPTS.bi(1,2)*ones(SIMOPTS.bi(2,2),1)];
end
end