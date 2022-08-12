%% Simulate data and compare Theil-Sen estimator with least squares.
clearvars('*')

% Choose total sample size and fraction of outliers:
N_total = 20;
N_outlr = round(0.2 * N_total);

% Simulate a linear data set.
true_b0 = -2;
true_b1 = 10;
data_x = linspace(0, 1, N_total)';
data_y = true_b0 + true_b1 .* data_x;

% Add some "usual" Gaussian noise to both dimensions.
SDx_usual = 0.1;
SDy_usual = 2.0;
data_x = data_x + randn(size(data_x)) * SDx_usual;
data_y = data_y + randn(size(data_y)) * SDy_usual;

% Simulate "outliers" as signal-dependent, positive noise in y dimension.
SDy_outlr = 20 * SDy_usual;
outlr_idx = randperm(N_total, N_outlr);  % randomly select data points
outlr_y = data_y(outlr_idx);  % start with original value
outlr_y = abs(outlr_y) + 3 * SDy_usual;  % set to unlikely high value
outlr_y = outlr_y + abs(randn(N_outlr, 1) * SDy_outlr);  % over-dispersion
outlr_y = outlr_y .* data_x(outlr_idx);  % scale by x magnitude
data_y(outlr_idx) = outlr_y;

% Estimate least squares parameters.
est_ls = [ones(N_total, 1), data_x] \ data_y;

% Estimate Theil-Sen parameters.
[est_ts, ~] = TheilSen(data_x, data_y);

% Plot everything and add comparison of estimates to title.
figure()
plims = [min(data_x), max(data_x)]';
normal_idx = setdiff(1:N_total, outlr_idx);
plot(data_x(normal_idx), data_y(normal_idx), 'ko', ...
     data_x(outlr_idx), data_y(outlr_idx), 'rx', ...
     plims, est_ls(1) + plims * est_ls(2) , '-r', ...
     plims, est_ts(1) + plims * est_ts(2), 'b-', ...
     'linewidth', 2)
legend('Usual data', 'Outlier', 'Least Squares', 'Theil-Sen', 'location', 'NW')
title(sprintf('True: [%.3g, %.3g], LS: [%.3g, %.3g], TS: [%.3g, %.3g]', ...
      [true_b0, true_b1, est_ls(1), est_ls(2), est_ts(1), est_ts(2)]))

%% Demonstrate use of multiple predictor variables in X.
% NOTE: You must execute cell above first.
% create 3 different predictor columns
data_x1 = data_x;
data_x2 = +10 - 2 * data_x1 + randn(size(data_x1)) * SDx_usual;
data_x3 = -50 + 5 * data_x1 + randn(size(data_x1)) * SDx_usual;
X = [data_x1, data_x2, data_x3];
[est_ts, r_sqrd] = TheilSen(X, data_y);

% plot all simple regressions; note mainly the difference between x-axes
num_pred = size(X, 2);
figure()
for pp = 1:num_pred
    subplot(1, num_pred, pp)
    plims = [min(X(:, pp)), max(X(:, pp))]';
    plot(X(:, pp), data_y, 'k^', ...
    plims, est_ts(1, pp) + plims * est_ts(2, pp), 'b-', 'linewidth', 2)
end

%% Check that only identical x coordinates lead to warning and NaNs in output.
data_x = ones(5);
data_y = rand(5, 1);
TheilSen(data_x, data_y)
