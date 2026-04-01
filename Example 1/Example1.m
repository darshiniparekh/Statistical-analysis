>> %% ── 1. Load data ──────────────────────────────────────────────────────────
data = readtable('Three Substrate Sterilization.csv');
% Show what MATLAB named the columns (may differ from CSV headers)
disp(data.Properties.VariableNames)
head(data)
%% ── 2. Fix column names ───────────────────────────────────────────────────
% MATLAB auto-removed the space so headers are:
% 'SterilizationMethod' and 'MushroomProduction'
data.Properties.VariableNames{'SterilizationMethod'} = 'Method';
data.Properties.VariableNames{'MushroomProduction'}  = 'Production';
% Confirm
disp(data.Properties.VariableNames)
%% ── 3. Convert to categorical ─────────────────────────────────────────────
data.Method = categorical(data.Method);
%% ── 4. Descriptive statistics ─────────────────────────────────────────────
disp('=== Descriptive stats by Sterilization Method ===')
grpstats(data, 'Method', {'mean','std'}, 'DataVars', 'Production')
% Detailed summary with CI
methods = unique(data.Method);
fprintf('\n%-15s %6s %8s %8s %8s %8s\n', ...
   'Method','N','Mean','SD','CI_low','CI_up')
for i = 1:length(methods)
   idx  = data.Method == methods(i);
   vals = data.Production(idx);
   n    = sum(idx);
   m    = mean(vals);
   s    = std(vals);
   se   = s / sqrt(n);
   ci   = tinv(0.975, n-1) * se;
   fprintf('%-15s %6d %8.3f %8.3f %8.3f %8.3f\n', ...
       string(methods(i)), n, m, s, m-ci, m+ci)
end
%% ── 5. One-way ANOVA ──────────────────────────────────────────────────────
disp('=== One-Way ANOVA ===')
[p, tbl, stats] = anova1(data.Production, data.Method, 'on');
fprintf('\nANOVA p-value: %.6e\n', p)
=== One-Way ANOVA ===

ANOVA p-value: 1.531582e-22
>> %% ── 6. Assumption checks ──────────────────────────────────────────────────
% --- 6a. Extract residuals ---
lm_model      = fitlm(data, 'Production ~ Method');
residuals_vec = lm_model.Residuals.Raw;
% --- 6b. Normal probability plot ---
figure;
normplot(residuals_vec);
title('Normal Probability Plot of Residuals');
% --- 6c. Lilliefors normality test overall ---
[h_lil, p_lil] = lillietest(residuals_vec);
fprintf('\nLilliefors normality test: h = %d, p = %.4f\n', h_lil, p_lil)
if p_lil < 0.05
   fprintf('Result: Mild deviation from normality detected\n')
else
   fprintf('Result: Residuals are approximately normal (p >= 0.05)\n')
end
% --- 6d. Per-group normality tests ---
disp('=== Per-group normality tests ===')
for i = 1:length(methods)
   idx        = data.Method == methods(i);
   group_data = data.Production(idx);
   [h_g, p_g] = lillietest(group_data);
   fprintf('%-15s h = %d, p = %.4f\n', string(methods(i)), h_g, p_g)
end
% --- 6e. Levene homogeneity of variance test ---
figure;
p_levene = vartestn(data.Production, data.Method, ...
   'TestType', 'LeveneAbsolute', ...
   'Display',  'on');
fprintf('\nLevene test p-value: %.4f\n', p_levene)
if p_levene > 0.05
   fprintf('Result: Variances are homogeneous (p > 0.05) - assumption met\n')
else
   fprintf('Result: Variances are NOT homogeneous (p < 0.05)\n')
end
>> %% ── 7. Post-hoc Tukey HSD ─────────────────────────────────────────────────
disp('=== Tukey HSD: Pairwise comparisons ===')
[c, ~, ~, gnames] = multcompare(stats, ...
   'CType',   'tukey-kramer', ...
   'Display', 'on');
% Print labelled readable table
fprintf('\n%-15s %-15s %10s %10s %10s %10s\n', ...
   'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue')
for i = 1:size(c,1)
   fprintf('%-15s %-15s %10.4f %10.4f %10.4f %10.4f\n', ...
       gnames{c(i,1)}, gnames{c(i,2)}, ...
       c(i,3), c(i,4), c(i,5), c(i,6))
end
% Significant comparisons
fprintf('\nSignificant comparisons (p < 0.05):\n')
for i = 1:size(c,1)
   if c(i,6) < 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames{c(i,1)}, gnames{c(i,2)}, c(i,4), c(i,6))
   end
end
% Non-significant comparisons
fprintf('\nNon-significant comparisons (p >= 0.05):\n')
for i = 1:size(c,1)
   if c(i,6) >= 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames{c(i,1)}, gnames{c(i,2)}, c(i,4), c(i,6))
   end
end
>> %% ── 8. Boxplot with mean overlay ──────────────────────────────────────────
figure;
boxplot(data.Production, data.Method);
xlabel('Sterilization Method');
ylabel('Mushroom Production (kg)');
title('Mushroom Production by Sterilization Method');
grid on;
% Overlay group means as red dots
hold on;
for i = 1:length(methods)
   idx = data.Method == methods(i);
   m   = mean(data.Production(idx));
   plot(i, m, 'r.', 'MarkerSize', 20)
end
hold off;
>> %% ── 9. Bar chart: Mean +/- SD ─────────────────────────────────────────────
means_prod = zeros(1, length(methods));
sds_prod   = zeros(1, length(methods));
for i = 1:length(methods)
   idx           = data.Method == methods(i);
   means_prod(i) = mean(data.Production(idx));
   sds_prod(i)   = std(data.Production(idx));
end
figure;
bar(1:length(methods), means_prod, 'FaceColor', [0.4 0.76 0.647]);
hold on;
errorbar(1:length(methods), means_prod, sds_prod, 'k.', 'LineWidth', 1.2);
set(gca, 'XTick', 1:length(methods), ...
        'XTickLabel', string(methods));
ylabel('Mean Mushroom Production (kg)');
title('Mean +/- SD by Sterilization Method');
grid on;
hold off;
