function data = ReadSPM(names)
    for i = 1 : length(names)
        SPMFile = load_nii(names{i});

        % reshape the data to be voxels X time
        vDims = size(SPMFile.img);
        if length(vDims) == 3
              vDims = [vDims 1];
        end
        data(:,i) = reshape(SPMFile.img,prod(vDims(1:3)), vDims(4));
    end
end

