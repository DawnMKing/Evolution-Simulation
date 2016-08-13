# Evolution-Simulation
Agent-based Evolution Simulation Overview
  These files contain all the necessary code to run an evolution simulation. The simulation starts with an intial population distribution on a 2D landscape (that is the size of your choice i.e. 25X25 arbitrary units). Digital organisms can either sexually or asexually reproduce based off the choosen simulation reproduction scheme. Offspring are generated and they diffuse on the space depending on the condition of mutation parameter. Each generation is then subjected to a series of death processes before the next generation can reproduce. The simulation saves a variety of data (discussed in more detail below) that can later be analysized. The simulation outputs large data sets that requires data management, thus the simulation also contains custom-written code to tag and organize data files that are based on the particlular parameter of the simulation. The analysis code uses the tagging system to locate and identify particular data. 

Outline of simulation files.
#main_babies.m
  Primary simulation file. Here you set all the parameters and type of simualtion that you want to run, such as reproduction scheme, intial population size, mutability, death percentages, flat or varying fitness landscapes, number of generations or simulations to run, etc. Can choose to run simulation, clustering, and genealogical loops depending on the data needed. All files are commented. 
#Simulations.m
  Main simulation loop (i.e. does loop for simulation ran), looks for preexisting data if prompted. The simulation loop has passes to functions: 1. NameAndCD.m, which creates the output data filenames based off of global parameters set in main_babies.m, it also creates a directory name for input and output data. 2. setInitialMutabilies.m, outputs mutability values for each individual in intial population. 3. Generations.m, main generation loop for each simulation (the number of generations in each simulation is choosen in main_babies.m), this outputs all generational data such as population size, number of clusters, etc. 4. RecordData.m, saves all data generated data for each simulation with specific files names and in specified directory locations created by NameAndCD.m.
#NameAndCD.m
  creates data file names and directory names based off the global variables set in the main_babies.m 
#setInitialMutabilites.m
  Set intial mutation values for each individual in the initial population
#Generations.m
  Main generation Loop. Ouputs generational population size, each individuals x-and y-coordinates, each individuals parents, clustering seeds (who mated with whom), distances between mates, who was killed in each generation.  Functions in loop appear in this order: FindMates.m, MakeBabies.m, OverpopulationDeath.m, RandomDeath.m, CliffJumpers.m, AdjustLandscape.m.
#FindMates.m, locates mates based off of choosen reproduction scheme (assortative mating, nearest-neighbor mates), random mates.
#MakeBabies.m, diperse offspring depending on mutation parameter and reproduction scheme, same number of osspring for each parent if flat-fitness landscape, or different number of offspring for each parent if a varying fitness landscape
#OverpopulationDeath.m, kills offspring if within a defined distance of one another
#RandomDeath.m, kills random pernetage of ofspring either with either predefined percentage in each generation or upto a certain   percentage in each generation.
#CliffJumpers.m, kills organisms if the fall off of the predefined landscape boundary
#AjdustLandscape.m, change the fitness landscape (only if using a varying fitness landscape, will pass if on a flat fitness         landscape).
    
  #Clustering.m
    Main clustering loop. It contains conditional functions build_cluster_seeds.m, build_clusters.m, locate clusters.m, depending on the generated data needed.
  
