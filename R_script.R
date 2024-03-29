# Patrick L. Chen
# CDS 492 Project
setwd("C:/Users/Patrick/OneDrive/CDS492/Breast Cancer Dataset")
breast_cancer <- read.csv("Breast_Cancer.csv")

library(tidyverse)
library(dplyr)
library(reader)
library(caret)

# The first question to ask is the proportion of cancer patients 
# who have survived vs the number being dead. This should give
# an overall estimate of the general survivalbility of cancer rates. 
glimpse(breast_cancer)
ggplot(data = breast_cancer) +
  geom_bar(mapping = aes(x = Status))

# This is the overall histogram of all patients with their survival
# months being included. 
ggplot(data = breast_cancer) +
  geom_histogram(mapping = aes(x = Survival.Months))

# This is the overall histogram of all patients with their survival
# months being included. 

deaths <- filter(breast_cancer, Status == "Dead")
ggplot(data = deaths) +
  geom_histogram(mapping = aes(x = Survival.Months))

alive <- filter(breast_cancer, Status == "Alive")
ggplot(data = alive) +
  geom_histogram(mapping = aes(x = Survival.Months))

deaths <- filter(breast_cancer, Status == "Dead")
ggplot(data = deaths) +
  geom_histogram(mapping = aes(x = Tumor.Size))

ggplot(data = deaths) +
  geom_point(mapping = aes(x = Age, y = Survival.Months))

ggplot(data = alive) +
  geom_point(mapping = aes(x = Age, y = Survival.Months))


# Here is the code for calculating the average rate from
# dead and alive patients. 

patients <- c(rep(0, 3408), rep(1, 616))


n_samples <- 500
sample_size <- 50

# create an empty vector to store the sample means
sample_means <- vector("numeric", n_samples)

# take samples and calculate the mean of each sample
for (i in 1:n_samples) {
  sample <- sample(patients, sample_size, replace = TRUE)
  sample_means[i] <- mean(sample)
}

# plot the sampling distribution
hist(sample_means, main = "Sampling Distribution of Dead and Alive Patients",
     xlab = "Sample Mean", ylab = "Frequency")


ggplot(data = alive) +
  geom_bar(mapping = aes(x = Race))

# Here is the glm model to predict the dead or alive status of patients based on a few factors. 

breast_cancer$Status <- ifelse(breast_cancer$Status == "Alive", 1, 0)

model <- glm(Status ~ Race + Age + Tumor.Size + T.Stage + N.Stage, data = breast_cancer, family = binomial)
summary(model)

breast_cancer$predicted_status <- plogis(predict(model, type = "response"))

# Here is the graph. 

library(ggplot2)
ggplot(breast_cancer, aes(x = predicted_status, y = Status)) +
  geom_point() +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  xlab("Predicted probability of death") +
  ylab("Observed status (0 = alive, 1 = dead)") +
  ggtitle("Logistic regression model predictions")

summary(model)

# Here is the prediction model for only race. 
logistic_model <- glm(Status ~ Race, data = breast_cancer, family = "binomial")
summary(logistic_model)

probs <- predict(logistic_model, type = "response")
race_probs <- tapply(probs, breast_cancer$Race, mean)

# Create a bar plot of the probabilities
barplot(race_probs, xlab = "Race", ylab = "Probability of Death",
        ylim = c(0,1), col = "blue", main = "Probability of Death by Race")

# Here is the cross validation for the glm model. 
breast_cancer$Status <- factor(breast_cancer$Status, levels = c(0, 1), labels = c("alive", "dead"))
formula <- Status ~ Age + Race + Tumor.Size + T.Stage + N.Stage
ctrl <- trainControl(method = "cv", number = 10)
model <- train(formula, data = breast_cancer, method = "glm", family = "binomial", trControl = ctrl)
print(model)

