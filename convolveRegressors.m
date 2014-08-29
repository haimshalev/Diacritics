function [ subj ] = convolveRegressors( subj )

% shift the regressors to the peak (~6 seconds)
subj = shift_regressors(subj,'conds','runs',3);

% convlove with haemodynamic response function
subj = convolve_regressors_afni(subj,'conds','runs','overwrite_if_exist',true,'binarize_thresh',0.5);

end

