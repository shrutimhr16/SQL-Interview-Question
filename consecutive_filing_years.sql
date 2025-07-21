CREATE TABLE tax_filings (
    user_id INT NOT NULL,
    filing_date DATE NOT NULL,
    product_used VARCHAR(100) NOT NULL
);

use shruti
-- Sample Data for tax_filings table

INSERT INTO tax_filings (user_id, filing_date, product_used) VALUES
-- User 101: 3 consecutive TurboTax years (2018, 2019, 2020), then a gap, then 2 more (2022, 2023)
(101, '2018-03-15', 'TurboTax Deluxe'),
(101, '2019-03-20', 'TurboTax Premier'),
(101, '2020-04-01', 'TurboTax Basic'),
(101, '2022-03-10', 'TurboTax Deluxe'),
(101, '2023-03-18', 'TurboTax Premier'),

-- User 202: 2 consecutive TurboTax years (2015, 2016)
(202, '2015-02-28', 'TurboTax Self-Employed'),
(202, '2016-03-05', 'TurboTax Deluxe'),

-- User 303: Only 1 TurboTax filing (2021)
(303, '2021-04-10', 'TurboTax Premier'),

-- User 404: 2 consecutive TurboTax years (2010, 2011), then a gap, then 3 more (2013, 2014, 2015)
(404, '2010-03-01', 'TurboTax Basic'),
(404, '2011-03-07', 'TurboTax Deluxe'),
(404, '2013-03-15', 'TurboTax Premier'),
(404, '2014-03-22', 'TurboTax Self-Employed'),
(404, '2015-04-01', 'TurboTax Deluxe'),

-- User 505: 4 consecutive TurboTax years (2017, 2018, 2019, 2020)
(505, '2017-02-14', 'TurboTax Premier'),
(505, '2018-03-01', 'TurboTax Deluxe'),
(505, '2019-03-08', 'TurboTax Basic'),
(505, '2020-03-16', 'TurboTax Premier'),

-- User 606: Mix of products, only 2 consecutive TurboTax years
(606, '2019-01-20', 'QuickBooks Self-Employed'), -- Not TurboTax
(606, '2020-03-01', 'TurboTax Deluxe'),
(606, '2021-03-05', 'TurboTax Premier'),
(606, '2023-02-10', 'QuickBooks Online'), -- Not TurboTax

-- User 707: Exactly 3 consecutive TurboTax years (2021, 2022, 2023)
(707, '2021-04-05', 'TurboTax Basic'),
(707, '2022-03-20', 'TurboTax Deluxe'),
(707, '2023-03-25', 'TurboTax Premier'),

-- User 808: Filing with non-TurboTax product
(808, '2020-03-01', 'H&R Block Online'), -- Not TurboTax
(808, '2021-03-05', 'TaxAct'), -- Not TurboTax

-- User 909: 2020-2021-2022 Turbotax then 2023 Quickbooks
(909, '2020-03-01', 'TurboTax Deluxe'),
(909, '2021-03-05', 'TurboTax Premier'),
(909, '2022-03-10', 'TurboTax Basic'),
(909, '2023-03-15', 'QuickBooks Self-Employed');

#Write a SQL query to identify user_ids of individuals who
# have filed their taxes using any version of TurboTax for 
#three or more consecutive years. Display the output in 
#ascending order of user_id.
select * from tax_filings;

select distinct user_id from (
select user_id , year(filing_date)
from tax_filings
where (user_id , year(filing_date)+1) in
(select user_id , year(filing_date)
from tax_filings)
and (user_id , year(filing_date)+2) in
(select user_id , year(filing_date)
from tax_filings)
and product_used like 'TurboTax%' )t;

with tax as (
SELECT user_id,
lag(EXTRACT(year from filing_date)) over (PARTITION BY user_id ORDER BY filing_date) as prev_year,
EXTRACT(year from filing_date) as current_year,
lead(EXTRACT(year from filing_date)) over (PARTITION BY user_id ORDER BY filing_date) as next_year
FROM tax_filings
where lower(product_used) like 'turbotax%')
select distinct user_id
from tax
where next_year - prev_year = 2
;

select distinct t1.user_id 
from tax_filings t1 inner join tax_filings t2
on year(t2.filing_date) = year(t1.filing_date)+1
inner join tax_filings t3
on year(t3.filing_date) = year(t1.filing_date)+2
AND t1.user_id = t2.user_id AND t1.user_id = t3.user_id