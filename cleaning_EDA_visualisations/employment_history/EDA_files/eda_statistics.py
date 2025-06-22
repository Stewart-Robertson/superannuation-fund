import pandas as pd
from scipy import stats

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

# Calculate descriptive statistics for numerical columns
numerical_stats = data.describe(include='number')
print('Descriptive statistics for numerical columns:')
print(numerical_stats)

# Calculate descriptive statistics for categorical columns
categorical_stats = data.describe(include='object')
print('Descriptive statistics for categorical columns:')
print(categorical_stats)

# Save the cleaned data to a new CSV file
cleaned_file_path = 'cleaning_files/cleaned_member_employers.csv'
data.to_csv(cleaned_file_path, index=False)
print(f'Cleaned data saved to {cleaned_file_path}')