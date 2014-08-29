function [ subj ] = RunGLM( subj )

    global isAnova;
    global combinedScansPath;
    global maskPath;

    if (~isAnova)
        % setting the statemap parameters
        statmap_3d_arg.whole_func_name = combinedScansPath;
        statmap_3d_arg.deconv_args.mask = maskPath;
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
    end

end

