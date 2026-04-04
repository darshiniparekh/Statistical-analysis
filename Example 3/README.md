Example 3: Effect of the combination of humidity and temperature on the volume of bread dough made with yeast 

##Bojective:To find the ideal humidity and adjecent temperature conditions for a fermentation room that allow the dough to reach an desired volume for bread made with yeast in the shortest time possible

##BackGround:
Yeast can consume the sugar available in the bread dough and produce bubbles. This is the main science behind the “rise” of a bread dough. The objective is to determine the temperature and humidity conditions that maximize dough rise in the shortest time possible. 
 A total of 9 different treatments with a combination of three humidity levels 70%, 75% and 80% and three temperature levels, 25°C, 28°C, and 32°C, were created. The bread dough was placed in the industry-grade container in the same amount. We want to test the combined effect of temperature and humidity to get a better “rise” in the bread dough. 

##Design:

- Factour 1: Temperature: 25°C, 28°C, 32°C
- Factour 2: Relative Humidity: 70%, 75%, 80%
- Response Variable: Tiempo (minutes)
- Sample Size: 9 treatment combinations, n=5 per group, N=45 total
- Design: Randomized complete block design

##Statistical Analysis

- Two-way ANOVA with interaction (Type III sums of squares)
- Assumption checks: Shapiro-Wilk test and Lilliefors test to check normility of residuals, Levene homogeneity of variance test
- Tukey HSD post-hoc test on glucose main effect

##Files

- bread dough.csv — raw data
- Example3_R.R — R analysis code
- Example3_Python.py — Python analysis code  
- Example3_MATLAB.m — MATLAB analysis code
