function sub = setmask(sub)

    %sub = GetStavAnalyzeWholeMask(sub);
    
    sub = GetStavAfniWholeMask(sub);
    
    %sub = GetMVPAFullMask(sub);

    %sub = GetYaelUnionMask(sub);
    
    summarize(sub)
end
%% Stav Afni mask

function sub = GetStavAfniWholeMask(sub)

    global globalVars;
    
    disp('Setting whole mask using Stav analyze whole mask');
    
    maskpath = globalVars.maskPath;
    
    sub = load_afni_mask(sub,'Subj-Mask', maskpath);
    
end

%% Stav Analyze mask - maybe analyze mask is not as afni mask

function sub = GetStavAnalyzeWholeMask(sub)

    disp('Setting whole mask using Stav analyze whole mask');
    
    maskpath = [getdatadir() '/Mask/wholemask.img'];
    mask = ft_read_mri(maskpath);
    wholevol = mask.anatomy;
    sub = initset_object(sub,'mask','Subj-Mask',wholevol);
    
end

%% MVPA tutorial whole mask

function sub = GetMVPAFullMask(sub)
    
    disp('Setting whole mask using the mvpa afni whole mast');
    
    maskpath = [getdatadir 'Mask/mask_cat_select_vt+orig'];

    sub = load_afni_mask(sub,'Subj-Mask', maskpath);
end

%% Yaels union mask

function sub = GetYaelUnionMask(sub)
    
    disp('Setting the mask built from union of yael masks');
    
    % read all yael's masks from /Data/ROIs
    maskDir = '/Data/ROIs/';
    files = getallfiles(maskDir, 'img');
    
    % union them all to one mask
    mask = [];
    for iFile = 1 : length(files)
       image = ft_read_mri([maskDir files{iFile}]);
       if (iFile == 1)
           mask = image.anatomy;
       else
           mask = mask | image.anatomy;
       end
    end
    
    % update the sub mask
    sub = initset_object(sub,'mask','Subj-Mask',mask);
end

