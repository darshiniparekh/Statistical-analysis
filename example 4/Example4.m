Matlab Code:
%% ── 1. Load data ──────────────────────────────────────────────────────────
data = readtable('Nucleic Acid (NA) Extraction in Yeast Cells.csv');
% Preview to confirm columns loaded correctly
head(data)
disp(data.Properties.VariableNames)
%% ── 2. Convert to categorical ─────────────────────────────────────────────
data.pH   = categorical(data.pH);
data.Temp = categorical(data.Temp);
%% ── 3. Descriptive statistics ─────────────────────────────────────────────
disp('=== Descriptive stats by pH ===')
grpstats(data, 'pH', {'mean','std'}, 'DataVars', 'Extracc')
disp('=== Descriptive stats by Temperature ===')
grpstats(data, 'Temp', {'mean','std'}, 'DataVars', 'Extracc')
disp('=== Descriptive stats by pH x Temperature ===')
grpstats(data, {'pH','Temp'}, {'mean','std'}, 'DataVars', 'Extracc')
%% ── 4. Two-way ANOVA with interaction ─────────────────────────────────────
disp('=== Two-Way ANOVA ===')
[p, tbl, stats] = anovan(data.Extracc, ...
   {data.pH, data.Temp}, ...
   'model',    'interaction', ...
   'varnames', {'pH', 'Temp'}, ...
   'display',  'on');
%% ── 5. Assumption checks ──────────────────────────────────────────────────
% --- 5a. Extract residuals ---
lm_model      = fitlm(data, 'Extracc ~ pH * Temp');
residuals_vec = lm_model.Residuals.Raw;
% --- 5b. Normal probability plot ---
figure;
normplot(residuals_vec);
title('Normal Probability Plot of Residuals');
% --- 5c. Lilliefors normality test ---
[h_lil, p_lil] = lillietest(residuals_vec);
fprintf('\nLilliefors normality test: h = %d, p = %.6f\n', h_lil, p_lil)
if p_lil < 0.05
   fprintf('Result: Residuals deviate from normality (p < 0.05)\n')
   fprintf('Note: ANOVA is robust to this given balanced design and n=72\n')
else
   fprintf('Result: Residuals are approximately normal (p >= 0.05)\n')
end
% --- 5d. Levene homogeneity of variance test ---
group_labels = categorical(strcat(string(data.pH), '_', string(data.Temp)));
figure;
p_levene = vartestn(data.Extracc, group_labels, ...
   'TestType', 'LeveneAbsolute', ...
   'Display',  'on');
fprintf('\nLevene test p-value: %.4f\n', p_levene)
if p_levene > 0.05
   fprintf('Result: Variances are homogeneous (p > 0.05) - assumption met\n')
else
   fprintf('Result: Variances are NOT homogeneous (p < 0.05)\n')
end
%% ── 6. Post-hoc Tukey HSD ─────────────────────────────────────────────────
% --- 6a. pH main effect ---
disp('=== Tukey HSD: pH main effect ===')
[c_pH, ~, ~, gnames_pH] = multcompare(stats, ...
   'Dimension', 1, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
% Print as readable table
pH_table = array2table(c_pH, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(pH_table)
% --- 6b. Temperature main effect ---
disp('=== Tukey HSD: Temperature main effect ===')
[c_Temp, ~, ~, gnames_Temp] = multcompare(stats, ...
   'Dimension', 2, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
Temp_table = array2table(c_Temp, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(Temp_table)
% --- 6c. Interaction (pH x Temp) ---
disp('=== Tukey HSD: pH x Temperature interaction ===')
[p2, tbl2, stats2] = anovan(data.Extracc, ...
   {group_labels}, ...
   'model',    'linear', ...
   'varnames', {'pH_Temp'}, ...
   'display',  'off');
[c_int, ~, ~, gnames_int] = multcompare(stats2, ...
   'CType',   'tukey-kramer', ...
   'Display', 'on');
int_table = array2table(c_int, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(int_table)
%% ── 7. Interaction plot ───────────────────────────────────────────────────
figure;
interactionplot(data.Extracc, {data.pH, data.Temp}, ...
   'varnames', {'pH', 'Temperature'});
title('Interaction Plot: pH x Temperature');
xlabel('pH');
ylabel('Mean Extraction Efficiency (%)');
%% ── 8. Mean +/- SD bar chart by pH ───────────────────────────────────────
pH_levels = {'pH 3', 'pH 10', 'pH 12'};
means_pH  = [16.33, 40.25, 64.45];
sds_pH    = [6.53,  17.76, 27.13];
figure;
b = bar(1:3, means_pH, 'FaceColor', [0.6 0.8 0.6]);
hold on;
errorbar(1:3, means_pH, sds_pH, 'k.', 'LineWidth', 1.2);
set(gca, 'XTick', 1:3, 'XTickLabel', pH_levels);
ylabel('Mean Extraction Efficiency (%)');
title('Mean +/- SD by pH Level');
grid on;
hold off;
%% ── 9. Boxplot by pH and Temperature ─────────────────────────────────────
figure;
boxplot(data.Extracc, {data.pH, data.Temp}, ...
   'Labels', {'3-40','3-60','3-80','10-40','10-60','10-80','12-40','12-60','12-80'});
xlabel('pH - Temperature');
ylabel('Extraction Efficiency (%)');
title('Boxplot: Extraction Efficiency by pH and Temperature');
grid on;
