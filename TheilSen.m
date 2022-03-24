function coef = TheilSen(X, y)
% THEILSEN performs Theil-Sen robust, simple linear regression(s) of X on y.
% 
% For convenience, the input X may contain more than one predictor variable.
% But note that two or more predictor variables in X are treated as independent
% simple regressions; do not confuse the output with multiple regression.
%
% THEILSEN treats NaNs in X or y as missing values, and ignores them.
%
% INPUT
%   X: One or more columns vectors containing explanatory/predictor variables.
%      Rows contain the observed predictor variables.
%   y: A column vector containing the observations of the response variable.
%
% OUTPUT
%   coef: Estimated regression coefficients for each predictor column in X, with
%         respect to the response variable y. Each column in coef corresponds
%         to one predictor in X, i.e. it has as many columns as X does.
%         The first row, i.e. coef(1, :), contains the estimated offset(s).
%         The second row, i.e. coef(2, :), contains the estimated slope(s).
%         (This output format is chosen to avoid confusion, e.g. with previous
%          versions of this code.)
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

Num_Obs = sizeX(1);  % rows in X and y are observations
Num_Pred = sizeX(2);  % columns in X are (independent) predictor variables

if Num_Obs < 2
    error('Expecting a data matrix Obs x Dim with at least 2 observations.')
end

%%% For the curious, here more readable code for 1 predictor column in X.
%%% However, the special case is absorbed in the general version for
%%% any number of columns in X, for the sake of code simplicity.
% % calculate slope for all pairs of data points
% C = nan(Num_Obs, Num_Obs);
% for i = 1:Num_Obs-1
%     C(i, i:end) = (y(i) - y(i:end)) ./ (X(i) - X(i:end));
% end
% % estimate slope as the median of all pairwise slopes
% b1 = median(C(:), 'omitnan');
% % estimate offset as the median of all pairwise offsets
% b0 = median(y - b1 * X, 'omitnan');

% calculate slope, per predictor, for all pairs of data points
C = nan(Num_Obs, Num_Pred, Num_Obs);
for i = 1:Num_Obs
    C(:, :, i) = bsxfun(@rdivide, ...
        bsxfun(@minus, y(i), y(:)), ...
        bsxfun(@minus, X(i, 1:end), X(:, 1:end)));
end

% stack layers of C to 2D
Cprm = reshape( permute(C, [1, 3, 2]), [], size(C, 2), 1 );

% estimate slope as the median of all pairwise slopes (per predictor column)
b1s = median(Cprm, 1, 'omitnan');

% estimate offset as the median of all pairwise offsets (per predictor column)
b0s = median(bsxfun(@minus, y(:), ...
             bsxfun(@times, b1s, X(:, 1:end))), ...
            'omitnan');

coef = [b0s; b1s];
end
