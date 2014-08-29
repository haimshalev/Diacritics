function [ classificationRegMat ] = createClassificationRegressorsMatrix( classificationRegMat )

    global decisionMethod;

    % Creating a binary regs vector 
    % It's the same matrix where the second condition is unused
    % If a cell have the value one it's the first condition, if it's zero
    % it is the second condition
    if (strcmp(decisionMethod,'binary') == 1)
        classificationRegMat(2,:) = [];
    end

end

