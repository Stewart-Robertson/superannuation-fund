import pandas as pd
import numpy as np

# Load the data
# Reading the first 500 rows of the dataset
data = pd.read_csv('../data/superannuation_members.csv', nrows=500)

# Function to identify outliers using Z-score
def identify_outliers_z(data):
    threshold = 3
    mean = np.mean(data)
    std_dev = np.std(data)
    z_scores = [(y - mean) / std_dev for y in data]
    return np.where(np.abs(z_scores) > threshold)

# Function to identify outliers using IQR
def identify_outliers_iqr(data):
    Q1 = np.percentile(data, 25)
    Q3 = np.percentile(data, 75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    return np.where((data < lower_bound) | (data > upper_bound))

# Handle outliers in the 'salary' column
salary_outliers_z = identify_outliers_z(data['salary'])
print(f'Z-score outliers in salary: {salary_outliers_z}')

salary_outliers_iqr = identify_outliers_iqr(data['salary'])
print(f'IQR outliers in salary: {salary_outliers_iqr}')

# Strategy for handling outliers: Remove them
data_cleaned = data.drop(index=salary_outliers_z[0])

data_cleaned.to_csv('cleaning_files/cleaned_superannuation_members.csv', index=False)
print('Cleaned data saved to cleaning_files/cleaned_superannuation_members.csv')