%% build_num_descendants.m
% function [num_descendants] = build_num_descendants(base_name,run_name)
% This uses population and parents data to determine the number of
% descendants of the original IPOP population for each generation. The
% output, num_descendants, is organized as a matrix with IPOP rows and NGEN
% columns. It provides a head count for each lineage (from top to bottom) in time 
% (from left to right).
function [num_descendants] = build_num_descendants(base_name,run_name), 
global SIMOPTS;
num_descendants = [];
this_script = 'build_num_descendants';
% fprintf([this_script '\n']);
if exist([make_data_name('num_descendants_',base_name,run_name,0) '.mat'])~=2 || ...
   SIMOPTS.write_over==1, 
go = 1;
[par,go,error] = try_catch_load(['parents_' base_name run_name],go);
if go==1, [pop,go,error] = try_catch_load(['population_' base_name run_name],go);
if go==1,             
  fprintf([this_script ' for ' base_name run_name '\n']);
  population = pop.population;  clear pop
  parents = par.parents;  clear par

  ngen = length(find(population>=SIMOPTS.limit));
  ipop = population(1);
  num_descendants = zeros(ipop,ngen-1);
%% debug test variables
% population = [6 8 7 4];
% parents = [1 2 2 4 5 5 6 6, 2 3 5 5 6 6 8, 4 4 5 7]';
% ngen = length(population);
% ipop = population(1);
% num_descendants = zeros(ipop,ngen-1);
% expect num_descendants = [1 2 0 1 2 2; 0 2 0 1 4 1]'
%% algorithm start
  for indiv = 1:ipop
%       indiv_update(indiv);
    old_orgs = indiv
    pars = old_orgs
    u = 0;  v = 0;
    pu = 0; pv = 0;
    num_pars = zeros(1,ngen-1);
    gen = 1;
    while ~isempty(old_orgs) && gen<ngen, 
      gen = gen +1;
      pu = pv +1; pv = sum(population(2:gen));
      pars_of_next_gen = parents(pu:pv);
      new_orgs = [];
      for i = 1:length(old_orgs), 
        new_orgs = [new_orgs; find(pars_of_next_gen==old_orgs(i))'];
      end
      num_descendants(indiv,gen-1) = length(new_orgs)
      old_orgs = new_orgs;
    end
  end
%% algorithm end
  save(make_data_name('num_descendants',base_name,run_name,0),...
                      'num_descendants');
end %population
end %parents
end %exists
end %function