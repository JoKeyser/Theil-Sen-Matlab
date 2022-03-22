n = 100;
outN = round(0.2 * n);
noise = randn(n, 2) * 0.1;
noise(randi(n * 2, [outN, 1])) = randn(outN, 1) * 5;
data = [linspace(0, 10, n)', linspace(0,5,n)'] + noise;
Bhat = [ones(n, 1), data(:, 1)] \ data(:, 2);
[m, b] = TheilSen(data);
plims = [min(data(:, 1)), max(data(:, 1))]';
figure()
plot(data(:, 1), data(:, 2), 'k.', ...
     plims, plims * m + b, '-r', ...
     plims, plims * Bhat(2) + Bhat(1), '-b', 'linewidth', 2)
legend('Data', 'Theil-Sen', 'Least Squares', 'location', 'NW')
title(sprintf('Acual Slope = %2.3g, LS est. = %2.3g, TS est. = %2.3g', ...
      [0.5 Bhat(2) m]))
