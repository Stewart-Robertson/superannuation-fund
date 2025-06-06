# Data Dictionary for the Gold Layer

The Gold layer in the database contains business-ready data that can be used for ad-hoc queries, BI reporting, machine learning, etc.

This layer uses a **_Star Schema_** with three _dimension_ tables and one _fact_ table:

|Table Type|Table Name  |
|--|--|
| Dimension |gold.dim_member  |
| Dimension |gold.dim_employer |
| Dimension |gold.dim_employment |
| Fact | gold.fact_member_contribution_performance |

![Star schema data model](https://github.com/user-attachments/assets/ca7f073d-3fa6-450e-97b3-2e2282e31acc)


## Member dimension table

**Purpose**: Stores information on Super Fund members.

| Column Name |Data Type | Description|
|--|--|--|
|MEMBER_ID | VARCHAR(50) | The table's primary key |
|FIRST_NAME | VARCHAR(50) | Member's first name |
|LAST_NAME | VARCHAR(50) | Member's last name |
|FULL_NAME | VARCHAR(101) | Member's full name |
|DATE_OF_BIRTH | DATE | Member's D.O.B |
|AGE | NUMBER(9,0) | Member's age |
|GENDER | VARCHAR(10) | Member's gender (male, female, other) |
|INVESTMENT_OPTION | VARCHAR(50) | Member's chosen investment option e.g. conservative, high-growth |
|SUPER_BALANCE | NUMBER(38,0) | Member's super balance (A$) |
|INSURANCE_COVERAGE | NUMBER(38,0) | Member's insurance coverage (A$) |
|SALARY | NUMBER(38,0) | Member's salary (A$) |
|EMPLOYMENT_STATUS | VARCHAR(50) | Member's employment status e.g. full-time-employed, part-time |
|EMPLOYEE_CONTRIBUTION_RATE | NUMBER(5,4) | Member's super contribution rate |
|EMPLOYER_CONTRIBUTION_RATE | NUMBER(5,4) | Member's employer's contribution rate |
|AGE_GROUP | VARCHAR(5) | Age group member falls within e.g. 18-24, 25-34, etc. |
|LIFE_STAGE | VARCHAR(25) | Life stage member falls within e.g. early career/student, peak earning |
|BALANCE_TIER | VARCHAR(7) | Member's balance tier (low, medium, high, premium) |
|INSURANCE_LEVEL | VARCHAR(12) | Level of insurance taken out by member (low-insured, mid-insured, high-insured) |
|INSURANCE_PREMIUM_REVENUE | NUMBER(38,3) | Premium calculated according to age and insurance coverage (A$) |
|SUPER_GROWTH_POTENTIAL_SEGMENT | VARCHAR(28) | Member's super balance growth potential categorised according to salary, age, and current super balance e.g. low, high, premium |
|CAMPAIGN_PRIORITY | VARCHAR(25) | Members categories according to super/insurance upsell opportunity. Calculated by salary, age, super balance, and insurance coverage e.g. early career intervention, priority campaign target |
|RISK_APPETITE | VARCHAR(10) | Member's risk appetite categories according to investment option (low, medium, high, aggresive) |

## Employer dimension table

**Purpose**: Stores information on _current_ employers of Super Fund members.

| Column Name |Data Type | Description|
|--|--|--|
|RELATIONSHIP_ID | NUMBER(38,0) | The table's primary key |
|EMPLOYER_ID | NUMBER(38,0) | ID of member's current employer |
|COMPANY_NAME | VARCHAR(50) | Name of member's current employer |
|INDUSTRY | VARCHAR(50) | Industry in which member is employed |
|HEAD_OFFICE_STATE | VARCHAR(50) | State in which member's employer's HQ is located |
|TOTAL_EMPLOYEES | NUMBER(38,0) | Total number of people employed by member's employer |
|AVG_SALARY | NUMBER(38,0) | Average salary within member's employer (A$) |
|DEFAULT_SUPER_FUND_OPTION | VARCHAR(50) | Member's employer's default investment option for its employees |
|DEFAULT_FUND_RISK_PROFILE | VARCHAR(50) | The default risk profile categorised by the default investmet option |
|SALARY_TIER | VARCHAR(13) | Member's salary tier (below average, average, above average) |
|INDUSTRY_GROWTH_POTENTIAL | VARCHAR(11) | Certain known industries (e.g. mining, technology, renewable energy etc.) categorised according to growth potential (e.g. high-growth, stable, declining, unknown) |
|PARTNERSHIP_VALUE_TIER | VARCHAR(8) | Member's employer categorised according to total super balance in fund from company's employees (bronze, silver, gold, platinum) |

## Employment dimension table

**Purpose**: Stores employment history of Super Fund members.

| Column Name |Data Type | Description|
|--|--|--|
|EMPLOYMENT_ID | NUMBER(38,0) | The table's primary key |
|MEMBER_ID | VARCHAR(50) | ID of member |
|EMPLOYER_ID | NUMBER(38,0) | ID of member's employer |
|POSITION_TITLE | VARCHAR(50) | Member's job title |
|START_DATE | DATE | When member started the role |
|END_DATE | DATE | When member ended the role (if current role, end date is 9999-31-12) |
|EMPLOYMENT_TYPE | VARCHAR(50) | The type of employment, e.g. full-time, part-time |
|FINAL_SALARY | NUMBER(38,0) | Member's final salary in the role (A$) |
|EMPLOYMENT_DURATION_DAYS | NUMBER(9,0) | How many days the member was in the role |
|EMPLOYMENT_DURATION_YEARS | NUMBER(18,2) | How many years the member was in the role |
|IS_CURRENT_EMPLOYMENT | BOOLEAN | Whether the role is the member's current job |
|MONTHS_UNEMPLOYED | NUMBER(9,0) | How many months unemployed/student/retired members have been out of work |

## Member fund performance fact table

**Purpose**: Shows key metrics, opportunities, and efficiency of the fund's Superannuation and insurance products.
  
| Column Name |Data Type | Description|
|--|--|--|
|MEMBER_ID | VARCHAR(50) | ID of the member: foreign key from dim_member |
|RELATIONSHIP_ID | NUMBER(38,0) | Relationship ID: foreign key from dim_employer |
|EMPLOYMENT_ID | NUMBER(38,0) | Employment ID: foreign key from dim_employment |
|CURRENT_SALARY | NUMBER(38,0) | Member's current salary (A$) |
|SUPER_BALANCE | NUMBER(38,0) | Member's super balance (A$) |
|INSURANCE_COVERAGE | NUMBER(38,0) | Member's insurance coverage (A$) |
|EMPLOYER_CONTRIBUTION_RATE | NUMBER(5,4) | Member's super contribution rate |
|EMPLOYEE_CONTRIBUTION_RATE | NUMBER(5,4) | Member's employer's super contribution rate |
|COMBINED_CONTRIBUTION_RATE | NUMBER(6,4) | Total contribution rate for member |
|ANNUAL_EMPLOYER_CONTRIBUTION | NUMBER(38,4) | Total contribution from member's employer in the calendar year (A$) |
|ANNUAL_EMPLOYEE_CONTRIBUTION | NUMBER(38,4) | Total contribution from member in the calendar year (A$) |
|TOTAL_ANNUAL_CONTRIBUTION | NUMBER(38,4) | Total combined contribution for member in the calendar year (A$) |
|POTENTIAL_ADDITIONAL_CONTRIBUTION | NUMBER(38,4) | Total potential additional contribution in A$ if contributions were rasied to the max level (max=0.3) |
|CONTRIBUTION_RATE_GAP | NUMBER(7,4) | Gap between current contribution _rate_ and max potential contribution _rate_ (0.3-combined contribution) |
|INSURANCE_COVERAGE_GAP | NUMBER(38,0) | Gap between member's current insurance coverage and max potential coverage (max=A$1,000,000) (A$) |
|INSURANCE_COVERAGE_BY_SALARY | NUMBER(38,6) | Member's insurance coverage divided by current salary |
|SUPER_BALANCE_BY_SALARY | NUMBER(38,6) | Member's super balance divided by current salary |
|CONTRIBUTION_EFFICIENCY_RATIO | NUMBER(38,10) | Member's (salary X total contribution)/(salary X maximum contribution). Null for students/retirees/unemployed. |
