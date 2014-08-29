% NANMEAN provides a replacement for MATLAB's nanmean.
%
% For usage see MEAN.


function y = nanmean_fidex(x, dim)
N = sum(~isnan(x), dim);
y = nansum(x, dim) ./ N;

end