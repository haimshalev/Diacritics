function [ subj ] = runFeatureSelection( subj )

global globalVars;

% if using anova run the feature selection and create thresh matrix
if (globalVars.isAnova) 
    featuresStatisticsName = 'epi_z_anova';
else
    featuresStatisticsName = 'epi_z_3dDeconvolve';
end

if (globalVars.isStaticNumber)

    subj = create_sorted_mask(subj, featuresStatisticsName, ...
                            globalVars.currentFeaturesMaskName,globalVars.staticNumOfFeatures, ...
                            'descending',true);
else 

    subj = create_thresh_mask(subj,  featuresStatisticsName, ...
                             globalVars.currentFeaturesMaskName , globalVars.featureThresh, ...
                            'greater_than', true, ...
                            'abs_first',    false); 
end                 

end

