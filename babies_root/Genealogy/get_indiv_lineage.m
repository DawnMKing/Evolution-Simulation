%% get_indiv_lineage.m
%
this_script = 'get_indiv_lineage';
fprintf([this_script '\n']);
global SIMOPTS;
% close all;
for op = overpop, SIMOPTS.op = op;
for dm = death_max, SIMOPTS.dm = dm;
for mu = mutability, SIMOPTS.mu = mu;
  make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
  for run = SIMS
    run_name = int2str(run);
    if exist([make_data_name('num_descendants',base_name,run_name,0) '.mat'])~=2, 
    go = 1;
    [par,go,error] = try_catch_load(['parents_' base_name run_name],go);
    if go==1, [pop,go,error] = try_catch_load(['population_' base_name run_name],go);
    if go==1,             
      fprintf([this_script ' for ' base_name run_name '\n']);
      population = pop.population;  clear pop
      parents = par.parents;  clear par

      ngen = length(find(population>=limit));
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
        indiv_update(indiv);
        old_orgs = indiv;
        pars = old_orgs;
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
          num_descendants(indiv,gen-1) = length(new_orgs);
          old_orgs = new_orgs;
        end
      end
%% algorithm end
      save(make_data_name('num_descendants',base_name,run_name,0),...
                          'num_descendants');
%     else
%       load(make_data_name('num_descendants',base_name,run_name,0));
    end
    end
      if do_descendants_mesh==1
        figure(mu*1000 +run); mesh(num_descendants);  title(make_title_name(base_name,run_name));
        xlabel('generation'); ylabel('ancestor'); zlabel('num\_descendants');
      end
    end
  end
end
end
end