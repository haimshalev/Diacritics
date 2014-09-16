function [ avgField , stdField] = GetAvgStdForASpecificField( fieldMats )

    for i = 1 : length(fieldMats)
       matrixOfAllSubjectsVectors(i, :) = fieldMats{i};        
    end
    
    avgField = mean(matrixOfAllSubjectsVectors);
    stdField = std(matrixOfAllSubjectsVectors, 0);

end

