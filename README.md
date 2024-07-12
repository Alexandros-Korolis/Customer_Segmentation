<h1><strong>Customer Segmentation</strong></h1>

<h2><strong>Project Purpose</strong></h2>
As an analyst, I've been tasked with analyzing transaction data to provide strategic advice to a pet shop owner in the USA on how to effectively target customers to increase sales.

<h2><strong>About the dataset</strong></h2>
&#8226; fact_sales.csv contains transaction data <br>
&#8226; dim_customers.csv contains customer data <br>
&#8226; dim_products.csv contains products data <br>
&#8226; state_region_mapping.csv contains data above locations <br>
&#8226; Data Cleaning folder contains cleaned data of fact_sales in .csv and sql script for data cleaning <br>
&#8226; RFM Analysis folder contains sql script for rfm analysis

<h2>Exploratory Data Analysis</h2>
&#8226; There were in total <strong>20151 transactions</strong> between <strong>2020-12-01</strong> and <strong>2021-12-09</strong>.<br>
&#8226; Transactions were made by <strong>3143 unique customers</strong>. <br>
<br>
&#8226; <strong>Which customers (top 10) did the most transactions ?</strong> <br>

![alt text](trans_per_cust.PNG) <br>
<br>
&#8226; <strong>Total Sales per product (top 10)? </strong> <br>

![alt text](sales_per_prod.PNG)
<br>
<h2> <strong>RFM Analysis (steps) </strong></h2>
&#8226; Find Recency for each customer. Take as reference date the maximum date. Lower recency values are better <br>
&#8226; Find Frequency for each customer. Count unique number of days of purchases <br>
&#8226; Find Monetary for each customer. Summary of Total Sales. <br>
&#8226; Create RFM scores based on quantiles of distribution. <br>
&#8226; Recency Score. The nearest date gets 4, the furthest 1. <br>
&#8226; Frequency Score. The least frequent gets 1 and the most frequent gets 4 <br>
&#8226; Monetary Score. The least money gets 1, the most money gets 4. <br>

<h2><strong> Categorize customers based on RFM score </strong></h2>
![alt text](Segments.PNG)
<br>





