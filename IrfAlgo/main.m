clc
clear
disp ('Classification By Generation - Main Script');

%% Global Configuration
dataFolder = '/home/Data/HaimShalev/Data/';
regressorsFolder = [dataFolder 'Regressors'];
scansFolder = [dataFolder 'Scans/ScansMatlabMatrices'];
maskPath = [dataFolder 'Mask/mask.mat'];
testedConditions = [1 2];
classificationMode = 'Voting'; % 'Summing','Voting' or 'Classifier'

%% Selected Features Configurations 

%featuresFolder = [dataFolder 'Mask/FeaturesMasksForOneRun'];
featuresFolder = [dataFolder 'Mask/FeaturesMasksSubjectLevelCrossValidation'];
%featuresFolder = [dataFolder 'Mask/FeaturesUnionOrRunLevelsCrossValidation/'];
featureSelectionMode = false;

%% Selected Dictionary Configurations

irfsFolder = [dataFolder 'IRFs/'];

% for run level use - 
%irfDictionariesFolder = [irfsFolder 'OutputFolderRunLevel'];

% for subject level use
%irfDictionariesFolder = [irfsFolder 'OutputFolderSubjectLevel'];
irfDictionariesFolder = [irfsFolder 'OutputFolderSubjectLevelCrossValidation'];
%irfDictionariesFolder = [irfsFolder 'OutputFolderRunLevelCrossRun'];

%% Training Mode Configuration

LearningFolder = 'LearningData/';

% statistics gathering
trainStatistics = false;
StatisticsLearningOutputFolder = [LearningFolder 'Statistics2500/']; 
mkdir(StatisticsLearningOutputFolder);

% neural network classifiers
trainNeuralNetworkClassifiers = false;
createDataForNeuralNetworkTraining = false;
createNeuralNetworkClassifiers = false;
hiddenNeuralNetworkNeurons = 10;
NeuralNetworksLearningOutputFolder = [LearningFolder 'NeuralNetworkClassifier/'];
mkdir(NeuralNetworksLearningOutputFolder);
                   
%% Start of Main Script

% get all the subjects
subjects = GetDirectoriesInPath(scansFolder, '[0-9]{3,3}');

% initialize a results map container
resultsMap = containers.Map();

% go over each configuration
for subjectIdx = 1 : numel(subjects)      
    
    subject = char(subjects{subjectIdx});
    
    % get all the runs
    runs = GetDirectoriesInPath([scansFolder '/' subject], '[A-B][D]?[1-2]');
    
    for runIdx = 1 : numel(runs)
        
        run = char(runs{runIdx});
        
        % get all the irf lengths
        irfFileLengths = GetDirectoriesInPath(irfDictionariesFolder, 'IrfLength.[9]{1}');
        
        for irfFileLengthIdx = 1 : numel(irfFileLengths)              
            
            irfFileLengthFolder = char(irfFileLengths{irfFileLengthIdx});
            
           %% Feature Selection Mode - Read the scans and try to choose the features in other way then anova
           
            if (featureSelectionMode)
                if (~isempty(strfind(run,'1')))
                    trainingRun = strrep(run, '1', '2');
                else
                    trainingRun = strrep(run, '2', '1');
                end
                [scans, regressors, irfDictionary] = PrapareClassifyRun(subject, trainingRun, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, '', irfDictionariesFolder);

                disp(['Running feature selection data of subject ' subject 'run ' trainingRun 'irfLength ' irfFileLengthFolder]);
                [votingFeaturesVec] = FeatureSelection(scans, regressors, irfDictionary, testedConditions);
                
                disp('Creating unmasked version of the voting featuresMask');
                %votingFeaturesVec = CreateUnMaskedFeaturesVec(votingFeaturesVec, maskPath);
                    
                numFeatures = 2500;
                disp(['Creating features mask of size ' num2str(numFeatures)]);
                %featuresMask = CreateFeaturesMask(votingFeaturesVec, numFeatures);
                
                %disp(['Saving features of size ' mat2str(size(featuresMask)) ' to : /home/haimshalev/Diacritics/Data/Mask/FeatureSelection/' subject '/' run '/featuresMask.mat']);
                mkdir([featuresFolder '/' subject '/' run '/']);
                save([featuresFolder '/' subject '/' run '/votingFeaturesVec.mat'], 'votingFeaturesVec');
                %save([featuresFolder '/' subject '/' run '/featuresMask.mat'], 'featuresMask');
            
            else
           %% Classification Mode
                    
                 %% Gather Training Statistics
                   LearningOutputFolder = [StatisticsLearningOutputFolder subject '/' run '/'];
                   mkdir(LearningOutputFolder);
                   if (trainStatistics)
        
                       % go over all the other training runs
                           trainingRuns = cell(3,1);
                           if (~isempty(strfind(run,'1')))
                               trainingRuns{1} = strrep(run, '1', '2');
                           else
                               trainingRuns{1} = strrep(run, '2', '1');
                           end
                           if (~isempty(strfind(run,'A')))
                               trainingRuns{2} = strrep(run, 'A', 'B');
                           else
                               trainingRuns{2} = strrep(run, 'B', 'A');
                           end
                           trainingRuns{3} = strrep(trainingRuns{2}, run(length(run)), trainingRuns{1}(length(trainingRuns{1})));

                           sumCorrects = [];
                           sumTrials = 0;
                           for trainingRunIdx = 1 : numel(trainingRuns)

                               trainingRun = char(trainingRuns{trainingRunIdx});

                               % read the necessery data
                               [scans, regressors, irfDictionary, ~] = PrapareClassifyRun(subject, trainingRun, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder, run);
                               
                               % extract all the combinations information 
                               [corrects , trials] = GetAccurracyStaistics(scans, regressors, irfDictionary, testedConditions, 0, 1, size(irfDictionary,2), 'Voting');                              
                               
                               save([LearningOutputFolder trainingRun], 'corrects' , 'trials');

                               if (isempty(sumCorrects))
                                   sumCorrects = corrects;
                               else
                                   sumCorrects = sumCorrects + corrects;
                               end
                               sumTrials = sumTrials + trials;
                           end
                           
                           corrects = sumCorrects;
                           trials = sumTrials;
                           save([LearningOutputFolder 'statistics'], 'corrects' , 'trials');
                   else
                       load([LearningOutputFolder 'statistics']);
                   end    
                   
                 %% Training Mode
                   LearningOutputFolder = [NeuralNetworksLearningOutputFolder subject '/' run '/'];
                   mkdir(LearningOutputFolder);
                   if (trainNeuralNetworkClassifiers)
                       
                       if (createDataForNeuralNetworkTraining)
                           % go over all the other training runs
                           trainingRuns = cell(3,1);
                           if (~isempty(strfind(run,'1')))
                               trainingRuns{1} = strrep(run, '1', '2');
                           else
                               trainingRuns{1} = strrep(run, '2', '1');
                           end
                           if (~isempty(strfind(run,'A')))
                               trainingRuns{2} = strrep(run, 'A', 'B');
                           else
                               trainingRuns{2} = strrep(run, 'B', 'A');
                           end
                           trainingRuns{3} = strrep(trainingRuns{2}, run(length(run)), trainingRuns{1}(length(trainingRuns{1})));

                           dataPoints = cell(size(testedConditions));
                           targets = cell(size(testedConditions));
                           neuronsMask = ones(1, 2500); %TODO: Change the number!!!!!!!!!!!!!!!

                           unionFeatures = [];
                           for trainingRunIdx = 1 : numel(trainingRuns)

                               trainingRun = char(trainingRuns{trainingRunIdx});

                               % read the necessery data
                               [scans, regressors, irfDictionary, ~] = PrapareClassifyRun(subject, trainingRun, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder);
                               
                               % extract all the combinations information 
                               [runDataPoints, runTargets , runNeuronsMask] = CreateDataForTrainingClassifier(scans, regressors, irfDictionary, testedConditions, 0, 1, size(irfDictionary,2), 'Voting');                              
                               
                               save([LearningOutputFolder trainingRun], 'runDataPoints', 'runTargets', 'runNeuronsMask');

                               % union them to the full data store for training
                               neuronsMask = neuronsMask & runNeuronsMask;
                               for conditionIdx = 1 : numel(testedConditions)
                                   dataPoints{conditionIdx} = [ dataPoints{conditionIdx}  runDataPoints{conditionIdx}'];
                                   targets{conditionIdx} = [ targets{conditionIdx}  runTargets{conditionIdx}'];
                               end
                           end
                           
                           save([LearningOutputFolder 'dataPoints'], 'dataPoints', 'targets', 'neuronsMask');
                       else
                           load([LearningOutputFolder 'dataPoints']);
                       end
                       
                       if (createNeuralNetworkClassifiers)
                           % train a stuck of classifiers, one for each condition, that each data point will
                           % be the vector x = [correlation to feature 1 : n]  and
                           % t = {1 , -1} where t will be 1 if this training vector
                           % yield the correct answer and -1 otherwise, Then we
                           % will be able to use this classifiers to choose what
                           % are the condition that his classifier get the most
                           % answers correctly
                           
                           classifiers = cell(size(testedConditions));
                           tr = cell(size(testedConditions));
                           for conditionIdx = 1 : numel(testedConditions)

                               data = dataPoints{conditionIdx}(:, 1 : ceil(size(dataPoints{conditionIdx},2))); 
                               target = targets{conditionIdx}(:, 1 : ceil(size(targets{conditionIdx},2)));
                               data(~neuronsMask,:) = [];
                               if (hiddenNeuralNetworkNeurons > 0)
                                classifiers{conditionIdx} = fitnet(hiddenNeuralNetworkNeurons);
                               else
                                classifiers{conditionIdx} = perceptron;
                               end
                               [classifiers{conditionIdx},tr{conditionIdx}] = train(classifiers{conditionIdx}, data, target);

                           end

                           save([LearningOutputFolder 'classifiers' num2str(hiddenNeuralNetworkNeurons)], 'classifiers', 'tr');
                       else
                           load([LearningOutputFolder 'classifiers' num2str(hiddenNeuralNetworkNeurons)]);
                       end
                   else
                      load([LearningOutputFolder 'dataPoints']);
                      load([LearningOutputFolder 'classifiers' num2str(hiddenNeuralNetworkNeurons)]); 
                   end    
                   
              %% Classification Code
                              
                %prapre all the needed data for classification
                [scans, regressors, irfDictionary] = PrapareClassifyRun(subject, run, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder);

                % test all the previous size windows from 1 tr to the size of
                % the IRf
                %for previousWindowSize = 1 : size(irfDictionary, 2)
                for previousWindowSize = 0 : 0
                    %for startTr = 1 : size(irfDictionary,2)
                    for startTr = 1 : 1
                        %for endTr = startTr : size(irfDictionary,2)
                        for endTr = size(irfDictionary,2) : size(irfDictionary,2)
                            % classify the data
                            disp(['Classifying data of subject ' subject 'run ' run 'irfLength ' irfFileLengthFolder]);
                            %[classificationRes, confusionMatrix] = ClassifyData(scans, regressors, irfDictionary, testedConditions, previousWindowSize, startTr, endTr, ...
                            %                                       classificationMode, struct('classifiers', {classifiers}, 'classifierNeuronsMask' ,neuronsMask));
                            
                            [classificationRes, confusionMatrix] = ClassifyData(scans, regressors, irfDictionary, testedConditions, previousWindowSize, startTr, endTr, ...
                                                                    classificationMode, struct('stats', corrects ./ trials));

                            % update the results map

                            resultsMap([subject '.' run '.' irfFileLengthFolder '.' num2str(previousWindowSize) '.' num2str(startTr) '.' num2str(endTr)]) = ... 
                               containers.Map( ...
                                   {'confusionMatrix', 'classificationAccurracy' , 'classificationRes' , 'originialRegressors'},...
                                   {confusionMatrix, computeConfusionMatrixAccurracy(confusionMatrix), classificationRes, regressors});
                        end
                    end
                end
            end
        end
    end
end

disp('Execution ended. Please see the resultsMap object for the results of all configurations');
clearvars -except resultsMap
save('resultsMap');
