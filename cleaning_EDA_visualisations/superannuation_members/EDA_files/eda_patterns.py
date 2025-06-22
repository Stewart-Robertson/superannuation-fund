import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns

# Load the data
# Reading the first 500 rows of the dataset
data = pd.read_csv('../data/superannuation_members.csv', nrows=500)

# Data quality metrics
num_rows = data.shape[0]
num_columns = data.shape[1]
num_missing_values = data.isnull().sum().sum()
num_duplicates = data.duplicated().sum()

# Output the results
print(f"Number of rows: {num_rows}")
print(f"Number of columns: {num_columns}")
print(f"Number of missing values: {num_missing_values}")
print(f"Number of duplicates: {num_duplicates}")

# Handling missing values
for column in data.columns:
    if data[column].isnull().any():
        if data[column].dtype == 'object':
            mode_value = data[column].mode()[0]
            data[column].fillna(mode_value, inplace=True)
        else:
            mean_value = data[column].mean()
            data[column].fillna(mean_value, inplace=True)

# Temporal patterns analysis (example: analyzing date_of_birth)
if 'date_of_birth' in data.columns:
    data['date_of_birth'] = pd.to_datetime(data['date_of_birth'], errors='coerce')
    data['age'] = (pd.to_datetime('today') - data['date_of_birth']).dt.days // 365
    plt.figure(figsize=(10, 6))
    sns.histplot(data['age'], bins=30, kde=True)
    plt.title('Age Distribution')
    plt.xlabel('Age')
    plt.ylabel('Frequency')
    plt.show()

# Clustering analysis (example: clustering based on salary and super balance)
if 'salary' in data.columns and 'super_balance' in data.columns:
    kmeans = KMeans(n_clusters=3)
    data['cluster'] = kmeans.fit_predict(data[['salary', 'super_balance']])
    plt.figure(figsize=(10, 6))
    sns.scatterplot(data=data, x='salary', y='super_balance', hue='cluster', palette='viridis')
    plt.title('Clustering of Salary and Super Balance')
    plt.xlabel('Salary')
    plt.ylabel('Super Balance')
    plt.show()
