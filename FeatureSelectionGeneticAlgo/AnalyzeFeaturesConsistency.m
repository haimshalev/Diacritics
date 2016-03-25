entireRunsFeaturesFolderPath = '/home/haimshalev/Diacritics/CodeFromNoName/Output/FeaturesMasksForEntireRun';
oneRunFeaturesFolderPath = '/home/haimshalev/Diacritics/CodeFromNoName/Output/FeaturesMasksForOneRun';

DiacriticalRuns = {'AD1','AD2','BD1','BD2'};
NonDiacriticalRuns = {'A1','A2','B1','B2'};

amountUnitedVsEntire = [];
amountUnitedVsCorrect = [];
amountEntireVsCorrect = [];

subjects = GetDirectoriesInPath(entireRunsFeaturesFolderPath, '[0-9]{3,3}');

for subjectIdx = 1 : numel(subjects)      
    subject = char(subjects{subjectIdx});
    
    runs = GetDirectoriesInPath([entireRunsFeaturesFolderPath '/' subject], '[A-B][D]?[1-2]');
    for runIdx = 1 : numel(runs)
        run = char(runs{runIdx});
        
            disp(['Analyzing run of : ' subject ' ' run]);
            
            if (ismember(run,DiacriticalRuns)) % diacritical run
                RunsToUnion = setdiff(DiacriticalRuns, {run});               
            else % non diacritical run
                RunsToUnion = setdiff(DiacriticalRuns, {run});
            end
            
            % load the entire runs mask
            entireRuns = load([entireRunsFeaturesFolderPath '/' subject '/' run '/featuresMask']);
            entireRuns = entireRuns.mask;
            
            % load the current tested run mask (this is the best mask, the one that allow us to classify in the run level)
            runLevel = load([oneRunFeaturesFolderPath '/' subject '/' run '/featuresMask']);
            runLevel = runLevel.mask;
            
            %load all the runs and unite them 
            unitedMask = zeros(size(entireRuns));
            for runToUniteIdx = 1: numel(RunsToUnion)
                runToUnite = char(RunsToUnion{runToUniteIdx});
                mask = load([oneRunFeaturesFolderPath '/' subject '/' runToUnite '/featuresMask']);
                unitedMask = unitedMask | mask.mask;
            end
            
            disp(['number of consistent features for run ' run ' with union of runs ' RunsToUnion ' is : ' num2str(count(unitedMask & entireRuns))]);
            amountUnitedVsEntire = [amountUnitedVsEntire count(unitedMask & entireRuns)];
            amountUnitedVsCorrect = [amountUnitedVsCorrect count(unitedMask & runLevel)];
            amountEntireVsCorrect = [amountEntireVsCorrect count(entireRuns & runLevel)];
            
            disp(['number of good features for run ' run ' with union of runs ' RunsToUnion ' is : ' num2str(count(unitedMask & runLevel))]);
            disp(['number of good features for run ' run ' with entireRunsSelection is : ' num2str(count(entireRuns & runLevel))]);
    end
end

disp(['mean amount of consistent voxels between two methods : ' num2str(mean(amountUnitedVsEntire)) ' with std of ' num2str(std(amountUnitedVsEntire))]);
disp(['mean amount of correct voxels in the union procedure : ' num2str(mean(amountUnitedVsCorrect)) ' with std of ' num2str(std(amountUnitedVsCorrect))]);
disp(['mean amount of correct voxels in the entire run procedure : ' num2str(mean(amountEntireVsCorrect)) ' with std of ' num2str(std(amountEntireVsCorrect))]);