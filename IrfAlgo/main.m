clc
clear
disp ('Permutation IRF algorithm');



regressorsFolder = '/home/haimshalev/Diacritics/Data/Regressors';
scansFolder = '/home/haimshalev/Diacritics/Data/Scans/ScansMatlabMatrices';
maskPath = '/home/haimshalev/Diacritics/Data/Mask/mask.mat';
%featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeaturesRunLevel';
%featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeaturesMasksSubjectLevelCrossValidation';
featuresFolder = '/home/haimshalev/Diacritics/Data/Mask/FeatureSelection2';
featureSelectionMode = true;

% for run level use
irfDictionariesFolder = '/home/Data/Tali_Data/DiacriticsFramework/HaimShalevCode/DiacriticsIRFs_09.12.15/OutputFolderRunLevel';

% for subject level use
%irfDictionariesFolder = '/home/haimshalev/Diacritics/Data/IRFs/OutputFolderSubjectLevel/';
%irfDictionariesFolder = '/home/haimshalev/Diacritics/Data/IRFs/OutputFolderSubjectLevelCrossValidation';
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
                [votingFeaturesVec] = FeatureSelection(scans, regressors, irfDictionary, [1 2]);
                
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
                % prapre all the needed data for classification
                [scans, regressors, irfDictionary] = PrapareClassifyRun(subject, run, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresFolder, irfDictionariesFolder);

                % test all the previous size windows from 1 tr to the size of
                % the IRf
                %for previousWindowSize = 1 : size(irfDictionary, 2)
                for previousWindowSize = 1 : 1
                    %for startTr = 1 : size(irfDictionary,2)
                    for startTr = 1 : 1
                        %for endTr = startTr : size(irfDictionary,2)
                        for endTr = size(irfDictionary,2) : size(irfDictionary,2)
                            % classify the data
                            disp(['Classifying data of subject ' subject 'run ' run 'irfLength ' irfFileLengthFolder]);
                            [classificationRes, confusionMatrix] = ClassifyData(scans, regressors, irfDictionary, [1 3], previousWindowSize, startTr, endTr);

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
