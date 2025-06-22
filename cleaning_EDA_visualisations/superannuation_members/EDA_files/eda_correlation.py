import pandas as pd

# Load the data
# Reading the first 500 rows of the dataset
data = pd.read_csv('../data/superannuation_members.csv', nrows=500)

# Calculate correlations
correlation_matrix = data.corr()

# Output the correlation matrix
print("Correlation Matrix:")
print(correlation_matrix)

# Save the correlation matrix to a CSV file
correlation_matrix.to_csv('eda_files/correlation_matrix.csv')
print('Correlation matrix saved to eda_files/correlation_matrix.csv')