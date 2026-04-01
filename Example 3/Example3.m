>> %% ── 1. Load data ──────────────────────────────────────────────────────────
data = readtable('bread dough.csv');
% Preview to confirm columns loaded correctly
head(data)
disp(data.Properties.VariableNames)
%% ── 2. Convert to categorical ─────────────────────────────────────────────
data.Temp     = categorical(data.Temp);
data.Humidity = categorical(data.Humidity);
%% ── 3. Descriptive statistics ─────────────────────────────────────────────
disp('=== Descriptive stats by Temperature ===')
grpstats(data, 'Temp', {'mean','std'}, 'DataVars', 'Tiempo')
disp('=== Descriptive stats by Humidity ===')
grpstats(data, 'Humidity', {'mean','std'}, 'DataVars', 'Tiempo')
disp('=== Descriptive stats by Temperature x Humidity ===')
grpstats(data, {'Temp','Humidity'}, {'mean','std'}, 'DataVars', 'Tiempo')
>> %% ── 4. Two-way ANOVA with interaction ─────────────────────────────────────
disp('=== Two-Way ANOVA ===')
[p, tbl, stats] = anovan(data.Tiempo, ...
   {data.Temp, data.Humidity}, ...
   'model',    'interaction', ...
   'varnames', {'Temperature', 'Humidity'}, ...
   'display',  'on');
=== Two-Way ANOVA ===
>> %% ── 5. Assumption checks ──────────────────────────────────────────────────
% --- 5a. Extract residuals from linear model ---
lm_model      = fitlm(data, 'Tiempo ~ Temp * Humidity');
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
   fprintf('Note: Check per-group normality before deciding on robustness\n')
else
   fprintf('Result: Residuals are approximately normal (p >= 0.05)\n')
end
% --- 5d. Per-group Shapiro-Wilk equivalent (Lilliefors per group) ---
% This matches Python's per-group shapiro.test
disp('=== Per-group normality tests ===')
group_labels = categorical(strcat(string(data.Temp), '_', string(data.Humidity)));
groups       = unique(group_labels);
for i = 1:length(groups)
   idx        = group_labels == groups(i);
   group_data = data.Tiempo(idx);
   [h_g, p_g] = lillietest(group_data);
   fprintf('Group %s: h = %d, p = %.4f\n', string(groups(i)), h_g, p_g)
end
% --- 5e. Levene homogeneity of variance test ---
figure;
p_levene = vartestn(data.Tiempo, group_labels, ...
   'TestType', 'LeveneAbsolute', ...
   'Display',  'on');
fprintf('\nLevene test p-value: %.4f\n', p_levene)
if p_levene > 0.05
   fprintf('Result: Variances are homogeneous (p > 0.05) - assumption met\n')
else
   fprintf('Result: Variances are NOT homogeneous (p < 0.05)\n')
end
>> %% ── 6. Post-hoc Tukey HSD ─────────────────────────────────────────────────
% --- 6a. Temperature main effect ---
disp('=== Tukey HSD: Temperature main effect ===')
[c_Temp, ~, ~, gnames_Temp] = multcompare(stats, ...
   'Dimension', 1, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
Temp_table = array2table(c_Temp, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(Temp_table)
% Flag non-significant comparisons
fprintf('\nNon-significant Temperature comparisons (p > 0.05):\n')
for i = 1:size(c_Temp, 1)
   if c_Temp(i,6) > 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames_Temp{c_Temp(i,1)}, gnames_Temp{c_Temp(i,2)}, ...
           c_Temp(i,4), c_Temp(i,6))
   end
end
% --- 6b. Humidity main effect ---
disp('=== Tukey HSD: Humidity main effect ===')
[c_Hum, ~, ~, gnames_Hum] = multcompare(stats, ...
   'Dimension', 2, ...
   'CType',     'tukey-kramer', ...
   'Display',   'on');
Hum_table = array2table(c_Hum, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(Hum_table)
% --- 6c. Interaction (Temperature x Humidity) ---
disp('=== Tukey HSD: Temperature x Humidity interaction ===')
[p2, tbl2, stats2] = anovan(data.Tiempo, ...
   {group_labels}, ...
   'model',    'linear', ...
   'varnames', {'Temp_Humidity'}, ...
   'display',  'off');
[c_int, ~, ~, gnames_int] = multcompare(stats2, ...
   'CType',   'tukey-kramer', ...
   'Display', 'on');
int_table = array2table(c_int, ...
   'VariableNames', {'Group1','Group2','LowerCI','MeanDiff','UpperCI','pValue'});
disp(int_table)
% Flag non-significant interaction comparisons
fprintf('\nNon-significant interaction comparisons (p > 0.05):\n')
for i = 1:size(c_int, 1)
   if c_int(i,6) > 0.05
       fprintf('  %s vs %s: mean diff = %.3f, p = %.4f\n', ...
           gnames_int{c_int(i,1)}, gnames_int{c_int(i,2)}, ...
           c_int(i,4), c_int(i,6))
   end
end
>> %% ── 7. Interaction plot ───────────────────────────────────────────────────
figure;
interactionplot(data.Tiempo, {data.Temp, data.Humidity}, ...
   'varnames', {'Temperature', 'Humidity'});
title('Interaction Plot: Temperature x Humidity');
xlabel('Temperature (°C)');
ylabel('Mean Rise Time (Tiempo)');
>> %% ── 8. Mean +/- SD bar chart by Temperature ──────────────────────────────
temp_levels = {'25°C', '28°C', '32°C'};
means_temp  = [192.87, 181.93, 182.40];
sds_temp    = [9.45,   14.23,  15.67];    % replace with your actual SD values
figure;
bar(1:3, means_temp, 'FaceColor', [0.53 0.81 0.98]);
hold on;
errorbar(1:3, means_temp, sds_temp, 'k.', 'LineWidth', 1.2);
set(gca, 'XTick', 1:3, 'XTickLabel', temp_levels);
ylabel('Mean Rise Time (Tiempo)');
title('Mean +/- SD by Temperature');
grid on;
hold off;
>> %% ── 9. Mean +/- SD bar chart by Humidity ─────────────────────────────────
hum_levels = {'70%', '75%', '80%'};
means_hum  = [191.80, 187.00, 178.40];
sds_hum    = [8.12,   12.34,  18.56];     % replace with your actual SD values
figure;
bar(1:3, means_hum, 'FaceColor', [0.6 0.8 0.6]);
hold on;
errorbar(1:3, means_hum, sds_hum, 'k.', 'LineWidth', 1.2);
set(gca, 'XTick', 1:3, 'XTickLabel', hum_levels);
ylabel('Mean Rise Time (Tiempo)');
title('Mean +/- SD by Humidity');
grid on;
hold off;
>> %% ── 10. Boxplot by Temperature and Humidity ───────────────────────────────
figure;
boxplot(data.Tiempo, {data.Temp, data.Humidity}, ...
   'Labels', {'25-70','25-75','25-80', ...
              '28-70','28-75','28-80', ...
              '32-70','32-75','32-80'});
xlabel('Temperature - Humidity');
ylabel('Rise Time (Tiempo)');
title('Boxplot: Rise Time by Temperature and Humidity');
grid on;
