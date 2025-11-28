--1.CREATE DATABASE--

--2.CREATE TABLE--

CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    transaction_date DATE,
    transaction_time TIME,
    amount DECIMAL(12,2),
    transaction_type VARCHAR(10),
    merchant VARCHAR(100),
    status VARCHAR(20),
    device_type VARCHAR(20),
    location VARCHAR(100)
);

--3.IMPORT CSV FILE--

select * 
from transactions;

--4.FIND DAILY SPENDS--

select transaction_date, sum(amount) as daily_spend
from transactions
where status = 'success'
group by transaction_date
order by transaction_date;

--5.FIND MONTHLY SPENDS--

select TO_CHAR(transaction_date, 'YYYY-MM') as month,
	sum(amount) as total_spent
from transactions
group by month
order by month;

--6. COUNT STATUS--

select status, count(*)
from transactions
group by status;

--7. MERCHANT ANALYSIS--

select merchant, count(*) as txn_count, sum(amount) as revenue
from transactions
where status = 'success'
group by merchant
order by revenue desc;

--8. HIGH-VALUE CUSTOMERS--

select customer_id, sum(amount) as total_spend, count(*) as txn_count
from transactions
where status = 'success'
group by customer_id
order by total_spend desc
limit 10;

--9. FRAUD DETECTION RULES--

--A. HIGH AMOUNT(>50000)--

select * 
from transactions
where amount > 50000 
order by amount desc;

--B. MULTIPLE TRANSACTIONS IN SAME MINUTE--

select customer_id,transaction_date,transaction_time,count(*) as cnt
from transactions
group by customer_id, transaction_date, transaction_time
having count(*) > 1;

--10. FAILED STATUS--

select status, count(*) as total
from transactions
group by status;

--11. DEVICE TYPE PERFORMANCE--

select device_type, count(*) as total_txn, sum(case when status = 'success' then 1 else 0 end) as success_txn
from transactions
group by device_type;

--12. CUSTOMER MONTHLY SPEND & TREND--

select customer_id,
       to_char(transaction_date, 'YYYY-mm') AS month,
       sum(amount) as monthly_spend,
       sum(sum(amount)) over(
            partition by customer_id
            order by to_char(transaction_date, 'YYYY-mm')
       ) as cumulative_spend
from transactions
group by customer_id, month;
