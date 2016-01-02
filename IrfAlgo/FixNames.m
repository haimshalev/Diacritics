load('snapshot.mat');

resultsKeys = resultsMap.keys();
previousMap = resultsMap;
currentCounter = 0;
resultsCounter = size(resultsKeys, 2);

regressorsFolder = '/home/haimshalev/Diacritics/Data/Regressors';
scansFolder = '/home/haimshalev/Diacritics/Data/Scans/ScansMatlabMatrices';
maskPath = '/home/haimshalev/Diacritics/Data/Mask/mask.mat';
featuresMaskPath = '/home/haimshalev/Diacritics/Data/Mask/featuresMask.mat';
irfDictionariesFolder = '/home/Data/Tali_Data/DiacriticsFramework/HaimShalevCode/DiacriticsIRFs_09.12.15/OutputFolder';

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
            
            % prapre all the needed data for classification
            [scans, regressors, irfDictionary] = PrapareClassifyRun(subject, run, irfFileLengthFolder, regressorsFolder, scansFolder, maskPath, featuresMaskPath, irfDictionariesFolder);
            
            % test all the previous size windows from 1 tr to the size of
            % the IRf
            for previousWindowSize = 1 : size(irfDictionary, 2)
                for startTr = 1 : size(irfDictionary,2)
                    for endTr = startTr : size(irfDictionary,2)
                       currentCounter = currentCounter + 1;
                       resultsMap([subject '.' run '.' irfFileLengthFolder '.' num2str(previousWindowSize) '.' num2str(startTr) '.' num2str(endTr)]) = ... 
                           previousMap(resultsKeys{currentCounter});
                    end
                end
            end
        end
    end
end