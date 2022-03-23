function [b1, b0] = TheilSen(data)
% Performs Theil-Sen robust linear regression on data.
%
% [b1, b0] = TheilSen(data)
%
% INPUT
%   data: A Num_Obs x Num_Dim matrix with Num_Obs observations.
%         The first Num_Dim - 1 columns are the explanatory variables and the
%         last column is the response such that
%         data = [x1, x2, ..., x(Num_Dim - 1), y];
%
% OUTPUT
%   b1: Estimated slope of each explanatory variable with respect to the
%       response variable. Therefore, b1 will be a vector of Num_Dim - 1 slopes.
%   b0: Estimated offsets.
%
% EXAMPLE
%   See accompanying file example.m.
%
% REFERENCE
%   - Gilbert, Richard O. (1987), "6.5 Sen's Nonparametric Estimator of Slope",
%     Statistical Methods for Environmental Pollution Monitoring,
%     John Wiley and Sons, pp. 217-219, ISBN 978-0-471-28878-7
%
% AUTHORS
%   2014-15 Zachary Danziger
%   2022 Johannes Keyser
%
% LICENSE
%   BSD 2-clause "simplified" license, see accompanying file license.txt.

sz = size(data);

if length(sz) ~= 2
    error('Expecting a 2D data matrix Num_Obs x Num_Dim.')
end

Num_Obs = sz(1);  % number of observations
Num_Dim = sz(2);  % number of dimensions

if Num_Obs < 2
    error('Expecting a data matrix Obs x Dim with at least 2 observations.')
end

if Num_Dim == 2  % normal 2D case
    C = nan(Num_Obs);

    for i = 1:Num_Obs
        % accumulate slopes
        C(i, i:end) = (data(i, 2) - data(i:end, 2)) ./ ...
                      (data(i, 1) - data(i:end, 1));
    end

    b1 = median(C(:), 'omitnan');  % calculate slope estimate
    
    if nargout == 2
        % calculate intercept if requested
        b0 = median(data(:, 2) - b1 * data(:, 1), 'omitnan');
    end
    
else
    C = nan(Num_Obs, Num_Dim-1, Num_Obs);

    for i = 1:Num_Obs
        % accumulate slopes
        C(:, :, i) = bsxfun( @rdivide, data(i, end) - data(:, end), ...
            bsxfun(@minus, data(i, 1:end-1), data(:, 1:end-1)) );
    end

    % stack layers of C to 2D
    Cprm = reshape( permute(C, [1, 3, 2]), [], size(C, 2), 1 );
    b1 = median(Cprm, 1, 'omitnan');  % calculate slope estimate
    
    if nargout == 2
        % calculate all intercepts if requested
        b0 = median( bsxfun(@minus, data(:, end), ...
                     bsxfun(@times, b1, data(:, 1:end-1))), ...
                     'omitnan');
    end
end

end
