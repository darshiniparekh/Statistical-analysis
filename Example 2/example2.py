#!/usr/bin/env python
# coding: utf-8

# In[19]:


import pandas as pd
import scipy.stats as stats
import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import matplotlib.pyplot as plt
from pathlib import Path
import re 


# In[20]:


file_path = Path.home() / "Downloads" / "Effect of Glucose.csv"
data = pd.read_csv(file_path)

data.columns = (
    data.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)
data.columns = [re.sub(r"\s+", "_", col.strip().lower()) for col in data.columns]




print(data.head())
print(data.columns)



# In[22]:


for name, group in data.groupby("treatment_glucose"):
    stat, p = stats.shapiro(group["biomass"])
    print(f"{name}: W={stat:.3f}, p={p:.4f}")


# In[24]:


groups = [
    group["biomass"].values
    for name, group in data.groupby("treatment_glucose")
]

stat, p = stats.levene(*groups)
print(f"Levene’s test: W={stat:.3f}, p={p:.4f}")


# In[33]:


data["blocks"] = data["blocks"].astype("category")
data["treatment_glucose"] = data["treatment_glucose"].astype("category")
model = ols(
    "biomass ~ C(blocks) * C(treatment_glucose)",
    data=data
).fit()
anova_table = sm.stats.anova_lm(model, typ=3)
print(anova_table)


# In[34]:


tukey = pairwise_tukeyhsd(
    endog=data["biomass"],
    groups=data["treatment_glucose"],
    alpha=0.05
)

print(tukey.summary())


# In[36]:


data.boxplot(
    column="biomass",
    by="treatment_glucose"
)

plt.title("Biomass by Treatment")
plt.suptitle("")
plt.xlabel("Treatment")
plt.ylabel("Biomass")
plt.show()


# In[40]:





# In[39]:


plt.figure(figsize=(9,6))
sns.lineplot(
    data=data,
    x="treatment_glucose",
    y="biomass",
    hue="blocks",
    marker="o"
)

plt.title("Interaction Line Plot: Glucose × Block")
plt.xlabel("Glucose Level")
plt.ylabel("Biomass")
plt.tight_layout()
plt.show()

