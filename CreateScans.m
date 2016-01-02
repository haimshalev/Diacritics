clc
disp ('Create scans matlab m files');
mvpa_add_paths;
scansFolder = '/home/haimshalev/Diacritics/Data/Scans/ConvertedAfniDataWithout3dDeconvolveWithout3dRefit';

testFolderKinds = {'Diacritics', 'WithoutDiacritics'};

for testKindIdx = 1 : numel(testFolderKinds)

    testKind = char(testFolderKinds{testKindIdx});
    
    % get all the subjects
    subjects = GetDirectoriesInPath([scansFolder '/' testKind], '[0-9]{3,3}');

    % go over each configuration
    for subjectIdx = 1 : numel(subjects)      

        subject = char(subjects{subjectIdx});
        subjectFolder = [scansFolder '/' testKind '/' subject '/'];
                 
        runAfniFiles = strcat(subjectFolder ,getallfiles(subjectFolder, '.BRIK'));
        
        for runNameIdx = 1: numel(runAfniFiles)
        
            runPath = char(runAfniFiles{runNameIdx});
            runName = strsplit(runPath,'dataset');
            runName = strsplit(runName{2}, '+tlrc');
            runName = runName{1};
            
            disp(['Working on directory ' testKind ' on subject ' subject ' on run ' runName]);
            
            initialSubj = init_subj('Diacritics', subject);
            initialSubj = load_afni_mask(initialSubj,'Subj-Mask', '/home/haimshalev/Diacritics/Data/Mask/afnimask+tlrc'); 
            initialSubj = load_afni_pattern(initialSubj,'epi','Subj-Mask', runPath);

            scans = initialSubj.patterns{1, 1}.mat;
            mkdir(subject);
            mkdir([subject '/' runName]);
            save([subject '/' runName '/scans.mat'], 'scans');
        end
    end
end

disp('Execution ended. Please see the scans folders');
clear