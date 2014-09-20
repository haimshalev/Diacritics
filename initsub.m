function subj = initsub(subj, runIdx)

subj = setmask(subj);

% now, read and set up the actual data. load_AFNI_pattern reads in the
% EPI data from a BRIK file, keeping only the voxels active in the
% mask (see above)
raw_filenames = getscanfiles(runIdx);
subj = load_afni_pattern(subj,'epi','Subj-Mask',raw_filenames);
summarize(subj)

% initialize the regressors object in the subj structure, load in the
% contents from a file, set the contents into the object and add a
% cell array of condnames to the object for future reference
subj = init_object(subj,'regressors','conds');
[regs condnames] = getregsmat(runIdx);
subj = set_mat(subj,'regressors','conds',regs);
subj = set_objfield(subj,'regressors','conds','condnames',condnames);
summarize(subj)

% store the names of the regressor conditions
% initialize the selectors object, then read in the contents
% for it from a file, and set them into the object
subj = init_object(subj,'selector','runs');
runs = getrunsmat(runIdx,subj);
subj = set_mat(subj,'selector','runs',runs);
summarize(subj)

% convolve the reggressors
subj = convolveRegressors(subj);
    
end