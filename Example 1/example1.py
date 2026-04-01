#!/usr/bin/env python
# coding: utf-8

# In[7]:


import pandas as pd
import numpy as np
import scipy.stats as stats
import statsmodels.api as sm
from statsmodels.formula.api import ols
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import matplotlib.pyplot as plt


# In[35]:


from pathlib import Path

file_path = Path.home() / "Downloads" / "Three Substrate Sterilization.csv"
data = pd.read_csv(file_path)


data.columns = data.columns.str.strip()

data = data.rename(columns={"Sterilization Method": "sterilization_method"
})
data = data.rename(columns={"Mushroom production": "mushroom_production"})
# Make column names safe
data.columns = (
    data.columns
    .str.strip()          # remove leading/trailing spaces
    .str.lower()          # lowercase everything
    .str.replace(" ", "_")
)

print(data.columns)

print(data.head())

print(data.groupby("sterilization_method").size())

print(data.columns.tolist())


# In[36]:


for name, group in data.groupby("sterilization_method"):
    stat, p = stats.shapiro(group["mushroom_production"])
    print(f"{name}: W={stat:.3f}, p-value={p:.4f}")



# In[37]:


sm.qqplot(data["mushroom_production"], line='s')
plt.title("Q–Q Plot of Mushroom Production")
plt.show()



# In[38]:


groups = [
    group["mushroom_production"].values
    for name, group in data.groupby("sterilization_method")
]

stat, p = stats.levene(*groups)
print(f"Levene’s test: W={stat:.3f}, p-value={p:.4f}")


# In[39]:


model = ols("mushroom_production ~ C(sterilization_method)",data=data).fit()

anova_table = sm.stats.anova_lm(model, typ=2)
print(anova_table)


# In[40]:


tukey = pairwise_tukeyhsd(
    endog=data["mushroom_production"],
    groups=data["sterilization_method"],
    alpha=0.05
)

print(tukey.summary())


# In[41]:


data.boxplot(
    column="mushroom_production",
    by="sterilization_method"
)
plt.title("Mushroom Production by Sterilization Method")
plt.suptitle("")
plt.xlabel("Sterilization Method")
plt.ylabel("Mushroom Production")
plt.show()

