Example 4: Effect of pH and Temperature on the Efficiency of Nucleic Acid (NA) Extraction in Yeast Cells

##Objective:
The objective is to study the effect of pH and temperature on the efficiency of nucleic acid extraction in yeast cells.

##Background
 Single-cell proteins have high nucleic acid content that poses a health risk upon ingestion. To make this protein suitable for human consumption, it is necessary to have it with a low concentration of nucleic acids. pH affects cell wall integrity, and heat denatures protein and increases membrane permeability. 

   Here is the experiment design that explains how pH and temperature affect the extraction of nucleic acids in the yeast cell. Here, the factors considered are Temperature and pH. Temperatures have 3 levels: 40, 60, and 80 as well as pH, which has three levels 3,10,12. And the response variable is the percentage of nucleic acid extraction in each 25 ml test tube where temperature and pH were controlled in a run time of 20 minutes. The more efficient the extraction, the lower the toxicity. 
   
##Design:

- Factor 1: pH — 3 levels (3, 10, 12)
- Factor 2: Temperature — 3 levels (40°C, 60°C, 80°C)
- Response variable: Nucleic acid extraction efficiency (%)
- Sample size: n = 8 per pH × Temperature combination, N = 72 total
- Design: Fully crossed two-way factorial design
  
##Statistical Analysis:

- Two-way ANOVA with interaction term
- Tukey HSD post-hoc test (main effects and all pairwise pH × Temperature combinations)
- Assumption checks: Shapiro-Wilk normality test (per group),Levene homogeneity of variance test
  
##Files:
- Nucleic Acid (NA) Extraction in Yeast Cells.csv — raw data
- Example4_R.R — R analysis with Shapiro-Wilk and Levene checks
- Example4_Python.py — Python analysis with swarm plot
- Example4_MATLAB.m — MATLAB analysis with full assumption checks
