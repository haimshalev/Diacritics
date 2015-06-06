function data = ReadIRF(irfFilePath)
    disp(['reading irf : ' irfFilePath]);
    [err Vdata AFNIheads ErrMessage]= BrikLoad(irfFilePath);

    % reshape the data to be voxels X time
    vDims = size(Vdata);
    if length(vDims) == 3
          vDims = [vDims 1];
    end
    data = reshape(Vdata,prod(vDims(1:3)), vDims(4));
end