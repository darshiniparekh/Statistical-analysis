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
data = pd.read_csv("Effect of Glucose.csv")
data.columns = [re.sub(r"\s+", "_", col.strip().lower()) 
                for col in data.columns]
print(data.head())
print(data.columns.tolist())
data["blocks"]            = data["blocks"].astype("category")
data["treatment_glucose"] = data["treatment_glucose"].astype("category")
desc_glucose = data.groupby("treatment_glucose")["biomass"].agg(
    N     = "count",
    Mean  = "mean",
    SD    = "std",
    SE    = lambda x: x.std() / np.sqrt(len(x)),
    Min   = "min",
    Max   = "max"
).round(4)
print(desc_glucose)
desc_block = data.groupby("blocks")["biomass"].agg(
    N    = "count",
    Mean = "mean",
    SD   = "std",
    SE   = lambda x: x.std() / np.sqrt(len(x))
).round(4)
print(desc_block)
desc_interaction = data.groupby(
    ["blocks", "treatment_glucose"])["biomass"].agg(
    N    = "count",
    Mean = "mean",
    SD   = "std"
).round(4)
print(desc_interaction)
model = ols(
    "biomass ~ C(blocks) * C(treatment_glucose)",
    data=data
).fit()
residuals = model.resid
stat_sw, p_sw = stats.shapiro(residuals)
print(f"Shapiro-Wilk: W = {stat_sw:.4f}, p = {p_sw:.4f}")
#Per-group normality by Glucose level
all_normal = True
for name, group in data.groupby("treatment_glucose"):
    stat_g, p_g = stats.shapiro(group["biomass"])
    print(f"  {name:<15} W = {stat_g:.3f},  p = {p_g:.4f}")
# Per-group normality by Block
for name, group in data.groupby("blocks"):
    stat_b, p_b = stats.shapiro(group["biomass"])
    
    print(f"  {name:<12} W = {stat_b:.3f},  p = {p_b:.4f}")
#Levene Homogeneity of Variance Test by Glucos
glucose_groups = [
    group["biomass"].values
    for name, group in data.groupby("treatment_glucose")
]
stat_lev, p_lev = stats.levene(*glucose_groups)
print(f"Levene's test: W = {stat_lev:.4f}, p = {p_lev:.4f}")
anova_table = sm.stats.anova_lm(model, typ=3)
print(anova_table)
tukey = pairwise_tukeyhsd(
    endog  = data["biomass"],
    groups = data["treatment_glucose"],
    alpha  = 0.05
)
print(tukey.summary())
# Mean +/- SD bar chart by Glucose 
glucose_summary = data.groupby("treatment_glucose")["biomass"].agg(
    Mean = "mean",
    SD   = "std"
).reset_index()

plt.figure(figsize=(9, 6))
x_pos = range(len(glucose_summary))
plt.bar(x_pos, glucose_summary["Mean"],
        yerr=glucose_summary["SD"],
        capsize=5, color="steelblue",
        edgecolor="white", alpha=0.85)
plt.xticks(x_pos, glucose_summary["treatment_glucose"], rotation=45)
plt.xlabel("Glucose Level (g/L)")
plt.ylabel("Mean Biomass (g/L)")
plt.title("Mean +/- SD Biomass by Glucose Level")
plt.grid(axis='y', alpha=0.3)
plt.tight_layout()
plt.show()
#Interaction plot: Block x Glucose 
plt.figure(figsize=(9, 6))
interaction_means = data.groupby(
    ["treatment_glucose","blocks"])["biomass"].mean().reset_index()

for block_name, group in interaction_means.groupby("blocks"):
    plt.plot(group["treatment_glucose"], group["biomass"],
             marker='o', linewidth=1.5, label=str(block_name))

plt.title("Interaction Plot: Glucose x Block")
plt.xlabel("Glucose Level (g/L)")
plt.ylabel("Mean Biomass (g/L)")
plt.legend(title="Block (Spore Age)")
plt.xticks(rotation=45)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()




