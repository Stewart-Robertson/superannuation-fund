import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os

# Load the first 500 rows of the dataset
file_path = '../../../data/superannuation_members.csv'
df = pd.read_csv(file_path)
output_path = 'data_visualisations'
if not os.path.exists(output_path):
    os.makedirs(output_path)

# Convert date_of_birth to datetime format
if 'date_of_birth' in df.columns:
    df['date_of_birth'] = pd.to_datetime(df['date_of_birth'], errors='coerce')

# Set seaborn style
sns.set(style='whitegrid')

# 1. Distribution of Salary
plt.figure(figsize=(10, 6))
sns.histplot(df['salary'].dropna(), bins=30, kde=True, color='skyblue')
plt.title('Distribution of Salary')
plt.xlabel('Salary')
plt.ylabel('Frequency')
plt.tight_layout()
plt.savefig(output_path+'/'+'salary_distribution.png')
plt.show()
plt.close()

# 2. Boxplot of Super Balance by Gender
if 'gender' in df.columns:
    plt.figure(figsize=(10, 6))
    sns.boxplot(x='gender', y='super_balance', data=df, palette='pastel')
    plt.title('Super Balance Distribution by Gender')
    plt.xlabel('Gender')
    plt.ylabel('Super Balance')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'super_balance_by_gender.png')
    plt.show()
    plt.close()

# 3. Scatter plot of Salary vs Super Balance colored by Employment Status
if all(col in df.columns for col in ['salary', 'super_balance', 'employment_status']):
    plt.figure(figsize=(12, 7))
    sns.scatterplot(x='salary', y='super_balance', hue='employment_status', data=df, palette='Set2')
    plt.title('Salary vs Super Balance by Employment Status')
    plt.xlabel('Salary')
    plt.ylabel('Super Balance')
    plt.legend(title='Employment Status', bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'salary_vs_super_balance.png')
    plt.show()
    plt.close()

# 4. Bar plot of Count of Members by Investment Option
if 'investment_option' in df.columns:
    plt.figure(figsize=(12, 6))
    order = df['investment_option'].value_counts().index
    sns.countplot(y='investment_option', data=df, order=order, palette='viridis')
    plt.title('Count of Members by Investment Option')
    plt.xlabel('Count')
    plt.ylabel('Investment Option')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'members_by_investment_option.png')
    plt.show()
    plt.close()

# 5. Boxplot of Employer Contribution Rate by Insurance Coverage
if all(col in df.columns for col in ['employer_contribution_rate', 'insurance_coverage']):
    plt.figure(figsize=(12, 7))
    sns.boxplot(x='insurance_coverage', y='employer_contribution_rate', data=df, palette='coolwarm')
    plt.title('Employer Contribution Rate by Insurance Coverage')
    plt.xlabel('Insurance Coverage')
    plt.ylabel('Employer Contribution Rate')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(output_path+'/'+'employer_contribution_by_insurance.png')
    plt.show()
    plt.close()

# 6. Scatter plot with regression: Employee Contribution Rate vs Employer Contribution Rate
if all(col in df.columns for col in ['employee_contribution_rate', 'employer_contribution_rate']):
    plt.figure(figsize=(10, 6))
    sns.regplot(x='employee_contribution_rate', y='employer_contribution_rate', data=df, scatter_kws={'alpha':0.5}, line_kws={'color':'red'})
    plt.title('Employee Contribution Rate vs Employer Contribution Rate')
    plt.xlabel('Employee Contribution Rate')
    plt.ylabel('Employer Contribution Rate')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'employee_vs_employer_contribution.png')
    plt.show()
    plt.close()

# 7. Age Distribution Histogram
import numpy as np
if 'date_of_birth' in df.columns:
    today = pd.Timestamp('today')
    df['age'] = df['date_of_birth'].apply(lambda x: (today - x).days // 365 if pd.notnull(x) else np.nan)
    plt.figure(figsize=(10, 6))
    sns.histplot(df['age'].dropna(), bins=30, kde=True, color='green')
    plt.title('Age Distribution of Members')
    plt.xlabel('Age')
    plt.ylabel('Count')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'age_distribution.png')
    plt.show()
    plt.close()

# 8. Violin plot of Super Balance by Employment Status
if all(col in df.columns for col in ['super_balance', 'employment_status']):
    plt.figure(figsize=(12, 7))
    sns.violinplot(x='employment_status', y='super_balance', data=df, palette='muted', inner='quartile')
    plt.title('Super Balance Distribution by Employment Status')
    plt.xlabel('Employment Status')
    plt.ylabel('Super Balance')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(output_path+'/'+'super_balance_by_employment_status.png')
    plt.show() 
    plt.close()

# 9. Bar plot of Gender counts
if 'gender' in df.columns:
    plt.figure(figsize=(6, 5))
    sns.countplot(x='gender', data=df, palette='husl')
    plt.title('Count of Members by Gender')
    plt.xlabel('Gender')
    plt.ylabel('Count')
    plt.tight_layout()
    plt.savefig(output_path+'/'+'members_by_gender.png')
    plt.show()
    plt.close()
