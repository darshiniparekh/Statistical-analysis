import pandas as pd
import scipy.stats as stats
import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import matplotlib.pyplot as plt
import re

from pathlib import Path

file_path = Path.home() / "Downloads" / "bread dough.csv"
data = pd.read_csv(file_path)

data.columns = [re.sub(r"\s+", "_", col.strip().lower()) for col in data.columns]

print(data.head())
print(data.columns)

data['treatment'] = data['temp'].astype(str) + "_" + data['humidity'].astype(str)

for name, group in data.groupby('treatment'):
    stat, p = stats.shapiro(group['tiempo'])
    print(f"{name}: W={stat:.3f}, p={p:.4f}")

groups = [group['tiempo'].values for name, group in data.groupby('treatment')]
stat, p = stats.levene(*groups)
print(f"Levene's test: W={stat:.3f}, p={p:.4f}")

model = ols('tiempo ~ C(temp) * C(humidity)', data=data).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

tukey = pairwise_tukeyhsd(
    endog=data['tiempo'],
    groups=data['treatment'],
    alpha=0.05
)
print(tukey.summary())

import seaborn as sns

plt.figure(figsize=(8,6))
sns.boxplot(x='temp', y='tiempo', hue='humidity', data=data)
plt.title('Tiempo by Temperature and Humidity')
plt.xlabel('Temperature')
plt.ylabel('Tiempo')
plt.show()

