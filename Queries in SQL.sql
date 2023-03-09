use MASAI_Project_1

---1. Make a dataset (Using SQL) named “daily_logins” which contains the number of logins on a daily basis

select * from daily_logins
order by year, month, Day


---2.-Daily trend of logins and trend of conversion rate (Number of orders placed per login)

---A-Daily Trend of logins:-

Select * from daily_logins

---B-Daily Trend of Conversion rate 

select * from [No. of Orders per day]

---	select * into Conversion_Rate_from_Login_to_Orders_Per_Day from
---	(select *, ([No. of Visit per_day] / Total_Orders_Each_day) as Conversion_rate from
---	(select a.YEar, a.Month, a.Day, Total_Orders_Each_day,[No_of_Visit_per_day] from
---	(select DateName(Month,Creation_Time) as Month, YEar(creation_Time) as YEar, Day(Creation_Time) as Day, count(*) as Total_Orders_Each_day
---, ROW_NUMBER() over (Order By Day(Creation_Time)) as Sr_No 
---	from sales_orders
---	group by DateName(Month,Creation_Time) , YEar(creation_Time) , Day(Creation_Time) ) as a join [No. of Orders Per Day] as b on 
---	a.sr_No = b.Sr_No 
---	) as n) as j 

---Final Table in which we store the conversion rate is here :-

select * from Conversion_Rate_from_Login_to_Orders_Per_Day


---3. Which KPIs (Key Performance Indicators) would you use to measure the performance of our app?

---Answer- A- How Much Avg_time user repeated login on our website every Year.  
---		   B- How much growth happened in terms of order per year. 
---		   C- How Much Growth Happened in terms of user_login per Year

---A
select YEar, Avg(Total_Login_User_wise) as AVG_Time_User_Repeated_login from 
(select year(login_time) year, USER_ID, count(*)  as Total_Login_User_wise from login_logs2
group by USER_ID,year(login_time))as a 
group by year

---B

select year, sum(Total_Orders_Each_day) as Total_Orders_Each_year from Conversion_Rate_from_Login_to_Orders_Per_Day
group by YEar

---C

select year, sum([No. of Visit per_day]) as [No. of Visit per_year]  from daily_logins
group by Year



--- 3.Prepare a report regarding our growth between the 2 years.
---a. Did our business grow?

---in terms of count of orders placed in each year (rejected and shipped)
select a.week_num,
count_of_orders_2021,
count_of_orders_2022
from
(
select DATEPART(week,creation_time) as week_num, COUNT(order_id) as count_of_orders_2021
from login_logs2 l
join sales_orders so
on l.user_id=so.fk_buyer_id
where year(creation_time)=2021
group by DATEPART(week,creation_time)) a
full outer join
(select DATEPART(week,creation_time) as week_num, COUNT(order_id) as count_of_orders_2022
from login_logs2 l
join sales_orders so
on l.user_id=so.fk_buyer_id
where year(creation_time)=2022
group by DATEPART(week,creation_time)) b
on a.week_num=b.week_num
order by a.week_num;

--- in terms of total_revenue_generated
select a.week_num, total_revenue_2021, total_revenue_2022 from
(select DATEPART(week,creation_time) as week_num, sum(order_quantity_accepted*rate) as total_revenue_2021
from login_logs2 l
join 
sales_orders so
on l.user_id=so.fk_buyer_id
join sales_orders_items soi
on so.order_id=soi.fk_order_id
where YEAR(creation_time)=2021
group by DATEPART(week,creation_time) )a
full outer join
(select DATEPART(week,creation_time) as week_num, sum(order_quantity_accepted*rate) as total_revenue_2022
from login_logs2 l
join 
sales_orders so
on l.user_id=so.fk_buyer_id
join sales_orders_items soi
on so.order_id=soi.fk_order_id
where YEAR(creation_time)=2022
group by DATEPART(week,creation_time))b
on a.week_num=b.week_num
order by a.week_num;

---b.Does our app perform better now?

select * from login_logs2 l
join 
sales_orders so
on l.user_id=so.fk_buyer_id
order by user_id,fk_buyer_id

---c



---4. What are our top-selling products in each of the two years? Can you draw some insight from this?
select top 10 *,
DENSE_RANK() over(partition by year order by total_orders_per_product desc) as ranking
from
(select YEAR(creation_time) as year,MONTH(creation_time) as month,
fk_product_id, COUNT(order_id) as total_orders_per_product
from login_logs2 l
join sales_orders so
on l.user_id=so.fk_buyer_id
join sales_orders_items soi
on soi.fk_order_id=so.order_id
group by YEAR(creation_time),MONTH(creation_time),fk_product_id) x
where year=2021;



select *
from login_logs2;

---3 c

with cte as 
(
select year(login_time) as year,DATEPART(week,login_time) as week_num,
DATEPART(WEEKDAY,login_time) as weekday_num,
DATENAME(weekday,login_time) as day_name,
COUNT(login_log_id) as total_traffic
from login_logs2
group by year(login_time),DATEPART(week,login_time),
DATEPART(WEEKDAY,login_time),
DATENAME(weekday,login_time)
)

select * from cte
order by year,week_num,weekday_num,day_name

---4
select *
from sales_orders so
join sales_orders_items soi
on so.order_id=soi.fk_order_id

---in terms of average rate and quantity
select fk_product_id,COUNT(order_id) as total_orders,
AVG(rate) as avg_rate,avg(ordered_quantity) as avg_quantity
from sales_orders so
join sales_orders_items soi
on so.order_id=soi.fk_order_id
group by fk_product_id
order by total_orders desc;

---week wise 

select week, fk_product_id,
total_orders_2021,total_orders_2022
from
(select a.week, a.fk_product_id,
total_orders_2021,total_orders_2022,
DENSE_RANK() over(partition by a.week order by total_orders_2021 desc,total_orders_2022 desc) as ranking
from
(select year(creation_time) as year,
DATEPART(week,creation_time) as week,
fk_product_id, count(order_id) as total_orders_2021
from sales_orders so
join sales_orders_items soi
on so.order_id=soi.fk_order_id
where YEAR(creation_time)=2021 and sales_order_status='shipped'
group by year(creation_time),
DATEPART(week,creation_time),
fk_product_id ) a
join
(select year(creation_time) as year,
DATEPART(week,creation_time) as week,
fk_product_id, count(order_id) as total_orders_2022
from sales_orders so
join sales_orders_items soi
on so.order_id=soi.fk_order_id
where YEAR(creation_time)=2022 and sales_order_status='shipped'
group by year(creation_time),
DATEPART(week,creation_time),
fk_product_id ) b
on a.fk_product_id=b.fk_product_id) x
where ranking<=10;

--- best selling products overall (best selling accepted)
select top 5 YEAR(creation_time) as year,
fk_product_id,
COUNT(order_id) as total_orders
from sales_orders so
join sales_orders_items soi
on so.order_id=soi.fk_order_id
where so.sales_order_status='shipped'
group by YEAR(creation_time),fk_product_id 
order by total_orders desc;

---5. Looking at July 2021 data, what do you think is our biggest problem and how would you recommend fixing it ?

---How much order rejected 

select year(creation_time) as Year, Count(*) as Total_Rejected_Orders from sales_orders
where sales_order_status = 'Rejected'
group by year(creation_time)



---So Our biggest problem in 2021 was our app proformance because less customers login on app and conversion of orders are also less in 2021.


---6. Does the login frequency affect the number of orders made?

select year, sum(Total_Orders_Each_day) as Total_Orders_Each_year from Conversion_Rate_from_Login_to_Orders_Per_Day
group by YEar

---D

select year, sum([No. of Visit per_day]) as [No. of Visit per_year]  from daily_logins
group by Year

---Answer = So after analysing both year's Total Login count and total Orders Count, it is clearly visible that 
---			login frequency affect our no. of orders made.


---7. Give at least 2 insights that are not mentioned above and are not clearly visible from the data.

--- Answer 

---A. The depot id 1,8,9 are rejected most no. of orders. 

select fk_depot_id , Count(*) as Total_Rejected_in_each_depot from
(select fk_depot_id, sales_Order_status from sales_orders
where sales_order_status = 'Rejected') as a 
group by fk_depot_id
order by Total_Rejected_in_each_depot desc

---B.So out of Total_order_quantity of 66638 only 29786 Total_order_quantity were accpted. 

select Sum(ordered_quantity) as Total_Order_Placed, Sum(Order_Quantity_Accepted) as Total_Order_Accepted from sales_orders_items

---C-Around 7,09,10,364 Rs loss faced by company due to rejected orders. 

select sum(rate) as Total_loss from sales_orders_items
where order_quantity_accepted = 0

select  datepart(DAY, creation_time) as Time , count(*) as Orders from sales_orders
group by datepart(DAY, creation_time)
order by Time

---D-On which day orders gets less orders 


select DateName(Weekday,creation_time) as Day, Count(*) as Rejected_Each_Day from sales_orders
group by DateName(Weekday,creation_time)
order by Rejected_Each_Day desc
