import pandas as pd

# Load the data
data = pd.read_csv('../data/member_employers.csv', nrows=500)

# Calculate correlations
correlation_matrix = data.corr()

# Output the correlation matrix
print("Correlation Matrix:")
print(correlation_matrix)

# Infer possible important insights from the correlations
# This part is just a placeholder for insights, as no further analysis is to be done.
# You can replace this with actual insights based on the correlation matrix.
insights = "Insights can be drawn from the correlation matrix regarding relationships between variables."
print(insights)

# Save the correlation matrix to a CSV file
correlation_file_path = 'eda_files/correlation_matrix.csv'
correlation_matrix.to_csv(correlation_file_path)
print(f'Correlation matrix saved to {correlation_file_path}')