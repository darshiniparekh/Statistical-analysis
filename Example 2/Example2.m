%% ── 1. Load data ──────────────────────────────────────────────────────────
data = readtable('Effect of Glucose.csv');
head(data)
disp(data.Properties.VariableNames)
%% ── 2. Standardise column names if needed ─────────────────────────────────
% Rename to consistent names - adjust if your CSV headers differ
data.Properties.VariableNames{'Blocks'}              = 'Block';
data.Properties.VariableNames{'Treatment_Glucose'}  = 'Glucose';
data.Properties.VariableNames{'Biomass'}            = 'Biomass';
%% ── 3. Convert to categorical ─────────────────────────────────────────────
data.Block   = categorical(data.Block);
data.Glucose = categorical(data.Glucose);
%% ── 4. Descriptive statistics ─────────────────────────────────────────────
disp('=== Descriptive stats by Glucose level ===')
grpstats(data, 'Glucose', {'mean','std'}, 'DataVars', 'Biomass')
disp('=== Descriptive stats by Block ===')
grpstats(data, 'Block', {'mean','std'}, 'DataVars', 'Biomass')
disp('=== Descriptive stats by Glucose x Block ===')
grpstats(data, {'Glucose','Block'}, {'mean','std'}, 'DataVars', 'Biomass')
%% ── 5. Two-way ANOVA with interaction ─────────────────────────────────────
% This now matches R's Anova(model, type="III") exactly
disp('=== Two-Way ANOVA (Type III) ===')
[p, tbl, stats] = anovan(data.Biomass, ...
   {data.Block, data.Glucose}, ...
   'model',    'interaction', ...
   'sstype',   3, ...            
   'varnames', {'Block', 'Glucose'}, ...
   'display',  'on');

%% ── 6. Assumption checks ──────────────────────────────────────────────────
% --- 6a. Extract residuals ---
lm_model      = fitlm(data, 'Biomass ~ Block * Glucose');
residuals_vec = lm_model.Residuals.Raw;
% --- 6b. Normal probability plot ---
figure;
normplot(residuals_vec);
title('Normal Probability Plot of Residuals');
% --- 6c. Lilliefors normality test (overall residuals) ---
[h_lil, p_lil] = lillietest(residuals_vec);
fprintf('\nLilliefors normality test: h = %d, p = %.6f\n', h_lil, p_lil)
if p_lil < 0.05
   fprintf('Result: Mild deviation from normality detected\n')
   fprintf('Note: Check per-group tests below\n')
else
   fprintf('Result: Residuals are approximately normal (p >= 0.05)\n')
end
% --- 6d. Per-group normality tests ---
disp('=== Per-group normality tests (by Glucose level) ===')
gluc_groups = unique(data.Glucose);
for i = 1:length(gluc_groups)
   idx        = data.Glucose == gluc_groups(i);
   group_data = data.Biomass(idx);
   [h_g, p_g] = lillietest(group_data);
   fprintf('Glucose %s: h = %d, p = %.4f\n', string(gluc_groups(i)), h_g, p_g)
pause(0.01)
end
% --- 6e. Levene homogeneity of variance test ---
group_labels = categorical(strcat(string(data.Block), '_', string(data.Glucose)));
figure;
p_levene = vartestn(data.Biomass, group_labels, ...
   'TestType', 'LeveneAbsolute', ...
   'Display',  'on');
fprintf('\nLevene test p-value: %.4f\n', p_levene)
if p_levene > 0.05
   fprintf('Result: Variances are homogeneous (p > 0.05) - assumption met\n')
else
   fprintf('Result: Variances are NOT homogeneous (p < 0.05)\n')
end
>> %% ── 7. Post-hoc Tukey HSD ─────────────────────────────────────────────────
% --- 7a. Glucose main effect (Dimension 2) ---
disp('=== Tukey HSD: Glucose main effect ===')
[c_Gluc, ~, ~, gnames_Gluc] = multcompare(stats, ...
   'Dimension', 2, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
Gluc_table = array2table(c_Gluc, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(Gluc_table)
% Print significant comparisons
fprintf('\nSignificant Glucose comparisons (p < 0.05):\n')
for i = 1:size(c_Gluc, 1)
   if c_Gluc(i,6) < 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames_Gluc{c_Gluc(i,1)}, gnames_Gluc{c_Gluc(i,2)}, ...
           c_Gluc(i,4), c_Gluc(i,6))
   end
end
% Print non-significant comparisons
fprintf('\nNon-significant Glucose comparisons (p > 0.05):\n')
for i = 1:size(c_Gluc, 1)
   if c_Gluc(i,6) >= 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames_Gluc{c_Gluc(i,1)}, gnames_Gluc{c_Gluc(i,2)}, ...
           c_Gluc(i,4), c_Gluc(i,6))
   end
end
% --- 7b. Block main effect (Dimension 1) ---
disp('=== Tukey HSD: Block main effect ===')
[c_Block, ~, ~, gnames_Block] = multcompare(stats, ...
   'Dimension', 1, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
Block_table = array2table(c_Block, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(Block_table)
% --- 7c. Interaction (Block x Glucose) ---
disp('=== Tukey HSD: Block x Glucose interaction ===')
[p2, tbl2, stats2] = anovan(data.Biomass, ...
   {group_labels}, ...
   'model',    'linear', ...
   'varnames', {'Block_Glucose'}, ...
   'display',  'off');
[c_int, ~, ~, gnames_int] = multcompare(stats2, ...
   'CType',   'tukey-kramer', ...
   'Display', 'on');
int_table = array2table(c_int, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(int_table)
%% ── 8. Interaction plot ───────────────────────────────────────────────────
figure;
interactionplot(data.Biomass, {data.Block, data.Glucose}, ...
   'varnames', {'Block (Spore Age)', 'Glucose Level'});
title('Interaction Plot: Block x Glucose');
xlabel('Block (Spore Age in days)');
ylabel('Mean Biomass (g/L)');
>> %% ── 9. Bar chart: Mean +/- SD by Glucose level ────────────────────────────
gluc_labels = {'0.5 g/L', '2 g/L', '10 g/L', '50 g/L', '100 g/L'};
means_gluc  = [8.4667, 8.4667, 10.1333, 9.9000, 10.3500];
sds_gluc    = [0.7906,  0.9129,  1.4572,  2.2716,  1.2570];
figure;
bar(1:5, means_gluc, 'FaceColor', [0.4 0.7 0.9]);
hold on;
errorbar(1:5, means_gluc, sds_gluc, 'k.', 'LineWidth', 1.2);
set(gca, 'XTick', 1:5, 'XTickLabel', gluc_labels);
ylabel('Mean Biomass (g/L)');
title('Mean +/- SD Biomass by Glucose Level');
grid on;
hold off;
>> %% ── 10. Boxplot ───────────────────────────────────────────────────────────
figure;
boxplot(data.Biomass, data.Glucose);
xlabel('Glucose Level');
ylabel('Biomass (g/L)');
title('Biomass Distribution by Glucose Level');
grid on;
