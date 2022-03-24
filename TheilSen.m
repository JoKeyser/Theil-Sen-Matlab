function [b1, b0] = TheilSen(X, y)
% THEILSEN performs Theil-Sen robust, simple linear regression(s) of X on y.
% 
% Note that multiple predictor variables in X are treated as independent
% simple regressions; don't confuse the output with multiple regression.
%
% THEILSEN treats NaNs in X or y as missing values, and ignores them.
%
% INPUT
%   X: One or more columns vectors containing explanatory/predictor variables.
%      Rows contain the observed predictor variables.
%   y: A column vector containing the observations of the response variable.
%
% OUTPUT
%   b1: Estimated slope(s) for each predictor variable in X with respect to the
%       response variable. Therefore, b1 will be a vector with as many slopes as
%       column vectors in X.
%   b0: Estimated offset(s) for each predictor variable in X.
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

sizeX = size(X);
sizeY = size(y);

if length(sizeY) ~= 2 || sizeY(1) < 2 || sizeY(2) ~= 1 || ~isnumeric(X)
    error('Input y must be a column array of at least 2 observed responses.')
end

if length(sizeX) ~= 2 || ~isnumeric(X)
    error('Input X must be one or more column arrays of predictor variables.')
end

if sizeX(1) ~= sizeY(1)
    error('The number of rows (observations) of X and y must match.')
end

Num_Obs = sizeX(1);  % rows are number of observations
Num_Pred = sizeX(2);  % columns are number of (independent) predictor variables

if Num_Obs < 2
    error('Expecting a data matrix Obs x Dim with at least 2 observations.')
end

if Num_Pred == 1  % X is a vector, i.e. normal 2D case
    C = nan(Num_Obs);

    % calculate slopes of all possible data point pairs
    for i = 1:Num_Obs-1
        C(i, i:end) = (y(i) - y(i:end)) ./ (X(i) - X(i:end));
    end

    % the slope estimate is the median of all pairwise slopes
    b1 = median(C(:), 'omitnan');
    
    if nargout == 2
        % calculate intercept if requested
        b0 = median(y - b1 * X, 'omitnan');
    end
    
else  % more than 1 predictor variable in X

    C = nan(Num_Obs, Num_Pred, Num_Obs);

    for i = 1:Num_Obs
        % accumulate slopes
        C(:, :, i) = bsxfun( @rdivide, ...
            y(i) - y(:), ...
            bsxfun(@minus, X(i, 1:end), X(:, 1:end)) );
    end

    % stack layers of C to 2D
    Cprm = reshape( permute(C, [1, 3, 2]), [], size(C, 2), 1 );
    b1 = median(Cprm, 1, 'omitnan');  % calculate slope estimate
    
    if nargout == 2
        % calculate all intercepts if requested
        b0 = median( bsxfun(@minus, y(:), ...
                     bsxfun(@times, b1, X(:, 1:end))), ...
                     'omitnan');
    end
end

end
