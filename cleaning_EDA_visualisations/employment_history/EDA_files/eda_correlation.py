import pandas as pd
from scipy.stats import pearsonr

# Load the data
# Ingest the first 500 rows
try:
    data = pd.read_csv('../data/employment_history.csv', nrows=500)
except Exception as e:
    print(f'Error reading the CSV file: {e}')
    exit()

# Data quality metrics
num_rows = data.shape[0]
num_columns = data.shape[1]
num_missing_values = data.isnull().sum().sum()
num_duplicates = data.duplicated().sum()

# Output the results
print(f'Number of rows: {num_rows}')
print(f'Number of columns: {num_columns}')
print(f'Number of missing values: {num_missing_values}')
print(f'Number of duplicates: {num_duplicates}')

# Handling duplicates
if num_duplicates > 0:
    data = data.drop_duplicates()
    print(f'Duplicates removed: {num_duplicates}')
else:
    print('No duplicates found.')

# Handling missing values
for column in data.columns:
    if data[column].isnull().any():
        if data[column].dtype == 'object':
            # Fill missing categorical values with the mode
            mode_value = data[column].mode()[0]
            data[column].fillna(mode_value, inplace=True)
        else:
            # Fill missing numerical values with the mean
            mean_value = data[column].mean()
            data[column].fillna(mean_value, inplace=True)

# Calculate correlations
correlation_matrix = data.corr()
print('Correlation matrix:')
print(correlation_matrix)

# Infer insights from correlations
# For example, if final_salary has a strong correlation with another variable, it might indicate a relationship
for column in correlation_matrix.columns:
    if column != 'final_salary':
        correlation, _ = pearsonr(data['final_salary'], data[column])
        print(f'Correlation between final_salary and {column}: {correlation}')
        if correlation > 0.5:
            print(f'  Strong positive correlation with {column}.')
        elif correlation < -0.5:
            print(f'  Strong negative correlation with {column}.')
        else:
            print(f'  Weak correlation with {column}.')