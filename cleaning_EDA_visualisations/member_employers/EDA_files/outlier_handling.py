import pandas as pd
from scipy import stats

# Load the data
data = pd.read_csv('../data/member_employers.csv', nrows=500)

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

# Filter the data to remove outliers based on IQR
data_no_outliers_iqr = data[outlier_condition]

# Save the cleaned data to a new CSV file
cleaned_file_path = 'cleaning_files/cleaned_member_employers_with_outliers_removed.csv'
data_no_outliers.to_csv(cleaned_file_path, index=False)
print(f'Cleaned data saved to {cleaned_file_path}')