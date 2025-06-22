import pandas as pd
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns

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

# Standardizing date formats
for column in data.columns:
    if 'date' in column.lower():
        data[column] = pd.to_datetime(data[column], errors='coerce').dt.strftime('%Y-%m-%d')

# Temporal patterns analysis
# Assuming there is a 'date' column to analyze trends over time
if 'date' in data.columns:
    data['date'] = pd.to_datetime(data['date'])
    data.set_index('date', inplace=True)
    data.resample('M').size().plot()
    plt.title('Monthly Employment Trends')
    plt.xlabel('Date')
    plt.ylabel('Number of Records')
    plt.show()

# Clustering analysis
# Assuming we have numerical features to cluster
numerical_data = data.select_dtypes(include=['float64', 'int64'])
if not numerical_data.empty:
    kmeans = KMeans(n_clusters=3)
    clusters = kmeans.fit_predict(numerical_data)
    data['Cluster'] = clusters
    sns.scatterplot(x=numerical_data.iloc[:, 0], y=numerical_data.iloc[:, 1], hue=data['Cluster'], palette='viridis')
    plt.title('Clustering of Employment Data')
    plt.xlabel('Feature 1')
    plt.ylabel('Feature 2')
    plt.show()

# Infer insights from the patterns
# For example, we can look at the mean of each cluster
cluster_means = data.groupby('Cluster').mean()
print('Cluster Means:')
print(cluster_means)

# Save the cleaned data to a new CSV file
cleaned_file_path = 'cleaning_files/cleaned_member_employers.csv'
data.to_csv(cleaned_file_path, index=False)
print(f'Cleaned data saved to {cleaned_file_path}')