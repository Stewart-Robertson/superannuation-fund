import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.cluster import KMeans
from datetime import datetime

# Create output directory
output_dir = 'visualisation_files'
os.makedirs(output_dir, exist_ok=True)

# Load first 500 rows
file_path = '../../../data/employment_history.csv'
data = pd.read_csv(file_path)

# Convert date columns to datetime
for col in ['start_date', 'end_date']:
    data[col] = pd.to_datetime(data[col], errors='coerce')

# Feature engineering: Calculate employment duration in days
# For ongoing employments (missing end_date), set it to today
today = pd.Timestamp.today()
data['end_date_filled'] = data['end_date'].fillna(today)
data['employment_duration_days'] = (data['end_date_filled'] - data['start_date']).dt.days

# Create a timestamp string for filenames
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

# 1. Line plot: Number of active employments per month over time

# Extract month periods
data['start_month'] = data['start_date'].dt.to_period('M')
data['end_month'] = data['end_date_filled'].dt.to_period('M')

# Generate monthly timeline from earliest start to latest end
min_month = data['start_month'].min().to_timestamp()
max_month = data['end_month'].max().to_timestamp()
all_months = pd.date_range(min_month, max_month, freq='MS')

def count_active_employments(df, months):
    active_counts = []
    for month_start in months:
        month_end = month_start + pd.offsets.MonthEnd(0)
        active = df[(df['start_date'] <= month_end) & (df['end_date_filled'] >= month_start)]
        active_counts.append({'month': month_start, 'active_employments': active.shape[0]})
    return pd.DataFrame(active_counts)

active_counts_df = count_active_employments(data, all_months)

plt.figure(figsize=(12,6))
sns.lineplot(data=active_counts_df, x='month', y='active_employments', marker='o')
plt.title('Number of Active Employments Over Time')
plt.xlabel('Month')
plt.ylabel('Active Employments')
plt.xticks(rotation=45)
plt.legend(['Active Employments'], loc='upper left')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'active_employments_over_time_{timestamp}.png'))
plt.close()

# 2. Histogram + KDE: Distribution of Employment Duration
plt.figure(figsize=(10,6))
sns.histplot(data['employment_duration_days'].dropna(), bins=50, kde=True, color='skyblue')
plt.title('Distribution of Employment Duration (Days)')
plt.xlabel('Duration (Days)')
plt.ylabel('Count')
plt.legend(['Employment Duration'])
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'employment_duration_distribution_{timestamp}.png'))
plt.close()

# 3. Barplot: Distribution of Employment Type
plt.figure(figsize=(8,5))
order = data['employment_type'].value_counts().index
sns.countplot(data=data, y='employment_type', order=order, palette='muted')
plt.title('Distribution of Employment Types')
plt.xlabel('Count')
plt.ylabel('Employment Type')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'employment_type_distribution_{timestamp}.png'))
plt.close()

# 4. Boxplot: Final Salary by Employment Type
plt.figure(figsize=(10,6))
sns.boxplot(data=data, x='employment_type', y='final_salary', palette='Set2')
plt.title('Final Salary Distribution by Employment Type')
plt.xlabel('Employment Type')
plt.ylabel('Final Salary')
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'final_salary_by_employment_type_{timestamp}.png'))
plt.close()

# 5. Scatter plot with regression: Final Salary vs Employment Duration
plt.figure(figsize=(10,6))
sns.scatterplot(data=data, x='employment_duration_days', y='final_salary', hue='employment_type', alpha=0.7)
sns.regplot(data=data, x='employment_duration_days', y='final_salary', scatter=False, color='red')
plt.title('Final Salary vs Employment Duration')
plt.xlabel('Employment Duration (Days)')
plt.ylabel('Final Salary')
plt.legend(title='Employment Type')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'salary_vs_duration_{timestamp}.png'))
plt.close()

# 6. Heatmap: Top 10 Positions over Years count
# Extract start year
data['start_year'] = data['start_date'].dt.year
pos_year_counts = data.groupby(['start_year', 'position_title']).size().reset_index(name='count')
# Top 10 positions
top_positions = data['position_title'].value_counts().head(10).index
pos_year_pivot = pos_year_counts[pos_year_counts['position_title'].isin(top_positions)]
pos_year_pivot = pos_year_pivot.pivot(index='position_title', columns='start_year', values='count').fillna(0)
plt.figure(figsize=(12,7))
sns.heatmap(pos_year_pivot, annot=True, fmt='g', cmap='YlGnBu')
plt.title('Employment Start Counts of Top 10 Positions Over Years')
plt.xlabel('Year')
plt.ylabel('Position Title')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'top_positions_heatmap_{timestamp}.png'))
plt.close()

# 7. Pairplot: Numerical Features Colored by Employment Type
numeric_cols = ['final_salary', 'employment_duration_days']
if data['employment_type'].nunique() < 10:
    sns_plot = sns.pairplot(data.dropna(subset=numeric_cols+['employment_type']), vars=numeric_cols, hue='employment_type', diag_kind='kde', height=3)
    sns_plot.fig.suptitle('Pairplot of Numerical Features by Employment Type', y=1.02)
    sns_plot.savefig(os.path.join(output_dir, f'pairplot_numerical_{timestamp}.png'))
    plt.close()

# 8. Clustering analysis: KMeans on final_salary and employment_duration_days
cluster_data = data[['final_salary', 'employment_duration_days']].dropna()
scaler = StandardScaler()
features_scaled = scaler.fit_transform(cluster_data)

# Elbow method
sse = []
for k in range(1, 11):
    kmeans = KMeans(n_clusters=k, random_state=42)
    kmeans.fit(features_scaled)
    sse.append(kmeans.inertia_)
plt.figure(figsize=(8,5))
plt.plot(range(1, 11), sse, marker='o')
plt.title('Elbow Method for Optimal Clusters')
plt.xlabel('Number of Clusters')
plt.ylabel('Sum of Squared Distances')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'elbow_method_{timestamp}.png'))
plt.close()

# From elbow, pick k=3
k_opt = 3
kmeans = KMeans(n_clusters=k_opt, random_state=42)
cluster_data['cluster'] = kmeans.fit_predict(features_scaled)

plt.figure(figsize=(10,6))
sns.scatterplot(x=cluster_data['employment_duration_days'], y=cluster_data['final_salary'], hue=cluster_data['cluster'], palette='deep')
plt.title('Clusters of Employment Records')
plt.xlabel('Employment Duration (Days)')
plt.ylabel('Final Salary')
plt.legend(title='Cluster')
plt.tight_layout()
plt.savefig(os.path.join(output_dir, f'clusters_scatterplot_{timestamp}.png'))
plt.close()

print(f'Visualizations saved to folder: {output_dir}')
