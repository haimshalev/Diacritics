function data = ReadBrik(names)
    
    for i = 1 : length(names)
        
        [err Vdata AFNIheads ErrMessage]= BrikLoad(names{i});

        % reshape the data to be voxels X time
        vDims = size(Vdata);
        if length(vDims) == 3
              vDims = [vDims 1];
        end
        data{i} = reshape(Vdata,prod(vDims(1:3)), vDims(4));
    end
end