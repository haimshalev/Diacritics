function [] = RemoveAllFilesFromFolder(bNeedToAsk)
    
    files = dir(pwd);
    needToDelete = false;
    for fileIdx = 1:size(files,1)
        if (files(fileIdx).name(1) ~= '.')
            needToDelete = true;
            break;
        end
    end
    
    if (needToDelete)

        % ask the use to remove all the files from the running folder
        if (bNeedToAsk)
            result = input('The script will create temp files and need to remove all the files in the running folder. Press y to confirm\n','s');
        else
            result = 'y';
        end

        if strcmp(result , 'y') == true
            % remove all the files
            delete('*');
        end

    end
end