this_script = 'make_seed_distances';
fprintf([this_script '\n']);
land_limit = ((((max(basic_map_size)*2)-1)*2)-1);
try_limits = [   1   2   4   8    16  land_limit*ones(1,2)]'*ones(1,2); %limits 
dc_limits =  [0 1.5 2.9 5.7 11.4 22.7  land_limit*ones(1,3)]'*ones(1,2); %double check limits

for op = overpop, SIMOPTS.op = op;
for dm = death_max, SIMOPTS.dm = dm;
for mu = mutability, SIMOPTS.mu = mu;
  make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
  for run = SIMS
    run_name = int2str(run);
    fprintf([this_script ' for ' base_name run_name '\n']);
    go = 1;
    if exist([make_data_name('seed_distances',base_name,run_name,0) '.mat'])~=2, 
    [p,go] = try_catch_load(['population_' base_name run_name],go,1);
    if go==1, 
      population = p.population; clear p
      load(['trace_x_' base_name run_name]);
      load(['trace_y_' base_name run_name]);
      if exist(['trace_cluster_seed_' base_name run_name '.mat'])~=2, 
        tcs_not_exist = 1;
        trace_cluster_seed = zeros(sum(population),2);
      else, tcs_not_exist = 0;  load(['trace_cluster_seed_' base_name run_name]); end
      ngen = length(population);
      u = int32(0);  v = int32(0);
      seed_distances = zeros(sum(population),2); %initialize the mate-and-cluster variable (MNC) for this generation
      for gen = 1:ngen
        u = int32(v +1);
        v = int32(sum(population(1:gen)));
        babies = [];
        babies = [trace_x(u:v) trace_y(u:v)];
        for i=1:population(gen) %for each baby
          this_coord = [babies(i,1) babies(i,2)]; %[x y]
          if tcs_not_exist==1, 
            j = 0;  last = 0; double_checked = 0;
            while seed_distances(i+u-1,2)==0 && double_checked==0
              j = j +1;
              if last==0
                try_coords = [this_coord+try_limits(j,:); this_coord-try_limits(j,:)]; %determine search area
              else
                try_coords = [this_coord+dc_limits(j,:); this_coord-dc_limits(j,:)]; %determine search area
              end
              try_these = find((babies(:,1)>try_coords(2,1) & babies(:,1)<try_coords(1,1) & ...
                babies(:,2)>try_coords(2,2) & babies(:,2)<try_coords(1,2))); %find possible neighbors
              if length(try_these)>3
                if last==0
                  last = 1;
                else
                  distance = (babies(try_these,1)-babies(i,1)).^2 + ...
                    (babies(try_these,2)-babies(i,2)).^2; %find the distance to all other babies
                  [sort_distance I] = sort(distance); %sort the distances
                  seed_distances(i+u-1,1) = sqrt(sort_distance(2));
                  seed_distances(i+u-1,2) = sqrt(sort_distance(3));
                  if tcs_not_exist==1, 
                    trace_cluster_seed(i+u-1,1) = I(2);
                    trace_cluster_seed(i+u-1,2) = I(3);
                  end
                  double_checked = 1;
                end
              end
            end
          else, 
            nearest = int32(trace_cluster_seed(i+u-1,1));
            nx = trace_x(nearest-1+u);  ny = trace_y(nearest-1+u);
            seed_distances(i+u-1,1) = sqrt((this_coord(1) -nx).^2 +(this_coord(2) -ny).^2);
            second = int32(trace_cluster_seed(i+u-1,2));
            sx = trace_x(second-1+u);  sy = trace_y(second-1+u);
            seed_distances(i+u-1,2) = sqrt((this_coord(1) -sx).^2 +(this_coord(2) -sy).^2);
          end
        end
      end %end of assigning mates
      if tcs_not_exist==1, 
        save(['trace_cluster_seed_' base_name run_name],'trace_cluster_seed');
      end
      save(['seed_distances_' base_name run_name],'seed_distances');
    end
    end
  end
end
end
end