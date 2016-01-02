function [ subj ] = RunGLM( subj , runIdx)

    global globalVars;

    if (~globalVars.isAnova)
        
        scanPath = getscanfiles(runIdx);
        
        % setting the statemap parameters
        if strcmp(globalVars.testsBuildMethod, 'OneRun')
            statmap_3d_arg.whole_func_name = scanPath{1};
        elseif strcmp(globalVars.testsBuildMethod,'EntireRuns')
            statmap_3d_arg.whole_func_name = globalVars.combinedScansPath;
        elseif strcmp(globalVars.testsBuildMethod,'ScrambledEntireRuns')
            statmap_3d_arg.whole_func_name = globalVars.combinedScansPath;
        else
            error('Unkown testsBuildMethod value. Please use OneRun or EntireRuns strings');
        end
        
        statmap_3d_arg.deconv_args.mask = globalVars.maskPath;
        statmap_3d_arg.runs_selname = 'runs';
        statmap_3d_arg.deconv_args.polort = '2';

        nConds = size(get_mat(subj,'regressors','conds_conv'),1);
        statmap_3d_arg.contrast_mat = create_main_effect_contrast(nConds);

        statmap_3d_arg.goforit = 7;

        subj = feature_select(subj,'epi_z', ...
                                 'conds_conv','runs_xval', ...
                                 'thresh',[], ...
                                 'statmap_funct','statmap_3dDeconvolve', ...
                                 'statmap_arg', statmap_3d_arg); 
       
       % If we seperating runs we don't have groups (only one run)
       % so to avoid warnings, Replace the group name with an individual
       % 3dDeconvolved name
       if strcmp(globalVars.testsBuildMethod, 'OneRun')
           subj.patterns{3}.name = 'epi_z_3dDeconvolve';
           subj.patterns{3}.group_name = '';
       end
       
       % the deconvolve function create outpu files, so we just clear the folder
        RemoveAllFilesFromFolder(false);
    end

end

