%matlab function that takes no arguments
%returns the value of p_s (probability that the sprinkler was on given the grass is wet)
function p_s = lab8_dbn()

%%specify the network topology- the observed value is grass wet, the latent is sprinkler
%intra specifies the within-time-slice connections between nodes
%for part 1 of this assignment we will only be dealing with a single time slice
intra = zeros(2); %adjacency matrix
intra(1,2) = 1; %node 1 (sprinkler) in timeslice t connects to node 2 (grass wet) in timeslice t

%inter specifies the relationship between nodes in time slice n and time slice n+1.
%for part 1, we are only modifying one time slice so we specify that there are no connections between time slices
inter = zeros(2);

%specify parameters
S = 2; % num sprinkler states (sprinkler can be True (2) or False (1))
G = 2; % num grass-wet states (grass wet can be True (2) or False (1))

ns = [S G]; %defines the number of possible states for each node
dnodes = 1:2; %list the discrete (non-continuous) nodes (all)
onodes = 1:2; %list the observable nodes (all)

%define 'equivalence classes', which are the nodes that share the same conditional probabilities
eclass1 = [1 2]; % eclass 1 holds the equivalence classes of each node in the first time slice
eclass2 = [1 2]; % eclass 2 holds the equivalence classes of each node in the second time slice (we only have one time slice in this example)

%create the dbn network
bnet = mk_dbn(intra, inter, ns, 'discrete', dnodes, 'eclass1', eclass1, 'eclass2', eclass2, 'observed', onodes);

%%define the conditional probabilities
%the prior probability that sprinkler = True is 0.7
%the probability that grass wet = True | sprinkler = True is 0.95
%the probability that grass wet = True | sprinkler = False is 0.4
sprinkler_prior = 0.7;
grass_wet_sprinkler = 0.95;
grass_wet_no_sprinkler = 0.4;

%% create the conditional probabilities for each equivalence class
%% Read the 'Creating your first bayes net' section of the bnt toolbox documentation to understand how to define the conditional probability table

%define the conditional probabilities for eclass1, which represents the prior for the sprinkler node in time slice 1
bnet.CPD{1} = tabular_CPD(bnet, bnet.rep_of_eclass(1), 'CPT', [1-sprinkler_prior sprinkler_prior]);
%define the conditional probabilities for eclass2, which represents the probabilities of the grass being wet given the sprinkler status
bnet.CPD{2} = tabular_CPD(bnet, bnet.rep_of_eclass(2), 'CPT', [1-grass_wet_no_sprinkler 1-grass_wet_sprinkler grass_wet_no_sprinkler grass_wet_sprinkler]);

%create the inference engine
engine = jtree_dbn_inf_engine(bnet);

%now we pose a query to our network
%calculate the probability that the sprinkler was on given the grass is wet
evidence = cell(bnet.nnodes_per_slice,2); %evidence is stored in a matlab cell. The 2nd dimension is the number of time slinces. Even though we are only working with 1 time splace, this code requires we specify at least 2 time slices (but we'll only populate the first one)
%evidence{2, 1} = 2; %node 2 at time slice 1 is equal to 2 (grass_wet = True). In the evidence array, value 1 = Fales, value 2 = True.
evidence{1, 1} = 2; % sprinkler = True at time slice 1

[engine, ll] = enter_evidence(engine, evidence); %perform inference - get answer to our query
%P = marginal_nodes(engine,1,1); %get the probabilities for the sprinkler node (node 1) at first timeslice
P = marginal_nodes(engine, 2, 1); % get the probabilities for the grass_wet node
%p_s = P.T(2); %probability that sprinkler = True
p_s = P.T(1); % probability that grass_wet = False



