# 1. Data Importation and Exploration
# a. Import Titanic dataset into R
# titanic <- read.csv("train.csv", stringsAsFactors = FALSE)
titanic <- read.csv("/Users/remmy/Documents/Projects/Data-Science/Research Methods and Publications/Exam/titanic/train.csv")


# b. Key variables in the Titanic dataset
# Variables included are:
# PassengerId, Survived, Pclass, Name, Sex, Age, SibSp, Parch, Ticket, Fare, Cabin, Embarked

# c. Display structure and summary statistics
# Structure
str(titanic)
# Summary statistics
summary(titanic)

# 2. Data Cleaning and Preprocessing
# a. Handling missing values
# Check for missing values
colSums(is.na(titanic))
# Handle missing values by imputation or removal
# Example: Impute missing ages with median age
titanic$Age[is.na(titanic$Age)] <- median(titanic$Age, na.rm = TRUE)

# b. Convert categorical variables to factors
titanic$Sex <- factor(titanic$Sex)
titanic$Embarked <- factor(titanic$Embarked)

# c. Identify and remove outliers (using Fare column as an example)
# Boxplot to visualize outliers
boxplot(titanic$Fare)
# Remove outliers (assuming values outside 1.5*IQR as outliers)
outliers <- boxplot.stats(titanic$Fare)$out
titanic <- titanic[!titanic$Fare %in% outliers, ]

# 3. Exploratory Data Analysis (EDA)
# a. Distribution of passenger ages
hist(titanic$Age, main = "Distribution of Passenger Ages", xlab = "Age", ylab = "Frequency")

# b. Relationship between passenger class and survival rate
# Calculate survival rate by passenger class
survival_rate <- aggregate(Survived ~ Pclass, data = titanic, FUN = mean)
# Visualize relationship
barplot(survival_rate$Survived, names.arg = survival_rate$Pclass, main = "Survival Rate by Passenger Class", xlab = "Passenger Class", ylab = "Survival Rate")

# c. Explore survival rate based on gender and visualize
# Calculate survival rate by gender
gender_survival <- aggregate(Survived ~ Sex, data = titanic, FUN = mean)
# Visualize
barplot(gender_survival$Survived, names.arg = gender_survival$Sex, main = "Survival Rate by Gender", xlab = "Gender", ylab = "Survival Rate")

# 4. Significant difference in survival rates between male and female passengers
# Chi-square test
chisq.test(table(titanic$Sex, titanic$Survived))

# 5. Visualization Techniques
# a. Bar chart to compare survival rates among different passenger classes
# Already done in 3b

# b. Plot to visualize correlation between passenger age and fare paid
plot(titanic$Age, titanic$Fare, main = "Correlation between Age and Fare", xlab = "Age", ylab = "Fare")

# c. Heatmap to visualize correlation matrix
correlation_matrix <- cor(titanic[, c("Pclass", "Age", "Fare")])
heatmap(correlation_matrix, main = "Correlation Matrix", xlab = "Variables", ylab = "Variables")

