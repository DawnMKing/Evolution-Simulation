function [] = save_lifetimes(base_name)
global lifetimes;
lt_name = ['lifetimes_' base_name(1:end-1)];
save(lt_name,'lifetimes');
end