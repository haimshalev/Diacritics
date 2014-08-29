function results = testsub(trainResults)

% Create a function handle for the classifier testing function
test_funct_hand = str2func('test_bp');

% Call whichever testing function
[acts scratchpad] = test_funct_hand(testpats,testtargs, trainResults.scratchpad);  

% Get the name of the perfmet function
cur_pm_name = 'perfmet_maxclass'; %args.perfmet_functs{p}; - Using default

% Create a function handle to it
cur_pm_fh = str2func(cur_pm_name);

% Run the perfmet function and get an object back
cur_pm = cur_pm_fh(acts,testtargs,scratchpad,[]);

results = cur_pm;
end