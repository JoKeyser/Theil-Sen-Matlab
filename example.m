% This example demonstrates the use of TheilSen.m with simulated data.
clearvars *

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
[m, b] = TheilSen([data_x, data_y]);
est_ts = [b, m];

% Plot everything and add comparison of estimates to title.
figure()
plims = [min(data_x), max(data_x)]';
normal_idx = setdiff(1:N_total, outlr_idx);
plot(data_x(normal_idx), data_y(normal_idx), 'ko', ...
     data_x(outlr_idx), data_y(outlr_idx), 'rx', ...
     plims, plims * est_ls(2) + est_ls(1), '-r', ...
     plims, plims * m + b, 'b-', ...
     'linewidth', 2)
legend('Normal data', 'Outlier', 'Least Squares', 'Theil-Sen', 'location', 'NW')
title(sprintf('True: [%.3g, %.3g], LS: [%.3g, %.3g], TS: [%.3g, %.3g]', ...
      [true_b0, true_b1, est_ls(1), est_ls(2), est_ts(1), est_ts(2)]))