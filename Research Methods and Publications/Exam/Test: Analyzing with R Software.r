# -----------------------------------------------------------------------------

#### Remmy Bisimbeko - B26099 - J24M19/011
#### My GitHub - https://github.com/RemmyBisimbeko/Data-Science

# -----------------------------------------------------------------------------

# 1. Data Importation and Exploration. 
# a. How can you import the Titanic dataset into R?

# Importing the Titanic dataset into R, you can use the
# read.csv() function. Here's the R code to accomplish this:

# Specify the full path to the directory containing the CSV file
directory_path <- "/Users/remmy/Documents/Projects/Data-Science/Research Methods and Publications/Exam/titanic"

# Set the working directory to where the train.csv file is located
setwd(directory_path)

# Then Import the Titanic dataset into R
titanic_data <- read.csv("/Users/remmy/Documents/Projects/Data-Science/Research Methods and Publications/Exam/titanic/train.csv")

# Display the structure of the imported dataset
str(titanic_data)

# Display the first few rows of the dataset
head(titanic_data)


# What does each line do:
# setwd() is used to set the working directory to the location where the train.csv file is stored. 
# read.csv() function reads the CSV file and imports it into R, storing it in the variable titanic_data.
# str() function displays the structure of the dataset, showing the data types and variable names.
# head() function displays the first few rows of the dataset for exploration.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# b. What are the key variables included in the Titanic dataset?

# To identify the key variables included in the Titanic dataset, 
# we can use the names() function to extract the column names from the dataset. 
# Here's how to do it in R:

# Display the column names of the Titanic dataset
variables <- names(titanic_data)
variables

# What does each line do:
# The names() function extracts the column names of the dataset titanic_data and 
# stores them in the variable variables.
# Printing variables displays the key variables included in the Titanic dataset.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# c. How would you display the structure and summary statistics of the Titanic dataset in R?

# To display the structure and summary statistics of the Titanic dataset in R, 
# we can use the str() function to view the structure of the dataset and the 
# summary() function to generate summary statistics. 
# Here's how to do it:

# Display the structure of the Titanic dataset
str(titanic_data)

# Display summary statistics of the Titanic dataset
summary(titanic_data)


# What does each line do:
# The str() function provides the structure of the dataset, 
# including the data types and the first few observations.
# The summary() function generates summary statistics for numerical variables in the dataset, 
# such as mean, median, minimum, maximum, and quartiles.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# 2. Data Cleaning and Preprocessing÷
# a. Are there any missing values in the dataset? 
# If so, how would you handle them using R?

# To check for missing values in the dataset and handle them using R, 
# we can use the following approach:

# Check for missing values in the dataset
missing_values <- colSums(is.na(titanic_data))

# Display columns with missing values and their respective counts
print(missing_values)

# Handle missing values
# Option 1: Remove rows with missing values
titanic_data_clean <- titanic_data[complete.cases(titanic_data), ]

# Option 2: Impute missing values using mean, median, or mode
# For example, impute missing values in the 'Age' column with the median age
titanic_data$Age[is.na(titanic_data$Age)] <- median(titanic_data$Age, na.rm = TRUE)

# What does each line do:
# colSums(is.na(titanic_data)) calculates the number of missing values for each column in the dataset.
# complete.cases(titanic_data) identifies rows without any missing values.
# Option 1 removes rows with missing values using the complete.cases() function.
# Option 2 imputes missing values using the mean, median, or mode of the respective column. 
# In this example, we impute missing values in the 'Age' column with the median age.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# b. How can you convert categorical variables, such as "Sex" and "Embarked", 
# into factors in R?

# To convert categorical variables like "Sex" and "Embarked" into factors in R, 
# we can use the factor() function. Here's how to do it:

# Convert 'Sex' variable to a factor
titanic_data$Sex <- factor(titanic_data$Sex)

# Convert 'Embarked' variable to a factor
titanic_data$Embarked <- factor(titanic_data$Embarked)

# What does each line do:
# The factor() function in R converts a vector into a factor, which is a categorical variable.
# When converting a variable to a factor, R automatically assigns levels to each unique value in the variable.
# In this example, we converted the "Sex" variable and the "Embarked" variable from character or numeric types to factors. 
# R will assign levels to each unique value in these variables.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# c. Can you identify and remove any outliers in the dataset using R?
# Hint: You may choose to analyze the "Fare" column, use a boxplot to show outliers

# we can identify and remove outliers in the dataset using R. 
# We can analyze the "Fare" column and use a boxplot to visualize the outliers. 
# Here's how to do it:

# Create a boxplot to visualize outliers in the 'Fare' column
boxplot(titanic_data$Fare, main="Boxplot of Fare", ylab="Fare")

# Identify outliers using the boxplot
outliers <- boxplot.stats(titanic_data$Fare)$out

# Print the identified outliers
print(outliers)

# Remove outliers from the dataset
titanic_data <- titanic_data[!titanic_data$Fare %in% outliers, ]

# What does each line do:
# We create a boxplot to visualize the distribution of the "Fare" column.
# Outliers are identified using the boxplot.stats() function, which calculates statistics for the boxplot, 
# including the outliers.
# We print the identified outliers.
# Finally, we remove the outliers from the dataset by subsetting the data using the %in% operator to exclude 
# rows containing outliers in the "Fare" column.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# 3. Exploratory Data Analysis (EDA)
# a. What is the distribution of passenger ages in the Titanic dataset, 
# and how can you visualize it using R?

# To visualize the distribution of passenger ages in the Titanic dataset using R, you can create a histogram. 
# Here's how to do it:

# Create a histogram to visualize the distribution of passenger ages
hist(titanic_data$Age, main="Histogram of Passenger Ages", xlab="Age", ylab="Frequency", col="skyblue", border="black")

# What does each line do:
# hist() function creates a histogram.
# titanic_data$Age specifies the column containing passenger ages.
# main argument sets the title of the histogram.
# xlab argument sets the label for the x-axis.
# ylab argument sets the label for the y-axis.
# col and border arguments set the color of the histogram bars and their borders, respectively.

# This histogram will provide a visual representation of the distribution of passenger ages in the Titanic dataset, 
# showing the frequency of different age groups.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# b. Is there a relationship between passenger class ("Pclass") and survival rate? 
# How would you visualize this relationship in R?


# To visualize the relationship between passenger class ("Pclass") and survival rate in the Titanic dataset using R, 
# you can create a bar plot. 
# Here's how to do it:

# Calculate survival rates by passenger class
survival_rates <- aggregate(Survived ~ Pclass, data = titanic_data, FUN = mean)

# Create a bar plot to visualize the relationship between passenger class and survival rate
barplot(survival_rates$Survived, names.arg = survival_rates$Pclass, 
        main = "Survival Rate by Passenger Class", xlab = "Passenger Class", 
        ylab = "Survival Rate", col = "skyblue", border = "black")

# What does each line do:
# We first calculate the survival rates by passenger class using the aggregate() function.
# Then, we create a bar plot using the barplot() function.
# survival_rates$Survived contains the survival rates.
# survival_rates$Pclass contains the passenger class categories.
# names.arg specifies the names of the bars.
# main sets the title of the plot.
# xlab sets the label for the x-axis.
# ylab sets the label for the y-axis.
# col and border specify the colors of the bars and their borders, respectively.

# This bar plot will visually show the relationship between passenger class and survival rate, 
# allowing you to compare the survival rates across different passenger classes.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# c. Can you explore the survival rate based on gender ("Sex") and visualize it using R?

# We can explore the survival rate based on gender ("Sex") and visualize it using R. 
# Here's how to do it:

# Calculate survival rates by gender
survival_rates_gender <- aggregate(Survived ~ Sex, data = titanic_data, FUN = mean)

# Create a bar plot to visualize the survival rate based on gender
barplot(survival_rates_gender$Survived, names.arg = survival_rates_gender$Sex, 
        main = "Survival Rate by Gender", xlab = "Gender", ylab = "Survival Rate", 
        col = c("pink", "lightblue"), border = "black")


# What does each line do:
# We calculate the survival rates by gender using the aggregate() function.
# Then, we create a bar plot to visualize the survival rate based on gender using the barplot() function.
# survival_rates_gender$Survived contains the survival rates.
# survival_rates_gender$Sex contains the gender categories.
# names.arg specifies the names of the bars.
# main sets the title of the plot.
# xlab sets the label for the x-axis.
# ylab sets the label for the y-axis.
# col specifies the colors of the bars (pink for female, lightblue for male).
# border specifies the color of the borders of the bars.

# This bar plot will visually display the survival rate based on gender, 
# allowing us to compare the survival rates between male and female passengers.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------


# 4. Is there a significant difference in survival rates between male and female passengers? 
# Hint: chi_square_test 


# To determine if there is a significant difference in survival rates between male and female passengers, we can perform a chi-square test of independence. 
# Here's how to do it in R:

# Perform chi-square test of independence
chi_sq_test <- chisq.test(table(titanic_data$Sex, titanic_data$Survived))

# Print the results
print(chi_sq_test)

# What does each line do:
# We use the table() function to create a contingency table of "Sex" and "Survived" variables.
# Then, we perform a chi-square test of independence using the chisq.test() function.
# Finally, we print the results of the chi-square test.

# The output of the chi-square test will provide the test statistic, degrees of freedom, 
# and p-value. We can interpret the p-value to determine if there is a significant difference 
# in survival rates between male and female passengers. If the p-value is less than a chosen significance level (e.g., 0.05), 
# we reject the null hypothesis, indicating that there is a significant difference in survival rates.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# 5. Visualization Techniques
# a. How can you create a bar chart in R to compare the 
# survival rates among different passenger classes?


# To create a bar chart in R to compare the survival rates among different passenger classes, 
# you can follow these steps:

# #     Calculate the survival rates for each passenger class.
# #     Create a bar plot to visualize the survival rates.

# Here's the R code to accomplish this:

# Calculate survival rates for each passenger class
survival_rates <- aggregate(Survived ~ Pclass, data = titanic_data, FUN = mean)

# Create bar plot
barplot(survival_rates$Survived, 
        names.arg = survival_rates$Pclass,
        col = "skyblue", 
        main = "Survival Rates by Passenger Class",
        xlab = "Passenger Class",
        ylab = "Survival Rate",
        border = "black")

# What does each line do:
# We first calculate the survival rates for each passenger class using the aggregate() function, 
# which computes the mean survival rate for each class.
# Then, we create a bar plot using the barplot() function. 
# We specify the survival rates as the heights of the bars (survival_rates$Survived), 
# the passenger classes as the x-axis labels (survival_rates$Pclass), 
# and set appropriate labels for the plot title, x-axis, and y-axis.
# We also set the color of the bars (col), the border color (border), 
# and the y-axis limits (ylim) to ensure that the plot is visually appealing and informative.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# b. What type of plot would you use in R to visualize the correlation between passenger age and fare paid?

# To visualize the correlation between passenger age and fare paid in R, you can use a scatter plot. 
# A scatter plot is suitable for showing the relationship between two continuous variables.

# Here's how you can create a scatter plot in R to visualize the correlation between passenger age and fare paid:

# Create a scatter plot
plot(titanic_data$Age, titanic_data$Fare,
     xlab = "Age",
     ylab = "Fare",
     main = "Correlation between Passenger Age and Fare Paid",
     col = "blue",
     pch = 16)


# What does each line do:
# We use the plot() function to create a scatter plot.
# We specify titanic_data$Age as the x-axis variable and titanic_data$Fare as the y-axis variable.
# We set appropriate labels for the x-axis (xlab) and y-axis (ylab), as well as a title for the plot (main).
# We set the color of the points to blue (col = "blue") and use solid circles as the point symbol (pch = 16). 
# These are optional parameters that you can adjust based on your preference.

# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------

# c. Can you create a heatmap in R to visualize the correlation matrix of 
# variables ("Pclass", "Age", "Fare") in the Titanic dataset? 
# Hint: - You may need to handle missing, infinite or NaN values


# To create a heatmap in R to visualize the correlation matrix of variables ("Pclass", "Age", "Fare") 
# in the Titanic dataset, you can follow these steps:

# Load required library
library(ggplot2)

# Subset the dataset to include only the required variables
subset_data <- titanic_data[, c("Pclass", "Age", "Fare")]

# Handle missing values by removing rows with any missing values
subset_data <- na.omit(subset_data)

# Calculate the correlation matrix
correlation_matrix <- cor(subset_data)


# This should do the trick
# Convert the correlation matrix to a data frame for plotting
correlation_df <- as.data.frame(as.table(correlation_matrix))
names(correlation_df) <- c("Var1", "Var2", "Correlation")

# Create a heatmap of the correlation matrix
ggplot(data = correlation_df, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile() +
  scale_fill_gradient(low = "blue", high = "red") +
  labs(title = "Correlation Heatmap of Variables",
       x = "Variables",
       y = "Variables") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5))


# What does each line do:
# We load the ggplot2 library to create the heatmap.
# We subset the dataset to include only the variables "Pclass", "Age", and "Fare".
# We handle missing values by removing rows with any missing values using the na.omit() function.
# We calculate the correlation matrix using the cor() function.
# We create a heatmap of the correlation matrix using ggplot() and geom_tile().
# We use scale_fill_gradient() to specify the color gradient for the heatmap.
# We label the axes and title the plot using labs().
# We adjust the appearance of the plot using theme_minimal() and theme().

# -----------------------------------------------------------------------------


