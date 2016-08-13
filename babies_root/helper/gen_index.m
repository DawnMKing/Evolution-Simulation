%% gen_index.m
% [u,v] = gen_index(population,gen)
% gets initial (u) and final (v) indices of population based data
% TIPS:
% can swap population for num_clusters for cluster based data
% omitting initial population also gets parent-like indices
%
function [u,v] = gen_index(population,gen), 
v = sum(population(1:gen));
u = v - population(gen) +1;
end