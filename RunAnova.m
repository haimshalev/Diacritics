function [ subj ] = RunAnova( subj )
    global isAnova;
    if (isAnova)
        % Anova Voxal selection - cannot be done on convolved regressors
        subj = feature_select(subj,'epi_z','conds_sh3','runs_xval','thresh',[]);
    end
end

