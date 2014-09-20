function runsmat = getrunsmat(runIdx,subj)

files = getscanfiles(runIdx);

%diacriticsCount = 1;
%withoutDiacriticsCount = 1;

global globalVars;

runsmat = [];


    for iFile = 1 : length(files)
        runsmat = [runsmat iFile*ones(1,globalVars.scanLength)];
    end  
    %{ 
    path = files{iFile};
    [a,name,b] = fileparts(path);
    
    % if without diacritics
    if size(name,2) == withoutDiacriticsScanFileNameLegth
        runsmat = [runsmat withoutDiacriticsCount*ones(1,scanLength)];
        withoutDiacriticsCount = withoutDiacriticsCount +1;
    elseif size(name,2) == withDiacriticsScanFileNameLength
        runsmat = [runsmat diacriticsCount*ones(1,scanLength)];
        diacriticsCount = diacriticsCount +1;
    else error('wrong scan file name');
    end
    %}
end