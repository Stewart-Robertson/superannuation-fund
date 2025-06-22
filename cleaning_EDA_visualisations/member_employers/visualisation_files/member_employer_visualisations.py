import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os
import argparse

file_path = '../../../data/member_employers.csv'
df = pd.read_csv(file_path)

# Basic data inspection (printed for user to understand the data)
print("Data head:")
print(df.head())
print("Data info:")
print(df.info())
print("Data description:")
print(df.describe(include='all'))

# Set seaborn style for clarity and good aesthetics
sns.set(style='whitegrid')

# Create output directory if it does not exist
output_dir = 'data_visualisations'
os.makedirs(output_dir, exist_ok=True)

# Helper function to save plots robustly

def save_plot(fig, name):
    filename = os.path.join(output_dir, f"{name}.png")
    fig.savefig(filename, bbox_inches='tight')
    plt.close(fig)

# 1. Distribution histograms for numeric columns with KDE
numeric_cols = df.select_dtypes(include=['number']).columns.tolist()
for col in numeric_cols:
    fig, ax = plt.subplots(figsize=(8,5))
    sns.histplot(df[col], kde=True, ax=ax, color='blue')
    ax.set_title(f'Distribution of {col}')
    ax.set_xlabel(col)
    ax.set_ylabel('Frequency')
    save_plot(fig, f'distribution_{col}')

# 2. Boxplots for numeric columns to identify outliers
for col in numeric_cols:
    fig, ax = plt.subplots(figsize=(8,5))
    sns.boxplot(x=df[col], ax=ax, color='orange')
    ax.set_title(f'Boxplot of {col}')
    save_plot(fig, f'boxplot_{col}')

# 3. Countplots for categorical columns with reasonable cardinality
cat_cols = df.select_dtypes(exclude=['number']).columns.tolist()
for col in cat_cols:
    unique_values = df[col].nunique()
    if 1 < unique_values < 30:
        fig, ax = plt.subplots(figsize=(10,6))
        sns.countplot(y=col, data=df, order=df[col].value_counts().index, ax=ax, palette='viridis')
        ax.set_title(f'Countplot of {col}')
        save_plot(fig, f'countplot_{col}')

# 4. Correlation heatmap for numeric features
if len(numeric_cols) > 1:
    corr = df[numeric_cols].corr()
    fig, ax = plt.subplots(figsize=(10,8))
    sns.heatmap(corr, annot=True, fmt='.2f', cmap='coolwarm', ax=ax)
    ax.set_title('Correlation Heatmap of Numeric Features')
    save_plot(fig, 'correlation_heatmap')

# 5. Pairplot for numeric features to explore relationships
if len(numeric_cols) > 1:
    pairplot = sns.pairplot(df[numeric_cols].dropna())
    pairplot.fig.suptitle('Pairplot of Numeric Features', y=1.02)
    pairplot.savefig(os.path.join(output_dir, 'pairplot_numeric_features.png'))
    plt.close()

# 6. Bar plots of average numeric values grouped by categorical columns
for cat_col in cat_cols:
    unique_values = df[cat_col].nunique()
    if 1 < unique_values < 30:
        for num_col in numeric_cols:
            grouped = df.groupby(cat_col)[num_col].mean().sort_values(ascending=False)
            fig, ax = plt.subplots(figsize=(10,6))
            sns.barplot(x=grouped.values, y=grouped.index, ax=ax, palette='magma')
            ax.set_title(f'Average {num_col} by {cat_col}')
            ax.set_xlabel(f'Average {num_col}')
            ax.set_ylabel(cat_col)
            save_plot(fig, f'avg_{num_col}_by_{cat_col}')

# 7. Countplots showing relationship between two categorical variables if available
if len(cat_cols) >= 2:
    cat1 = cat_cols[0]
    cat2 = cat_cols[1]
    fig, ax = plt.subplots(figsize=(12,8))
    sns.countplot(data=df, x=cat1, hue=cat2, ax=ax, palette='Set2')
    ax.set_title(f'Countplot of {cat1} grouped by {cat2}')
    plt.xticks(rotation=45)
    save_plot(fig, f'countplot_{cat1}_by_{cat2}')

# Suggestion: To explore interactivity in the future, consider using plotly.express or bokeh libraries

print(f"Visualizations created and saved to the '{output_dir}' directory.")