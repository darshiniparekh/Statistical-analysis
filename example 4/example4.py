
import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import matplotlib.pyplot as plt
import seaborn as sns
import re
from pathlib import Path

file_path = Path.home() / "Downloads" / "Nucleic Acid (NA) Extraction in Yeast Cells.csv"  # replace with actual filename
data = pd.read_csv(file_path)

data.columns = [re.sub(r"\s+", "_", col.strip().lower()) for col in data.columns]

print(data.head())
print(data.columns)
data['treatment'] = data['ph'].astype(str) + "_" + data['temp'].astype(str)

for name, group in data.groupby('treatment'):
    stat, p = stats.shapiro(group['extracc'])
    print(f"{name}: W={stat:.3f}, p={p:.4f}")

groups = [group['extracc'].values for name, group in data.groupby('treatment')]
stat, p = stats.levene(*groups)
print(f"Levene's test: W={stat:.3f}, p={p:.4f}")

model = ols('extracc ~ C(ph) * C(temp)', data=data).fit()
anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)

tukey = pairwise_tukeyhsd(
    endog=data['extracc'],
    groups=data['treatment'],
    alpha=0.05
)
print(tukey.summary())

import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(8,6))

means = data.groupby(['ph','temp'])['extracc'].mean().unstack()
means.plot(marker='o')
plt.title('Interaction Plot: Extraction Efficiency')
plt.xlabel('pH')
plt.ylabel('Mean Extraction Efficiency')
plt.legend(title='Temperature')
plt.grid(True)
plt.show()

plt.figure(figsize=(8,6))
sns.swarmplot(x='ph', y='extracc', hue='temp', data=data, dodge=True)
plt.title('Swarm Plot: Extraction Efficiency by pH and Temp')
plt.xlabel('pH')
plt.ylabel('Extraction Efficiency')
plt.show()










