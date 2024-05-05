-- Explore Dataset
select *
from fact_sales;

-- Check the range of dates.
select min("Transaction Date") as "min_date",
		max("Transaction Date") as "max_date"
from fact_sales;

-- How many unique customers do we have ? 
select count(distinct("Customer ID")) as "unique_customers"
from fact_sales;

-- Examine number of transcations per customer.
select "Customer ID", count("Customer ID") as "transcation_count"
from fact_sales
group by "Customer ID"
order by "transcation_count" desc;

copy (select * from transactions_per_customer) to 'D:\trans_per_cust.csv'
delimiter ','
csv header;

-- Examine total sales per product
select "Description", sum("Sales") as "Total Sales"
from fact_sales
group by "Description"
order by "Total Sales" desc;

-- Create view RFM table.

-- For each customer find:
-- Recency : minimum Recency
-- Frequency: count unique number of days of purchases
-- Monetary: summary of Total Sales

alter table fact_sales
add column Recency varchar(255);

update fact_sales
set Recency = '2021-12-09' - "Transaction Date";

create view RFM as 
select 
	"Customer ID",
	cast(min("recency") as numeric) as "Recency",
	cast(count(distinct("Transaction Date")) as numeric) as "Frequency",
	round(cast(sum("Sales") as numeric),2) as "Monetary"
from fact_sales
group by "Customer ID";


-- Create RFM scores based on quantiles of distribution.

-- Date from customer's last purchase.
-- The nearest date gets 4 and the furthest date gets 1.
-- Total number of purchases.
-- The least frequency gets 1 and the maximum frequency gets 4.
-- Total spend by the customer.The least money gets 1, the most money gets 4.
create view RFM_scores as
select "Customer ID","Recency","Frequency","Monetary",
ntile(4) over (order by "Recency" desc) as "recency_score",
ntile(4) over (order by "Frequency") as "frequency_score",
ntile(4) over (order by "Monetary") as "monetary_score"
from RFM
order by "Customer ID" asc;

create view RFM_segments as
select "Customer ID","Recency","Frequency","Monetary",
ntile(4) over (order by "Recency" desc) as "recency_score",
ntile(4) over (order by "Frequency") as "frequency_score",
ntile(4) over (order by "Monetary") as "monetary_score",
concat(cast("recency_score" as char),cast("frequency_score" as char),cast("monetary_score" as char)) as "RFM_segment",
"recency_score"+"frequency_score"+"monetary_score" as "RFM_score"
from RFM_scores;

-- categorize numbers from customers

-- '[3-4][3-4]4': 'VIP',
-- '[2-3-4][1-2-3-4]4': 'Top Recent',
-- '1[1-2-3-4]4': 'Top at Risk ',
-- '[3-4][3-4]3': 'High Promising',
-- '[2-3-4][1-2]3': 'High New',
-- '2[3-4]3': 'High Loyal',        
-- '[3-4][3-4]2': 'Medium Potential',
-- '[2-3-4][1-2]2': 'Medium New',
-- '2[3-4]2': 'Medium Loyal',        
-- '4[1-2-3-4]1': 'Low New',
-- '[2-3][1-2-3-4]1': 'Low Loyal',    
-- '1[1-2-3-4][1-2-3]': 'Need Activation'
create view labels as 
SELECT *,
CASE
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (3,4) and "frequency_score" in (3,4) and "monetary_score" = 4) THEN 'VIP'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (2,3,4) and "frequency_score" in (1,2,3,4) and "monetary_score" = 4) THEN 'Top Recent'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 1 and "frequency_score" in (1,2,3,4) and "monetary_score" = 4) THEN 'Top at Risk'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (3,4) and "frequency_score" in (3,4) and "monetary_score" = 3) THEN 'High Promising'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (2,3,4) and "frequency_score" in (1,2) and "monetary_score" = 3) THEN 'High New'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 2 and "frequency_score" in (3,4) and "monetary_score" = 3) THEN 'High Loyal'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (3,4) and "frequency_score" in (3,4) and "monetary_score" = 2) THEN 'Medium Potential'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (2,3,4) and "frequency_score" in (1,2) and "monetary_score" = 2) THEN 'Medium New'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 2 and "frequency_score" in (3,4) and "monetary_score" = 2) THEN 'Medium Loyal'  
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 4 and "frequency_score" in (1,2,3,4) and "monetary_score" = 1) THEN 'Low New'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" in (2,3) and "frequency_score" in (1,2,3,4) and "monetary_score" = 1) THEN 'Low Loyal'
  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 1 and "frequency_score" in (1,2,3,4) and "monetary_score" in (1,2,3)) THEN 'Need Activation'  
END as "segment"
FROM fact_sales; 

-- Calculate customers per segment and stats per segment
select "segment",
	round(cast(sum("Sales") as numeric),2) as "Total Monetary",
	count("segment") as "Total_Customers",
	round(cast(avg(cast("recency" as numeric)) as numeric),2) as "Mean_recency",
	(sum("Sales")/1250704)*100 as "Monetary %",
	round((count(distinct("Customer ID"))::decimal/3143)*100,3)  as "Customers %"	
from labels
group by "segment"
order by "Total Monetary" desc;

-- Observe that VIP and Top Recent customers (22% of customers) produce 
-- 77.7 % of total sales 



