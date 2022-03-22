function [m, b] = TheilSen(data)
% Performs Theil-Sen robust linear regression on data.
%
% [m, b] = TheilSen(data)
%
% INPUT
%   data: A MxD matrix with M observations. The first D-1 columns are the
%         explanatory variables and the Dth column is the response such that
%         data = [x1, x2, ..., x(D-1), y];
%
% OUTPUT
%   m: Estimated slope of each explanatory variable with respect to the
%      response varuable. Therefore, m will be a vector of D-1 slopes.
%   b: Estimated offsets.
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
%   2014-2015 Zachary Danziger
%   2022 Johannes Keyser
%
% LICENSE
%   Simplified BSD license, see accompanying file license.txt.

sz = size(data);
if length(sz) ~= 2 || sz(1) < 2
    error('Expecting MxD data matrix with at least 2 observations.')
end

if sz(2) == 2  % normal 2D case
    C = nan(sz(1));

    for i = 1:sz(1)
        % accumulate slopes
        C(i, i:end) = (data(i, 2) - data(i:end, 2)) ./ ...
                      (data(i, 1) - data(i:end, 1));
    end

    m = nanmedian(C(:));  % calculate slope estimate
    
    if nargout == 2
        % calculate intercept if requested
        b = nanmedian(data(:, 2) - m * data(:, 1));
    end
    
else
    C = nan(sz(1), sz(2)-1, sz(1));

    for i = 1:sz(1)
        % accumulate slopes
        C(:, :, i) = bsxfun( @rdivide, data(i, end) - data(:, end), ...
            bsxfun(@minus, data(i, 1:end-1), data(:, 1:end-1)) );
    end

    % stack layers of C to 2D
    Cprm = reshape( permute(C, [1, 3, 2]), [], size(C, 2), 1 );
    m = nanmedian(Cprm, 1);	 % calculate slope estimate
    
    if nargout == 2
        % calculate all intercepts if requested
        b = nanmedian( bsxfun(@minus, data(:, end), ...
                       bsxfun(@times, m, data(:, 1:end-1))) );
    end
end