import pandas as pd

# Load the data
data = pd.read_csv('../data/member_employers.csv', nrows=500)

# Data quality metrics
num_rows = data.shape[0]
num_columns = data.shape[1]
num_missing_values = data.isnull().sum().sum()
num_duplicates = data.duplicated().sum()
data_types = data.dtypes

# Output the results
print(f"Number of rows: {num_rows}")
print(f"Number of columns: {num_columns}")
print(f"Number of missing values: {num_missing_values}")
print(f"Number of duplicates: {num_duplicates}")
print(f"Data types:\n{data_types}")

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

# Standardizing date formats (example)
if 'date_column' in data.columns:
    data['date_column'] = pd.to_datetime(data['date_column'], errors='coerce')

# Standardizing string formats (example)
for column in data.select_dtypes(include=['object']).columns:
    data[column] = data[column].str.strip().str.lower()

# Save the cleaned data to a new CSV file
data.to_csv('cleaned_member_employers.csv', index=False)
print(f'Cleaned data saved to cleaned_member_employers.csv')