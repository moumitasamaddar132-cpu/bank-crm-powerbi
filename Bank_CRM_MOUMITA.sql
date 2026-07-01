create database Bank_CRM;
use Bank_CRM;

select * from ActiveCustomer;
select * from Bank_churn;
select * from CreditCard;
select * from Customerinfo;
select * from ExitCustomer;
select * from Gender;
select * from Geography;

-- Objective Questions

-- O1. What is the distribution of account balances across different regions?

select g.GeographyLocation as Region,
count(*) as NumofCustomers,
min(b.Balance) as MinBalance,
max(b.Balance) as MaxBalance,
round(avg(b.Balance),2) as AvgBalance,
round(sum(b.Balance),2) as TotalBalance
from Bank_churn b 
left join Customerinfo c 
on b.Customerid = c.Customerid
left join Geography g 
on c.GeographyID = g.GeographyID 
group by g.GeographyLocation;

-- O2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. 

select CustomerID, Surname, EstimatedSalary, Bank_DOJ
from Customerinfo
where Bank_DOJ between '2019-10-01' and '2019-12-31'
order by EstimatedSalary desc
limit 5;

-- O3. Calculate the average number of products used by customers who have a credit card. 

 select avg(NumOfProducts)
 from Bank_churn
 where HasCrCard = 1;
 
--  O4. Determine the churn rate by gender for the most recent year in the dataset.

select  g.GenderCategory,
round((SUM(CASE WHEN b.Exited = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Churn_Rate_Percentage
from Bank_churn b
join Customerinfo c on b.CustomerID = c.CustomerID
join Gender g on c.GenderID = g.GenderID
where year(c.Bank_doj) = (
       select max(year(Bank_doj)) 
        from Customerinfo
    )
group by g.GenderCategory
order by Churn_Rate_Percentage desc;

-- O5. Compare the average credit score of customers who have exited and those who remain. (SQL)

select e.ExitCategory,avg(b.CreditScore) as avg_creditscore
from Bank_churn b
join ExitCustomer e
on b.Exited = e.ExitID
group by e.ExitCategory;

-- O6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? 

select g.GenderCategory,count(*) as NumActiveAccounts,round(avg(c.EstimatedSalary),2) as avg_esti_salary
from Bank_churn b
join Customerinfo c 
on b.Customerid= c.Customerid 
join Gender g 
on c.GenderID = g.GenderID
where b.ISActiveMember = 1
group by g.GenderCategory;

-- O7. Segment the customers based on their credit score and identify the segment with the highest exit rate. 

select case when b.CreditScore >= 800 then "Excellent" 
when b.CreditScore between 740 and 799 then "Very Good"
when b.CreditScore between 670 and 739 then "Good"
when b.CreditScore between 500 and 669 then "Fair"
else "Bad"
end as Segment,
count(*) as TotalCustomer,
count(case when Exited = 1 then 1 end) as exitcount,
round(count(case when Exited = 1 then 1 end)*100 / count(*),2) as exit_rate
from Bank_churn b
group by segment
order by exit_rate desc;

-- O8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. 

select g.GeographyLocation,
  sum(case when b.IsActiveMember = 1 then 1 else 0 end) as TotalActiveCustomers
from  Customerinfo c 
join Geography g 
on c.GeographyID = g.GeographyID
join Bank_churn b
on c.Customerid = b.Customerid
where b.Tenure > 5
group by g.GeographyLocation 
order by TotalActiveCustomers desc ;

-- O9. What is the impact of having a credit card on customer churn, based on the available data?

select 
    case when b.Hascrcard = 1 then 'CreditCardHolder' else 'NoCreditCard' end as Customertype,
    count(*) as Totalcustomers,
    count(case when b.Exited = 1 then 1 end) as Exitcount,
    round(count(case when b.Exited = 1 then 1 end) * 100 / count(*), 2) as Exitrate
from bank_churn b
group by Customertype
order by Exitrate desc;

-- O10. For customers who have exited, what is the most common number of products they have used?

select NumOfProducts,
count(*) as TotalCutomers
from Bank_churn
where Exited = 1
group by NumOfProducts;

-- O11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

select year(Bank_doj) as Year,
count(*) TotalCustomers
from Customerinfo
group by Year
order by Year;

-- O12. Analyze the relationship between the number of products and the account balance for customers who have exited.

select NumOfProducts,
count(*) as TotalCustomers,
round(sum(Balance),2) as AccountBalance
from Bank_churn
where Exited =1
group by NumOfProducts;

-- O13.Identify any potential outliers in terms of balance among customers who have remained with the bank.

-- please check answer in document.

-- 14. How many different tables are given in the dataset, out of these tables which table only consists of categorical variables?

 -- please check answer in document.

-- O15.  Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. 

with cte1 as (
select case when GenderID = 1 then "Male"
else "Female" 
end as Gender,
round(avg(EstimatedSalary),2) as AvgSalary,
GeographyID
from Customerinfo 
group by Gender,GeographyID
)
select *,
rank() over(partition by GeographyID order by AvgSalary desc) as Ranking
from cte1
order by  GeographyID,Ranking;
 
--  O16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

select case when Age between 18 and 29 then '18-30'
when Age between 30 and 50 then '30-50'
else '50 and above'
end as AgeGroup,
round(avg(b.Tenure),2) as AvgTenure 
from Customerinfo c 
join Bank_churn b 
on b.Customerid = c.Customerid
where b.Exited = 1
group by AgeGroup
order by AgeGroup;

-- O17.Is there any direct correlation between salary and the balance of the customers? And is it different for people who have exited or not?

-- please check answer in document.

-- O18.Is there any correlation between the salary and the Credit score of customers?

select c.Customerid,
Surname as CustomerName,
EstimatedSalary as Salary,
CreditScore
from Customerinfo c 
join Bank_churn b 
on c.Customerid = b.Customerid 
order by Salary desc, CreditScore desc;


-- O19. Rank each bucket of credit score as per the number of customers who have churned the bank.

with creditbucket as (
    select Customerid,
        case 
            when CreditScore between 0 and 579 then 'poor'
            when CreditScore between 580 and 669 then 'fair'
            when CreditScore between 670 and 739 then 'good'
            when CreditScore between 740 and 800 then 'very good'
            else 'excellent'
        end as CreditBucket
    from Bank_churn
    where Exited = 1
),
bucket_summary as (
    select  CreditBucket,
           count(Customerid) as TotalCustomers
    from creditbucket
    group by creditbucket
)
select  CreditBucket,
       TotalCustomers,
       dense_rank() over(order by TotalCustomers desc) as ranking
from bucket_summary;


-- O20.-- According to the age buckets find the number of customers who have a credit card. Also retrieve those buckets that have lesser than average number of credit cards per bucket.

with cte1 as (
    select 
        case 
		when c.Age between 18 and 30 then 'Adult'
		when c.Age between 31 and 50 then 'Middle-Aged'
		else 'Old-Aged'
        end as AgeGroup,
        count(case when b.HasCrCard = 1 then 1 end) as CustomersWithCard
    from Customerinfo c
    join Bank_churn b 
	on c.Customerid = b.Customerid
    group by AgeGroup
)
select *
from cte1
where CustomersWithCard < (
    select avg(CustomersWithCard) 
    from (
	select 
	case 
	when c.Age between 18 and 30 then 'Adult'
	when c.Age between 31 and 50 then 'Middle-Aged'
	else 'Old-Aged'
	end as AgeGroup,
	count(case when b.HasCrCard = 1 then 1 end) as CustomersWithCard
	from Customerinfo c
	join Bank_churn b 
	on c.Customerid = b.Customerid
	group by AgeGroup
    ) as subquery
);

-- O21. Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

with cte1 as (
select g.GeographyLocation,
count(*) TotalCustomers,
round(avg(b.Balance),2) as AvgBalance
from Bank_churn b
join Customerinfo c 
on b.Customerid = c.Customerid 
join Geography g 
on c.GeographyID = g.GeographyID
where b.Exited = 1
group by g.GeographyLocation
)
select *,
rank() over(order by TotalCustomers desc, AvgBalance desc) as Ranking 
from cte1;


-- O22.As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.

select Customerid, Surname,
concat(Customerid," ", Surname) as CustomerID_Surname
from Customerinfo;

-- O23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

select *,
case when Exited =1 then 'Exit'
else 'Retain'
end as ExitCategory
from Bank_churn;

-- O24. Were there any missing values in the data, using which tool did you replace them and what are the ways to handle them?

-- please check answer in document.

-- O25.Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.

select b.Customerid, c.Surname as LastName, 
case when b.IsActiveMember = 1 then 'Active'
else 'No Active'
end as ActiveCategory
from Bank_churn b 
join Customerinfo c 
on b.Customerid = c.Customerid 
where c.Surname like '%on';

-- O26. Can you observe any data disrupency in the Customer’s data? As a hint it’s present in the IsActiveMember and Exited columns. One more point to consider is that the data in the Exited Column is absolutely correct and accurate.

select  *
from bank_churn b 
where b.Exited =1 and b.IsActiveMember =1;


-- SUBJECTIVE QUESTIONS 

-- S5. Customer Tenure Value Forecast: How would you use the available data to model and predict the lifetime (tenure) value in the bank of different customer segments?


select c.Customerid,c.Surname as CustomerName,c.Age,g.GenderCategory,
b.CreditScore,c.EstimatedSalary,b.Balance,b.NumOfProducts,cc.Category,a.ActiveCategory,e.ExitCategory,
timestampdiff(YEAR, STR_TO_DATE(c.Bank_DOJ, '%Y-%m-%d'), CURDATE()) AS Years 
from Customerinfo c 
join Bank_churn b 
on c.Customerid = b.Customerid
join CreditCard cc
on b.HasCrCard = cc.CreditID
join Gender g 
on c.GenderID = g.GenderID
join ActiveCustomer a
on b.IsActiveMember = a.ActiveID
join  ExitCustomer e
on b.Exited = e.ExitID;


-- S9. Utilize SQL queries to segment customers based on demographics and account details.

select c.CustomerID, c.Age,b.CreditScore,
b.Balance,b.Tenure,g.GenderCategory,geo.GeographyLocation,
case
	when c.Age < 25 then 'Youth (Under 25)'
	when c.Age between 25 and 35 then 'Young Adults (25-35)'
	when c.Age between 36 and 50 then 'Middle Age (36-50)'
	else 'Senior (Above 50)' end as AgeGroup,
case
	when b.CreditScore < 500 then 'Poor Credit'
	when b.CreditScore between 500 and 700 then 'Average Credit'
	else 'Good Credit' end as CreditScoreCategory,
case 
	when b.Balance < 10000 then 'Low Balance'
	when b.Balance between 10000 and 50000 then 'Medium Balance'
	else 'High Balance' end as BalanceCategory,
case
	when b.Tenure < 2 then 'New Customer'
	when b.Tenure between 2 and 5 then 'Moderate Customer'
	else 'Loyal Customer' end as TenureSegment,
case
	when cc.CreditID = 1 then 'Credit Card Holder'
	else 'Non-Credit Card Holder' end as CreditCardSegment
from bank_churn b
join customerinfo c on c.CustomerID=b.CustomerID
join gender g on g.GenderID=c.GenderID
join geography geo on geo.GeographyID=c.GeographyID
join creditcard cc on cc.CreditID=b.HasCrCard;


-- S14. In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?

alter table Bank_churn
rename column HasCrCard to Has_creditcard;
select * from Bank_churn;
