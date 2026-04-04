Example 2:Effect of Glucose Concentration on the Biomass Production of the Filamentous Fungus Aspergillus Niger in Batch Liquid Culture

##Bojective:The goal is to study the effect of glucose concentration and spore age on the biomass production of the filamentous fungus Aspergillus niger. 

##BackGround: 

The goal is to study how spore age and glucose concentration affect the biomass production in the fungus Aspergillus niger. In every 500 ml flask, there is 100 ml of PDA inoculated with 10^6 spores per flask. Three blocks were created for the spore age, that is, 7, 14, and 21 days. Five glucose concentrations were tested: 0.5, 2, 10, 50, and 100 g/l. The response variable is biomass concentration in dry weight. The flasks were incubated for 72 hours with shaking at 200 rpm at a temperature of 35°C and an initial pH of 4.0. After this period, the biomass (g/l) was measured.

##Design:

- Factour 1: Spore age- 3 levels(7,14 and 21 days)
- Factour 2: Glucose concentration- 5 Levels (0.5, 2, 10, 50, 100 g/L)
- Response Variable: Biomass concentration in dry weight (g/L)
- Sample Size: n = 2 per Block × Glucose combination, N = 30 total
- Design: Randomized complete block design 

##Statistical Analysis
- Two-way ANOVA with interaction (Type III sums of squares)
- Tukey HSD post-hoc test on glucose main effect
- Estimated marginal means via emmeans package (R only)
- Assumption checks: Shapiro-Wilk normality test (per glucose group),
  Levene homogeneity of variance test

##Files

- Effect of Glucose.csv — raw data
- Example2_R.R — R analysis with emmeans Tukey
- Example2_Python.py — Python analysis with per-group Shapiro-Wilk
- Example2_MATLAB.m — MATLAB analysis with Type III SS
