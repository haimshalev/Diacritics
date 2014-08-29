function [ subj ] = runFeatureSelection( subj )

global isAnova;
global currentFeaturesMaskName;
global isStaticNumber;
global staticNumOfFeatures;
global featureThresh;

% if using anova run the feature selection and create thresh matrix
if (isAnova) 
    featuresStatisticsName = 'epi_z_anova';
else
    featuresStatisticsName = 'epi_z_3dDeconvolve';
end

if (isStaticNumber)

    subj = create_sorted_mask(subj, featuresStatisticsName, ...
                            currentFeaturesMaskName,staticNumOfFeatures, ...
                            'descending',true);
else 

    subj = create_thresh_mask(subj,  featuresStatisticsName, ...
                             currentFeaturesMaskName , featureThresh, ...
                            'greater_than', true, ...
                            'abs_first',    false); 
end                 

end

