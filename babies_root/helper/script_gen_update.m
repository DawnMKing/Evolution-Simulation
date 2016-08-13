function [] = script_gen_update(this_script,gen,base_name,run_name), 
if mod(gen,10)==0 && mod(gen,500)~=0,  fprintf(['gen %1.0f \n'],gen);  
elseif mod(gen,500)==0, fprintf([this_script ' for ' base_name run_name '\n' 'gen %1.0f \n'],gen); 
end
end