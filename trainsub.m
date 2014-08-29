function [subj results] = trainsub(subj)

    %% Neural network Back prop classifier
    class_args.train_funct_name = 'train_bp';
    class_args.test_funct_name = 'test_bp';
    class_args.alg = 'traincgb';
    class_args.nHidden = 200;
    class_args.showWindow = true;
    class_args.show = 100;
    class_args.epochs = 5000;
    class_args.goal = 0.01

    % run multiple train iteration (any iteration have n n minus one cross
    % validation)
    subj = init_object(subj,'regressors','classificationRegMat');
    [subj results] = runTrainIterations(subj, class_args, 5);
end

% run multiple train iteration (any iteration have n n minus one cross
% validation)
function [subj results] = runTrainIterations(subj, class_args, numOfIterations)

    results = [];
    
    selnames = find_group(subj,'selector', 'runs_xval');
    numOfTests = length(selnames);
    results.avg = zeros(numOfTests, 1);
    results.successTrainings = zeros(numOfIterations, numOfTests);
    
    for iteration = 1 : numOfIterations
        [subj results.resultsObjects{iteration}] = trainIteration(subj, class_args);
        
        for test = 1: numOfTests
             results.avg(test) = results.avg(test) + results.resultsObjects{iteration}.iterations(test).perf;
             results.successTrainings(iteration, test) = results.resultsObjects{iteration}.iterations(test).scratchpad.training_record.best_perf;
        end
    end 
    
    % calculate avg
    results.avg = results.avg ./ numOfIterations;
    results.successTrainings = results.successTrainings ./ numOfIterations;
end

function [subj results] = trainIteration(subj, class_args)
    
    global currentFeaturesMaskName;
    global performanceMethod;

    % Classification
    
    % Create the classification targets
    classificationRegMat = get_mat(subj,'regressors','conds_sh3');
    classificationRegMat = createClassificationRegressorsMatrix(classificationRegMat);
    subj = set_mat(subj,'regressors','classificationRegMat', classificationRegMat);

    % now, run the classification multiple times, training and testing
    % on different subsets of the data on each iteratio
    % using the binary preformance function and the new regs vector
    [subj results] = cross_validation(subj,'epi_z','classificationRegMat','runs_xval', currentFeaturesMaskName,class_args,'perfmet_functs',{performanceMethod}); 

end 