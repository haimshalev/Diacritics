clc
clear
disp ('Permutation IRF algorithm');

regressorsFolder = '/home/haimshalev/Diacritics/Data/Regressors';
scansFolder = '/home/haimshalev/Diacritics/Data/Scans/ScansMatlabMatrices';
maskPath = '/home/haimshalev/Diacritics/Data/Mask/mask.mat';
%featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeaturesRunLevel';
featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeaturesMasksSubjectLevelCrossValidation';
%featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeatureSelection2';
featureSelectionMode = false;
testedConditions = [1 2];
classificationMode = 'Classifier'; % 'Summing','Voting' or 'Classifier'

% for run level use
%irfDictionariesFolder = '/home/Data/Tali_Data/DiacriticsFramework/HaimShalevCode/DiacriticsIRFs_09.12.15/OutputFolderRunLevel';

% for subject level use
%irfDictionariesFolder = '/home/haimshalev/Diacritics/Data/IRFs/OutputFolderSubjectLevel/';
irfDictionariesFolder = '/home/haimshalev/Diacritics/Data/IRFs/OutputFolderSubjectLevelCrossValidation';
%irfDictionariesFolder = '/home/Data/Tali_Data/DiacriticsFramework/HaimShalevCode/DiacriticsIRFs_09.12.15/OutputFolderRunLevelCrossRun';

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
            
            % feature selection
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

                %% first we want to train a classifier
                   trainClassifiers = false;
                   createData = false;
                   createClassifiers = false;
                   hiddenNeurons = 10;
                   runLearningOutputFolder = ['LearningData/' subject '/' run '/'];
                   mkdir(runLearningOutputFolder);
                   
                   if (trainClassifiers)
                       
                       if (createData)
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

                           for trainingRunIdx = 1 : numel(trainingRuns)

                               trainingRun = char(trainingRuns{trainingRunIdx});

                               % read the necessery data
                               [scans, regressors, irfDictionary] = PrapareClassifyRun(subject, trainingRun, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder);

                               % extract all the combinations information 
                               [runDataPoints, runTargets , runNeuronsMask] = CreateDataForTrainingClassifier(scans, regressors, irfDictionary, testedConditions, 0, 1, size(irfDictionary,2), 'Voting');

                               save([runLearningOutputFolder trainingRun], 'runDataPoints', 'runTargets', 'runNeuronsMask');

                               % union them to the full data store for training
                               neuronsMask = neuronsMask & runNeuronsMask;
                               for conditionIdx = 1 : numel(testedConditions)
                                   dataPoints{conditionIdx} = [ dataPoints{conditionIdx}  runDataPoints{conditionIdx}'];
                                   targets{conditionIdx} = [ targets{conditionIdx}  runTargets{conditionIdx}'];
                               end
                           end

                           save([runLearningOutputFolder 'dataPoints'], 'dataPoints', 'targets', 'neuronsMask');
                       else
                           load([runLearningOutputFolder 'dataPoints']);
                       end
                       
                       if (createClassifiers)
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
                               if (hiddenNeurons > 0)
                                classifiers{conditionIdx} = fitnet(hiddenNeurons);
                               else
                                classifiers{conditionIdx} = perceptron;
                               end
                               [classifiers{conditionIdx},tr{conditionIdx}] = train(classifiers{conditionIdx}, data, target);

                           end

                           save([runLearningOutputFolder 'classifiers' num2str(hiddenNeurons)], 'classifiers', 'tr');
                       else
                           load([runLearningOutputFolder 'classifiers' num2str(hiddenNeurons)]);
                       end
                   else
                      load([runLearningOutputFolder 'dataPoints']);
                      load([runLearningOutputFolder 'classifiers' num2str(hiddenNeurons)]); 
                   end    
                   
              %% Classify the current run 
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
                            [classificationRes, confusionMatrix] = ClassifyData(scans, regressors, irfDictionary, testedConditions, previousWindowSize, startTr, endTr, ...
                                                                    classificationMode, struct('classifiers', {classifiers}, 'classifierNeuronsMask' ,neuronsMask));

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
