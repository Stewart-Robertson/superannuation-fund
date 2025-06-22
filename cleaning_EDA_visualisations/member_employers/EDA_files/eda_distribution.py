import pandas as pd
from scipy import stats

# Load the data
# Ingest the first 500 rows
data = pd.read_csv('../data/member_employers.csv', nrows=500)

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

# Handling duplicates
if num_duplicates > 0:
    data = data.drop_duplicates()
    print(f"Duplicates removed: {num_duplicates}")
else:
    print("No duplicates found.")

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
numerical_stats = data.describe()
print('Descriptive statistics for numerical columns:')
print(numerical_stats)

# Calculate descriptive statistics for categorical columns
categorical_stats = data.describe(include=['object'])
print('Descriptive statistics for categorical columns:')
print(categorical_stats)

# Identify outliers using Z-score
z_scores = stats.zscore(data.select_dtypes(include=['float64', 'int64']))
abs_z_scores = abs(z_scores)
filtered_entries = (abs_z_scores < 3).all(axis=1)

# Filter the data to remove outliers
data_no_outliers = data[filtered_entries]

# Alternatively, identify outliers using IQR
Q1 = data.quantile(0.25)
Q3 = data.quantile(0.75)
IQR = Q3 - Q1
outlier_condition = ~((data < (Q1 - 1.5 * IQR)) | (data > (Q3 + 1.5 * IQR))).any(axis=1)

# Save the cleaned data to a new CSV file
cleaned_file_path = 'cleaned_member_employers.csv'
data_no_outliers.to_csv(cleaned_file_path, index=False)
print(f'Cleaned data saved to {cleaned_file_path}')