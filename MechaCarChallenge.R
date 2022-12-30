# UCB-VIRT-DATA-ANALYTICS-2022, Parto Tandjoeng.
# Dependency
library(tidyverse)
library(ggpubr)
library(car)
library(gridExtra)

# Part 1: Linear Regression to Predict MPG
# Read in the csv file as a dataframe
df <- read.csv("./Resources/MechaCar_mpg.csv", check.names = F, stringsAsFactors = F)
head(df) # Display first five rows
str(df) # Structure & data type of dataframe
sum(is.na(df)) # Total number of missing values

# create linear model and summary statistics
model1 = lm(mpg ~ vehicle_length+vehicle_weight+spoiler_angle+ground_clearance+AWD, df)
summary(model1) #summarize linear model
summary(model1)$coefficients #summarize linear model (coefficients only)
summary(model1)$r.squared #get the r-squared
summary(model1)$adj.r.squared #get the adjusted r-squared
confint(model1) #confidential interval (default level = 0.95)
confint(model1, level = 0.99) #confidential interval (default level = 0.95)
awd0 <- df %>% filter(AWD==0) #select only data points where AWD = 0
awd1 <- df %>% filter(AWD==1) #select only data points where AWD = 1
t.test(awd0$mpg, awd1$mpg) #Welch Two Sample t-test
cor(df) #compare the strength of correlation (method = 'pearson')

b = model1$coefficients['(Intercept)'] #intercept in y = mx + (b)
ms <- c() #slope in y = (m)x + b
for (i in 2:6) {
  ms <- append(ms, model1$coefficients[i])
}
# initial multiple lm equation
yvals <- ms[1]*df$vehicle_length + ms[2]*df$vehicle_weight + ms[3]*df$spoiler_angle + 
  ms[4]*df$ground_clearance + ms[5]*df$AWD + b
avPlots(model1, col.lines = 'red', lwd = 1) #added-variable plots

#import dataset into ggplot2
plt <- ggplot(df, aes(x=vehicle_length+vehicle_weight+spoiler_angle+ground_clearance+AWD, y=mpg)) +
  #use geom_smooth to plot linear model, display linear regression equation and R-squared
  geom_point(size = 1) + geom_smooth(method = 'lm', color = 'red', se = FALSE, fullrange = TRUE) +
  stat_regline_equation(label.x = 2500, label.y = min(model1$fitted.values), size = rel(2.5)) +
  stat_cor(aes(label=after_stat(rr.label)), label.x = 2500, label.y = min(model1$fitted.values)-4, size = rel(2.5)) +
  theme(title = element_text(size=rel(0.7), face='bold'), axis.title = element_text(size=8), axis.text = element_text(size=8)) +
  xlim(c(0, 12500)) +
  coord_cartesian(clip = 'off') +
  labs(x = "vehicle_length+weight+spoiler_angle+ground_clearance+AWD", title = "MPG Multiple Linear Regression")
plt #view the plot
#save the plot as png
fname <- "./Data/lm_MPG_Multiple_Linear_Regression.png"
ggsave(fname, width = 6, height = 4, units = 'in', dpi = 150, scale = 0.7)

# multiple lm equation after removing insignificantly affecting predictors
model2 = lm(mpg ~ vehicle_length+ground_clearance, df)
summary(model2) #summarize linear model
summary(model2)$coefficients #summarize linear model (coefficient only)
summary(model2)$r.squared #get the r-squared
summary(model2)$adj.r.squared #get the adjusted r-squared
confint(model2) #confidential interval (default level = 0.95)
confint(model2, level = 0.99) #confidential interval (default level = 0.95)

b = model2$coefficients['(Intercept)'] #intercept in y = mx + (b)
ms <- c() #slope in y = (m)x + b
for (i in 2:3) {
  ms <- append(ms, model2$coefficients[i])
}
yvals <- ms[1]*df$vehicle_length + ms[2]*df$ground_clearance + b
#import dataset into ggplot2
plt <- ggplot(df, aes(x=vehicle_length+ground_clearance, y=mpg)) +
  #use geom_smooth to plot linear model, display linear regression equation and R-squared
  geom_point(size = 1) + geom_smooth(method = 'lm', color = 'blue') +
  stat_regline_equation(label.x = min(model2$fitted.values)+5, label.y = max(model2$fitted.values), size = rel(2.5)) +
  stat_cor(aes(label=after_stat(rr.label)), label.x = min(model2$fitted.values)+5, label.y = max(model2$fitted.values)-4, size = rel(2.5)) +
  theme(title = element_text(size=rel(0.8), face='bold'), axis.title = element_text(size=8), axis.text = element_text(size=8)) +
  labs(x = "vehicle_length+ground_clearance", title = "MPG Multiple Linear Regression (Revised)")
plt #view the plot
#save the plot as png
fname <- "./Data/lm_MPG_Multiple_Linear_Regression_rev.png"
ggsave(fname, width = 6, height = 4, units = 'in', dpi = 150, scale = 0.7)

#function to easily visualize a simple linear regression
lm_plot <- function(xlabel, ylabel, lmtype, mycolor) {
  xval <- df[[xlabel]]  
  yval <- df[[ylabel]]
  reg <- lm(yval ~ xval, df) #create simple linear regression model
  #determine y-axis (dependent variable) from linear regression model
  yvals <- reg$coefficients[2]*xval + reg$coefficients['(Intercept)'] 
  plt <- ggplot(df, aes(x=xval, y=yval)) + geom_point(size = 1) #import dataset into ggplot2 and plot
  if ("line" %in% lmtype) {
    #use geom_line to plot linear regression
    plt + geom_line(aes(y=yvals), color = mycolor) #plot linear regression line
  } else {
    #use geom_smooth to plot linear regression
    plt + geom_smooth(method = 'lm', se = FALSE, color = mycolor) +
      stat_regline_equation(label.x = mean(xval), label.y = min(yval), size = rel(2.5)) +
      stat_cor(aes(label=after_stat(rr.label)), label.x = mean(xval), label.y = min(yval)-4, size = rel(2.5)) +
      theme(title = element_text(size=rel(0.7), face='bold'), axis.title = element_text(size=8), axis.text = element_text(size=8)) +
      labs(x = xlabel, y = ylabel, title = "MPG Simple Linear Regression")
  }
  #save the plot as png
  fname <- gsub(" ", "", paste("./Data/lm_", xlabel, "_", ylabel, ".png"))
  ggsave(fname, width = 6, height = 4, units = 'in', dpi = 150, scale = 0.7)
}
lm_plot("vehicle_length", "mpg", "", "blue")
lm_plot("ground_clearance", "mpg", "", "blue")
lm_plot("vehicle_weight", "mpg", "", "red")
lm_plot("spoiler_angle", "mpg", "", "red")
lm_plot("AWD", "mpg", "", "red")

# Part 2: Summary Statistics on Suspension Coils
# Read in the csv file as a dataframe
df2  <- read.csv("./Resources/Suspension_Coil.csv", check.names = F, stringsAsFactors = F)
str(df2) # Structure & data type of dataframe
sum(is.na(df2)) # Total number of missing values

# get the mean, median, variance, and stddev of the suspension coil’s PSI column
total_summary <- df2 %>% 
  summarize(Mean = mean(PSI, na.rm=TRUE), Median = median(PSI, na.rm=TRUE), Variance = var(PSI, na.rm=TRUE), SD = sd(PSI, na.rm=TRUE))
view(total_summary)

# get the mean, median, variance, and stddev of the suspension coil’s PSI column by manufacturing lot
by_lot <- df2 %>% group_by(Manufacturing_Lot)
lot1 <- subset(df2, Manufacturing_Lot == 'Lot1')
lot2 <- subset(df2, Manufacturing_Lot == 'Lot2')
lot3 <- subset(df2, Manufacturing_Lot == 'Lot3')
# lot1 <- df2 %>% filter(Manufacturing_Lot == 'Lot1')
# lot2 <- df2 %>% filter(Manufacturing_Lot == 'Lot2')
# lot3 <- df2 %>% filter(Manufacturing_Lot == 'Lot3')
lot_summary <- by_lot %>% 
  summarize(Mean = mean(PSI, na.rm=TRUE), Median = median(PSI, na.rm=TRUE), Variance = var(PSI, na.rm=TRUE), SD = sd(PSI, na.rm=TRUE)) %>% 
  # mutate_if(is.numeric, format, 9) %>%
  as.data.frame()
view(lot_summary)

metrics <- lst(mean, median, min, max, quantile, IQR, var, sd, mad)
sum_by_lot <- map_dfr(metrics, ~ summarize(by_lot, across(where(is.numeric), .x, na.rm=TRUE)), .id = 'Metric')
view(sum_by_lot)
print(sd(lot3$PSI))

#normal distribution plots
sd1 = paste("Lot1 SD=", round(sd(lot1$PSI), digits=5))
sd2 = paste("Lot2 SD=", round(sd(lot2$PSI), digits=5))
sd3 = paste("Lot3 SD=", round(sd(lot3$PSI), digits=5))
totalsd = paste("Total SD=", round(sd(df2$PSI), 5))
plt <- ggplot(df2, aes(x=PSI)) +
  geom_histogram(aes(y = after_stat(density)), breaks = seq(1450, 1550, by=2), color = 'black', linewidth = 0.5, fill = 'white') +
  stat_function(fun = dnorm, args = list(mean=mean(df2$PSI), sd=sd(df2$PSI)), color = 'purple', linewidth = 1.2) +
  stat_function(fun = dnorm, args = list(mean=mean(lot1$PSI), sd=sd(lot1$PSI)), geom = 'polygon', color = '#1E90FF', fill = '#1E90FF', alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean=mean(lot2$PSI), sd=sd(lot2$PSI)), geom = 'polygon', color = 'green', fill = 'green', alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean=mean(lot3$PSI), sd=sd(lot3$PSI)), geom = 'polygon', color = 'red', fill = 'red', alpha = 0.5) +
  theme(title = element_text(size=rel(0.7), face='bold'), plot.subtitle = element_text(size=rel(0.8)), axis.title = element_text(size=8), axis.text = element_text(size=8)) +
  labs(x = "PSI (pounds per square inch)", title = "MechaCar Suspension Coil's PSI by Lot", 
       subtitle = paste(sd1, ", ", sd2, ", ", sd3, ", ", totalsd))
plt #view the plot
#save the plot as png
fname <- "./Data/Suspension_Coil_dnorm.png"
ggsave(fname, width = 6, height = 4, units = 'in', dpi = 150, scale = 0.7)

#boxplot with jittered datapoints
plt <- ggplot(df2, aes(Manufacturing_Lot, PSI, color = Manufacturing_Lot)) + 
  stat_boxplot(geom = 'errorbar', color = 'black', width = 0.1) +
  geom_boxplot(outlier.color = NA, color = 'black', notch = TRUE, notchwidth = 0.8) +
  geom_jitter(width = 0.25, size = 1) +
  scale_color_hue(direction = -1) +
  theme(title = element_text(size=rel(0.7), face='bold'), axis.title = element_text(size=8), axis.text = element_text(size=8), legend.position = 'none') +
  labs(y = "PSI (pounds per square inch)", title = "MechaCar Suspension Coil's PSI by Lot")
plt #view the plot
#save the plot as png
fname <- "./Data/Suspension_Coil_boxplot.png"
ggsave(fname, width = 6, height = 4, units = 'in', dpi = 150, scale = 0.7)

# plot only Lot3
plt <- ggplot(lot3, aes(x=PSI)) +
  geom_histogram(aes(y = after_stat(density)), breaks = seq(1450, 1550, by=2), color = 'black', linewidth = 0.5, fill = 'white') +
  stat_function(fun = dnorm, args = list(mean=mean(lot3$PSI), sd=sd(lot3$PSI)), geom = 'polygon', color = 'red', fill = 'red', alpha = 0.5) +
  theme(title = element_text(size=rel(0.7), face='bold'), plot.subtitle = element_text(size=rel(0.8)), axis.title = element_text(size=8), axis.text = element_text(size=8)) +
  labs(x = "PSI (pounds per square inch)", title = "MechaCar Suspension Coil's PSI of Lot3", 
       subtitle = sd3)
plt #view the plot

# Part 3: T-Test on Suspension Coils
stdmu = 1500 #given population mean of 1500 psi to compare against
# One Sample t-test vs the standard mean
t.test(df2[['PSI']], mu=stdmu)
t.test(lot1[['PSI']], mu=stdmu)
t.test(lot2[['PSI']], mu=stdmu)
t.test(lot3[['PSI']], mu=stdmu)

# paired t-test
t.test(lot1[['PSI']], lot2[['PSI']], paired = TRUE) 
t.test(lot1[['PSI']], lot3[['PSI']], paired = TRUE)
t.test(lot2[['PSI']], lot3[['PSI']], paired = TRUE)

# ANOVA test
aov_lot <- aov(PSI ~ Manufacturing_Lot, data=df2)
summary(aov_lot) # Summary statistics
lot_summary_Tukey <- TukeyHSD(aov_lot, conf.level = 0.95) # Summary statistics (default conf.level = 0.95)
view(lot_summary_Tukey)

# Part 4: Design a Study Comparing the MechaCar to the Competition
# Read in the csv file as a dataframe
vehicles <- read.csv("./Resources/vehicles.csv", check.names = F, stringsAsFactors = F)
# create a subset named competitor
competitor <- vehicles %>% select(city08, comb08, drive, highway08, phevBlended, trany, UCity, UHighway) %>% 
  mutate(mpg08 = (city08+highway08)/2, mpg = (UCity+UHighway)/2) %>% 
  as.data.frame()
# clean data and outliers
comp_awd <- competitor[grep("All-Wheel Drive", competitor$drive, ignore.case = TRUE), ] %>%
  filter(trany != 'Automatic (A1)' & trany != 'Automatic (A2)' & mpg08 > 1 & mpg > 1)
comp_fwd <- competitor[grep("Front-Wheel Drive", competitor$drive, ignore.case = TRUE), ] %>%
  filter(trany != 'Automatic (A1)' & trany != 'Automatic (A2)' & mpg08 > 1 & mpg > 1 & mpg08 < 85 & mpg < 85)
comp_rwd <- competitor[grep("Rear-Wheel Drive", competitor$drive, ignore.case = TRUE), ] %>%
  filter(trany != 'Automatic (A1)' & trany != 'Automatic (A2)' & mpg08 > 1 & mpg > 1 & mpg08 < 85 & mpg < 85)
comp_frwd <- list(comp_fwd, comp_rwd) %>% reduce(full_join, all = TRUE)
comp_awd0 <- subset(comp_awd, drive == 'All-Wheel Drive')
summary(comp_awd0)
summary(comp_fwd)

# One sample t-test: hypothesis vs competition's average unadjusted mpg
t.test(awd0$mpg, mu=mean(comp_awd0$mpg))
t.test(awd0$mpg, mu=mean(comp_fwd$mpg))

# ANOVA test
aov_mechacar <- aov(mpg ~ factor(AWD), data=df)
summary(aov_mechacar) # Summary statistics
aov_mechacar_Tukey <- TukeyHSD(aov_mechacar, conf.level = 0.95) # Summary statistics (default conf.level = 0.95)
view(aov_mechacar_Tukey)

# ANOVA test
aov_awd <- aov(mpg ~ drive, data=comp_awd)
summary(aov_awd) # Summary statistics
aov_awd_Tukey <- TukeyHSD(aov_awd, conf.level = 0.95) # Summary statistics (default conf.level = 0.95)
view(aov_awd_Tukey)

# ANOVA test
aov_frwd <- aov(mpg ~ drive, data=comp_frwd)
summary(aov_frwd) # Summary statistics
aov_frwd_Tukey <- TukeyHSD(aov_frwd, conf.level = 0.95) # Summary statistics (default conf.level = 0.95)
view(aov_frwd_Tukey)

#boxplot with jittered datapoints
plt1 <- ggplot(df, aes(factor(AWD), mpg, color = factor(AWD))) + 
  stat_boxplot(geom = 'errorbar', color = 'black', width = 0.1) +
  geom_boxplot(outlier.color = NA, color = 'black', notch = TRUE, notchwidth = 0.8) +
  geom_jitter(width = 0.2, size = 1) +
  scale_color_hue(direction = -1) +
  scale_x_discrete(limits = rev) +
  scale_y_continuous(limits = c(0, 85)) +
  theme(title = element_text(size=rel(0.48), face='bold'), axis.title = element_text(size=7), axis.text = element_text(size=6), legend.position = 'none') +
  labs(title = "(a) MechaCar MPG")

#boxplot with jittered datapoints
plt2 <- ggplot(comp_frwd, aes(drive, mpg, color = drive)) + 
  stat_boxplot(geom = 'errorbar', color = 'black', width = 0.1) +
  geom_boxplot(outlier.color = NA, color = 'black', notch = TRUE, notchwidth = 0.8) +
  geom_jitter(width = 0.2, size = 1) +
  scale_color_hue(direction = -1) +
  scale_x_discrete(limits = rev) +
  scale_y_continuous(limits = c(0, 85)) +
  theme(title = element_text(size=rel(0.48), face='bold'), axis.title = element_text(size=7), axis.text = element_text(size=6), legend.position = 'none') +
  labs(x = "drivetrain", title = "(b) Combined unadjusted MPG for fuelType1")

#boxplot with jittered datapoints
plt3 <- ggplot(comp_awd, aes(drive, mpg, color = drive)) + 
  stat_boxplot(geom = 'errorbar', color = 'black', width = 0.1) +
  geom_boxplot(outlier.color = NA, color = 'black', notch = TRUE, notchwidth = 0.8) +
  geom_jitter(width = 0.2, size = 1) +
  scale_y_continuous(limits = c(0, 85)) +
  theme(title = element_text(size=rel(0.48), face='bold'), axis.title = element_text(size=7), axis.text = element_text(size=6), legend.position = 'none') +
  labs(x = "drivetrain", title = "(c) Combined unadjusted MPG for fuelType1")
grid.arrange(plt1, plt2, plt3, ncol=3)
#save the plot as png
fname <- "./Data/MechaCar_vs_Competitor_boxplot.png"
ggsave(fname, arrangeGrob(plt1, plt2, plt3, ncol=3), width = 10, height = 4, units = 'in', dpi = 150, scale = 0.7)
