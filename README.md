📋 Project Overview


This Power BI project focuses on analyzing retail banking CRM data to track, calculate, and understand customer churn and exits. By identifying high-risk customer segments and regional trends, this dashboard provides actionable insights to improve customer retention and optimize operational efficiency.

🛠️ Tech Stack & Skills
Tool: Power BI Desktop

Data Source: Bank CRM Dataset (Excel/CSV)

DAX Formulas: Calculated columns and measures for Churn Rate and Active Customers

Data Modeling: Star Schema (Fact and Dimension tables)

📈 Key Metrics & DAX Calculations

Here are the core metrics built into this dashboard to calculate churn:

Total Customers:

Code snippet
Total Customers = COUNT(CustomerDim[CustomerID])
Total Exited Customers:

Code snippet
Exited Customers = CALCULATE(COUNT(CustomerDim[CustomerID]), CustomerDim[ExitStatus] = 1)
Churn Rate (%):

Code snippet
Churn Rate = DIVIDE([Exited Customers], [Total Customers], 0)

🔍 Key Insights & Features

Churn by Demographics: Analyzed how age group, gender, and credit scores impact customer exit behavior.

Product & Balance Analysis: Investigated if customers with specific financial products or lower balances have a higher tendency to drop out.

Geographical Trends: Mapped out exit rates across different regions to isolate localized service or retention issues.
