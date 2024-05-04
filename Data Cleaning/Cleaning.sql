-- Explore the transaction dataset
select *
from fact_sales;

-- Check for null values.
select count(*) as "total rows",
		count("Transaction Date") as "transaction date",
		count("Customer ID") as "customer id",
		count("Description") as "description",
		count("Stock Code") as "stock code",
		count("Invoice No") as "invoice no",
		count("Quantity") as "quantity",
		count("Sales") as "sales",
		count("Unit Price") as "unit price"
from fact_sales;

-- Customer ID and Invoice No columns have nulls.
-- I will drop rows that contain null in the Customer ID column.
DELETE FROM fact_sales 
WHERE "Customer ID" isnull;

-- Create a new column Transaction Time
alter table "fact_sales" add "Transaction_Time" character varying ;

update "fact_sales"
set "Transaction_Time" = substring("Transaction Date" from position(' ' in "Transaction Date") for length("Transaction Date"));

-- Remove Time from Transaction Date column.
update "fact_sales"
set "Transaction Date" = trim(substring("Transaction Date" from 1 for position(' ' in "Transaction Date")));

-- Change Quantity column type to integer.
alter table "fact_sales"
alter column "Quantity" type INTEGER using "Quantity"::integer;

-- Change Unit Price column type to float.
alter table "fact_sales"
alter column "Unit Price" type float using "Unit Price"::float;

-- Change Sales column type to float.
alter table "fact_sales"
alter column "Sales" type float using "Sales"::float;

-- Change Transaction Date column time to Date
alter table fact_sales 
alter column "Transaction Date" type DATE 
using to_date("Transaction Date", 'MM/DD/YYYY');

-- We have 0 values and negative values in columns Quantity, Sales, Unit Price
select min("Quantity"),min("Sales"),min("Unit Price")
from fact_sales;

update "fact_sales"
set "Quantity" = abs("Quantity");

update "fact_sales"
set "Sales" = abs("Sales");

-- Delete rows with 0 sales
DELETE FROM fact_sales 
WHERE "Sales" = 0;

-- Export to csv 
copy fact_sales to 'D:\clean_fact_sales.csv'
delimiter ','
csv header;