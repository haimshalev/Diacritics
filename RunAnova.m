function [ subj ] = RunAnova( subj )
    global globalVars;
    if (globalVars.isAnova)
        % Anova Voxal selection - cannot be done on convolved regressors
        subj = feature_select(subj,'epi_z','conds_sh3','runs_xval','thresh',[]);
        
         % If we seperating runs we don't have groups (only one run)
           % so to avoid warnings, Replace the group name with an individual
           % anova name
           if strcmp(globalVars.testsBuildMethod, 'OneRun')
               subj.patterns{3}.name = 'epi_z_anova';
               subj.patterns{3}.group_name = '';
           end
    end
end

