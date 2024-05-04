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

-- Champions [4][4][4]
select *
from RFM_segments
where "RFM_score"=12;

select *
from fact_sales
where "Customer ID" in
(select "Customer ID"
from RFM_segments
where "RFM_score"=12);


-- Potential Loyalists [4][2-3][3]
select *
from RFM_segments
where "recency_score" = 4
and "frequency_score">=2 and "frequency_score"<=3
and "monetary_score"=3;

select *
from fact_sales
where "Customer ID" in
(select "Customer ID"
from RFM_segments
where "recency_score" =4
and "frequency_score">=2 and "frequency_score"<=3
and "monetary_score"=3);

-- New Customers but high overall RMF [3-4][1][2-3-4]
select *
from RFM_segments
where "recency_score" >= 3
and "frequency_score"= 1
and "monetary_score">= 2;

select *
from fact_sales
where "Customer ID" in
(select "Customer ID"
from RFM_segments
where "recency_score" >= 3
and "frequency_score"= 1
and "monetary_score">= 2);

-- At risk customers [2][3-4][3-4] (Buy frequently, big amount but not recently)
select *
from RFM_segments
where "recency_score" = 2
and "frequency_score">=3
and "monetary_score">= 3;

select *
from fact_sales
where "Customer ID" in
(select "Customer ID"
from RFM_segments
where "recency_score" = 2
and "frequency_score">=3
and "monetary_score">= 3);

-- Can't lose them [1][4][1-2-3-4]
select *
from RFM_segments
where "recency_score" = 1
and "frequency_score" = 4;

select *
from fact_sales
where "Customer ID" in
(select "Customer ID"
from RFM_segments
where "recency_score" = 1
and "frequency_score" = 4);


-- 
--create view labels as 
--SELECT *,
--CASE
--  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "RFM_score"=12) THEN 'Champions'
--  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" =4 and "frequency_score">=2 and "frequency_score"<=3 and "monetary_score"=3) THEN 'Potential Loyalists'
--  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" >= 3 and "frequency_score"= 1 and "monetary_score">= 2) THEN 'New Customers'
--  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 2 and "frequency_score">=3 and "monetary_score">= 3) THEN 'At risk customers'
--  WHEN "Customer ID" in (select "Customer ID" from RFM_segments where "recency_score" = 1 and "frequency_score" = 4) THEN 'Cant lose them'
--END as "segment"
--FROM fact_sales; 

-- Create customer categories based on rfm score. Then create a view table as above
-- based on the customer categories.