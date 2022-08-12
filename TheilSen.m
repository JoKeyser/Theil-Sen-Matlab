function [coef, rsqrd] = TheilSen(X, y)
% THEILSEN performs Theil-Sen robust simple linear regression(s) of X on y.
% 
% For convenience, the input X may contain more than one predictor variable;
% but note that two or more predictor variables in X are treated as independent
% simple regressions: Do not confuse the output with multiple regression.
%
% With x denoting a single column vector of X, the returned slope estimator is
% the median of the set of slopes of data point pairs,
% (y(j) - y(i)) / (x(j) - x(i)), with x(i) ≠ x(j).
% The returned intercept is the median of y - slope_estimator * x.
%
% THEILSEN treats NaNs in X or y as missing values and ignores them.
%
% INPUT
%   X: One or more column vectors containing explanatory/predictor variables.
%      Rows represent observations (assumed to be i.i.d.).
%   y: A column vector containing the observations of the response variable.
%
% OUTPUT
%    coef: Estimated regression coefficients for each predictor column in X,
%          with respect to the response variable y. Each column in coef
%          corresponds to one predictor in X, i.e. it has as many columns as X.
%          The first row, i.e. coef(1, :), contains the estimated offset(s).
%          The second row, i.e. coef(2, :), contains the estimated slope(s).
%          (This output format was chosen to avoid confusion, e.g. with previous
%           versions of this code.)
%   rsqrd: Ordinary R² (coefficient of determination) per predictor column in X.
%
% EXAMPLE
%   See accompanying file example.m.
%
% REFERENCE
%   - Gilbert, Richard O. (1987), "6.5 Sen's Nonparametric Estimator of Slope",
%     Statistical Methods for Environmental Pollution Monitoring,
%     John Wiley and Sons, pp. 217-219, ISBN 978-0-471-28878-7
%   - Sen, P. K. (1968). Estimates of the Regression Coefficient Based on
%     Kendall’s Tau. Journal of the American Statistical Association, 63(324),
%     1379–1389. https://doi.org/10.1080/01621459.1968.10480934
%
% AUTHORS
%   2014-15 Zachary Danziger
%   2022 Johannes Keyser
%
% LICENSE
%   BSD 2-clause "simplified" license, see accompanying file license.txt.

sizeX = size(X);
sizeY = size(y);

if length(sizeY) ~= 2 || sizeY(1) < 2 || sizeY(2) ~= 1 || ~isnumeric(y)
    error('Input y must be a column array of at least 2 observed responses.')
end

if length(sizeX) ~= 2 || ~isnumeric(X)
    error('Input X must be one or more column arrays of predictor variables.')
end

if sizeX(1) ~= sizeY(1)
    error('The number of rows (observations) of X and y must match.')
end

Num_Obs = sizeX(1);  % rows in X (and y) are observations
Num_Pred = sizeX(2);  % columns in X are (independent) predictor variables

%%% For the curious, here more readable code for 1 column in X.
%%% This special case is absorbed in the general version below, for
%%% any number of columns in X, to avoid code duplication.
%
% % calculate slope for all pairs of data points
% C = nan(Num_Obs, Num_Obs);
% for i = 1:Num_Obs-1
%     C(i, i:end) = (y(i) - y(i:end)) ./ (X(i) - X(i:end));
% end
% % relabel infinite values (due to div by 0 = x(i) - x(j)) as NaNs-to-ignore.
% C(isinf(C)) = NaN;
% % estimate slope as the median of all pairwise slopes
% b1 = median(C(:), 'omitnan');
% % estimate offset as the median of all pairwise offsets
% b0 = median(y - b1 * X, 'omitnan');

% calculate slope, per predictor, for all pairs of data points
C = nan(Num_Obs, Num_Pred, Num_Obs);
for i = 1:Num_Obs
    C(:, :, i) = bsxfun(@rdivide, ...
                        bsxfun(@minus, y(i), y), ...
                        bsxfun(@minus, X(i, :), X));
end

% Relabel infinite values as NaN, to be omitted in the median calculation below.
% Infinite values can occur if a data pair has identical x coordinates, leading
% to division by zero, yielding -Inf or +Inf, depending on the numerator.
C(isinf(C)) = NaN;

% stack layers of C to 2D
Cprm = reshape(permute(C, [1, 3, 2]), ...
               [], size(C, 2), 1);

% estimate slope as the median of all pairwise slopes (per predictor column)
b1s = median(Cprm, 1, 'omitnan');

% estimate offset as the median of all pairwise offsets (per predictor column)
b0s = median(bsxfun(@minus, y, ...
                    bsxfun(@times, b1s, X)), ...
             'omitnan');

coef = [b0s; b1s];

if any(isnan(coef))
    warning('TheilSen:NaNoutput', ...
            'Output contains NaN; check for degenerate inputs.')
end

% If requested, output the ordinary/unadjusted R², per predictor column in X.
if nargout > 1
    % compute total sum of squares relative to the mean
    sum_sq_total = sum(power(y - mean(y), 2));
    sums_sq_total = repmat(sum_sq_total, 1, Num_Pred);
    % compute the residual sum(s) of squares relative to the regression line(s)
    ys_model = b0s + b1s .* X;
    ys_data = repmat(y, 1, Num_Pred);
    sums_sq_resid = sum(power(ys_data - ys_model, 2));
    % compute R² as 1 - SSresid / SStotal (i.e., the unadjusted version of R²)
    rsqrd = 1 - sums_sq_resid ./ sums_sq_total;
end
end
