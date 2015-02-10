mask = logical(get_mat(subj001, 'mask', 'Subj-Mask'));

% create the spm Masked Pattern
spmMaskedPattern = zeros(count(mask), size(SPM,2));
for i = 1 : size(SPM,2)
    currentSpmTr = SPM(:,i);
    spmMaskedPattern(:,i) = currentSpmTr(mask);
end

subj1PatternMat = get_mat(subj001, 'pattern', 'epi');
subj1PatternMatZScored = get_mat(subj001, 'pattern', 'epi_z');
regressors = logical(get_mat(subj001, 'regressors', 'conds'));
selectors = get_mat(subj001, 'selector', 'runs');
deconvolvedFeatures = get_mat(subj001, 'mask', 'staticFeatures_2500_1');

currentPattern = subj1PatternMat;
runNumber = 1;
cond1 = 1;
cond2 = 3;
x1 = find(regressors(cond1,:) & selectors == runNumber);
x2 = find(regressors(cond2,:) & selectors == runNumber);
x3 = x1;
x4 = x2;

for i = find(deconvolvedFeatures)'
    currentVoxel = currentPattern(i,:);    
    spmCurrentVoxel = spmMaskedPattern(i,:);
    y1 = currentVoxel(regressors(cond1,:) & selectors == runNumber);
    y2 = currentVoxel(regressors(cond2,:) & selectors == runNumber);
    y3 = spmCurrentVoxel(regressors(cond1,:) & selectors == runNumber);
    y4 = spmCurrentVoxel(regressors(cond2,:) & selectors == runNumber);
    plot(x1, y1,'b--o', x2, y2, 'g--o', x3, y3,'r--o', x4, y4, 'y--o');
    label1 = ['afni cond' num2str(cond1)];
    label2 = ['afni cond' num2str(cond2)];
    label3 = ['spm cond' num2str(cond1)];
    label4 = ['spm cond' num2str(cond2)];
    legend(label1, label2, label3, label4);
    grid on;
    input(['voxel ' num2str(i) ',press any key to continue']);
end

