--1. Total sales per customer (with customer name).

select 
c.Customer,
sum(s.profit) as [Total Sales]
from Dimension.Customer as c 
inner join Fact.Sale as s on c.[Customer Key] = s.[Customer Key]
group by c.Customer

------------------------------------------------------------
--2. Number of sales transactions per city.

select
c.City as City ,
count(s.[sale Key]) as 'Number of sales transactions'
from Dimension.City as c 
inner join Fact.sale s on c.[City Key] = s.[City Key]
group by c.City

------------------------------------------------------------
--3. Maximum sale value per employee.

select 
E.Employee,
Max(s.profit) as [ Maximum Value]
from Dimension.Employee as E 
inner join Fact.Sale as s on E.[Employee Key]= s.[Salesperson Key]  and E.[Is Salesperson] = 1
group by  E.Employee

------------------------------------------------------------
--4. Average quantity sold per product.

select 
t.[Stock Item],
Avg(s.Quantity) as [Average quantity sold]
from Dimension.[Stock Item] as t 
inner join Fact.Sale as s on t.[Stock Item Key] = s.[Stock Item Key]
group by  t.[Stock Item]

------------------------------------------------------------
--5. Total sales per year.
select
D.[Calendar Year] ,
sum( O.[Total Including Tax]) as [Total Sales]
from Fact.[Order] as O 
inner join  Dimension.Date D on O.[Order Date Key] = D.Date
group by D.[Calendar Year]

------------------------------------------------------------
--6. Number of orders per product type.

select 
S.[Stock Item],
count(O.[Order Key]) as [Number of orders]
from Fact.[Order] as O 
inner join Dimension.[Stock Item] as S on O.[Stock Item Key] = S.[Stock Item Key]
group by S.[Stock Item]

------------------------------------------------------------
--7. Total sales by city and year.

select 
C.City , 
D.[Calendar Year],
sum( O.[Total Including Tax]) as [Total Sales]
from Fact.[Order] as O
inner join  Dimension.Date D on O.[Order Date Key] = D.Date
inner join Dimension.City as C on O.[City Key] = C.[City Key]
group by C.City,D.[Calendar Year]
order by D.[Calendar Year]

------------------------------------------------------------
--8. Number of customers per country.

select 
T.Country,
count(C.Customer) as [ Number of customers]
from Dimension.Customer as C 
inner join Fact.[Order] as O on C.[Customer Key] = O.[Customer Key]
inner join Dimension.City as T on O.[City Key] = T.[City Key]
group by T.Country

------------------------------------------------------------
--9. Total sales per customer and their assigned salesperson.

select 
E.Employee,
c.Customer,
sum(s.profit) as [Total Sales]
from Dimension.Customer as c 
inner join Fact.Sale as s on c.[Customer Key] = s.[Customer Key] 
inner join Dimension.Employee as E
on E.[Employee Key] = s.[Salesperson Key] and E.[Is Salesperson] = 1
group by c.Customer , E.Employee

------------------------------------------------------------
--10. The top-selling product by total quantity.

select 
t.[Stock Item],
SUM(s.Quantity) as [Total quantity]
from Dimension.[Stock Item] as t 
inner join Fact.Sale as s on t.[Stock Item Key] = s.[Stock Item Key]
group by  t.[Stock Item]
order by [Total quantity] desc

------------------------------------------------------------
-- Total Tax amount by person

select 
SUM(Fact.[Order].[Tax Amount]) as Tax ,
Fact.[Order].[Salesperson Key]
from Fact.[Order]
GROUP BY Fact.[Order].[Salesperson Key]
ORDER BY Tax desc

------------------------------------------------------------
-- Product sales by supplier and year

select
SUM(S.Quantity) as Totalsold,
sup.Supplier,
d.[Calendar Year]
from Fact.Sale as S 
inner join Dimension.[Stock Item] as St on S.[Stock Item Key] = St.[Stock Item Key]
inner join Dimension.Supplier as sup on sup.[Supplier Key] = st.[Stock Item Key]
inner join Dimension.[Date] as d on s.[Invoice Date Key] = d.[Date]
group by sup.Supplier,d.[Calendar Year]
order by d.[Calendar Year] desc

------------------------------------------------------------
-- Top 10 monthly sales per product

select Top(10)
Sum(S.Quantity) as Totalsold,
st.[Stock Item] as Stock_Item,
D.[Calendar Month Label] as Month
from Fact.Sale S
inner join Dimension.[Stock Item] st on S.[Stock Item Key] = st.[Stock Item Key]
inner join Dimension.Date D on D.Date = S.[Invoice Date Key]
group by st.[Stock Item],D.[Calendar Month Label]
order by D.[Calendar Month Label] desc

------------------------------------------------------------
-- Product sales by season

select 
Sum(S.Quantity) as Totalsold,
st.[Stock Item] as Stock_Item,
D.[Calendar Month Label] as Month
from Fact.Sale S
inner join Dimension.[Stock Item] st on S.[Stock Item Key] = st.[Stock Item Key]
inner join Dimension.Date D on D.Date = S.[Invoice Date Key]
group by st.[Stock Item],D.[Calendar Month Label]
order by Totalsold desc

------------------------------------------------------------
-- High-performing products (above average sales)

select
St.[Stock Item] as Item,
SUM(S.Quantity) as Totalsold
from Fact.Sale as S 
inner join Dimension.[Stock Item] as St on S.[Stock Item Key] = St.[Stock Item Key]
Group by St.[Stock Item]
having SUM(S.Quantity) > AVG(S.Quantity)
order by Totalsold desc

------------------------------------------------------------
 -- Slow-moving products (less than 5 sales in 6 months)

 select 
 COUNT(*) as countsale,
 st.[Stock Item] as Stock_Item
 from Fact.Sale S
 inner join Dimension.[Stock Item] st on S.[Stock Item Key] = st.[Stock Item Key]
 inner join Dimension.Date D on D.Date = S.[Invoice Date Key]
 where D.Date >= S.[Invoice Date Key]
 group by st.[Stock Item]
 having count(*) < 500

------------------------------------------------------------
-- Products with sales but no current stock

select 
Si.[Stock Item]
from Dimension.[Stock Item] Si 
inner join Fact.[Stock Holding] sh on sh.[Stock Item Key] = si.[Stock Item Key]
inner join Fact.Sale as S on S.[Stock Item Key] = si.[Stock Item Key]
where sh.[Quantity On Hand] = 0 OR sh.[Quantity On Hand] is NULL

------------------------------------------------------------
-- Yearly sales analysis per product

select 
Sum(S.Quantity) as Totalsold,
st.[Stock Item] as Stock_Item,
D.[Calendar Year] as  Year
from Fact.Sale S
inner join Dimension.[Stock Item] st on S.[Stock Item Key] = st.[Stock Item Key]
inner join Dimension.Date D on D.Date = S.[Invoice Date Key]
group by st.[Stock Item],D.[Calendar Year]
order by D.[Calendar Year] desc

------------------------------------------------------------
--View
CREATE VIEW stocksales 
as
	select S.[Sale Key],
	S.[Stock Item Key],
	S.[Customer Key],
	S.[Invoice Date Key],
	S.[Total Excluding Tax],
	S.[Total Including Tax],
	S.[Unit Price],
	S.Quantity,
	D.Date,
	Si.[Stock Item],
	C.Customer,
	C.Category
	from Fact.Sale as S
	inner join Dimension.[Stock Item] Si on Si.[Stock Item Key] = S.[Stock Item Key]
	inner join Dimension.Customer C on C.[Customer Key] = S.[Customer Key]
	inner join Dimension.Date D on D.Date = S.[Invoice Date Key]

select * from stocksales
------------------------------------------------------------
--What are the top 5 stock items by total including tax?

select Top 5
st.[Stock Item],
SUM(st.[Total Including Tax]) as 'total including tax'
from stocksales as st
Group by st.[Stock Item]
order by 'total including tax' desc

------------------------------------------------------------
--Which customers bought the highest total quantity of products?

select
st.Customer,
Sum(st.Quantity) AS total_quantity
from stocksales st
Group by st.Customer
order by total_quantity desc

------------------------------------------------------------
--What is the average unit price for each stock item?

select
st.[Stock Item],
AVG(st.[Unit Price]) AS Avg_Price
from stocksales st
Group by st.[Stock Item]
order by Avg_Price desc

------------------------------------------------------------
--How many invoices were made per day?

select 
Day(st.Date) as [Day],
COUNT(st.[Invoice Date Key]) as invoices
from stocksales st
Group by Day(st.Date)
order by invoices



------------------------------------------------------------
--What is the total excluding tax per customer?

select
st.Customer,
Sum(st.[Total Excluding Tax]) AS  'Total Excluding Tax'
from stocksales st
Group by st.Customer
order by 'Total Excluding Tax' desc

------------------------------------------------------------
Select * from Fact.Purchase

CREATE VIEW Purchases
as
	select 
	Pu.[Purchase Key],
	Pu.[Supplier Key],
	Su.Supplier,
	Pu.[Stock Item Key],
	Si.[Stock Item],
	Pu.[Ordered Quantity],
	Pu.[Date Key],
	Si.[Unit Price],
	Si.[Tax Rate],
	Su.Category,
	D.[Short Month],
	D.[Calendar Year]
	from Fact.Purchase Pu
	join Dimension.Supplier Su on Su.[Supplier Key] = Pu.[Supplier Key]
	join Dimension.[Stock Item] Si on Si.[Stock Item Key] = Pu.[Stock Item Key]
	join Dimension.Date D on D.Date = Pu.[Date Key]

Select * from Purchases
------------------------------------------------------------
--Total Ordered Quantity by products 

select
p.[Stock Item],
Sum(p.[Ordered Quantity]) as 'Total Ordered Quantity'
from Purchases P
Group by p.[Stock Item]
order by 'Total Ordered Quantity' desc

------------------------------------------------------------
--Total Ordered Quantity by Categories

select
p.Category,
Sum(p.[Ordered Quantity]) as 'Total Ordered Quantity'
from Purchases P
Group by p.Category
order by 'Total Ordered Quantity' desc

------------------------------------------------------------
--Average Tax rate by Categories

select
p.Category,
AVG(p.[Tax Rate]) as 'Avg_Tax_rate'
from Purchases P
Group by p.Category
order by  'Avg_Tax_rate' desc

------------------------------------------------------------
--Count Products in each Category

Select 
p.Category,
COUNT(p.[Stock Item]) as 'Number of Product'
from Purchases p
Group by p.Category

------------------------------------------------------------
--Total Profit Excluding Tax from Products

select 
p.[Stock Item],
SUM(p.[Unit Price]) as 'Total Profits'
from Purchases p
Group by p.[Stock Item]
Order  by 'Total Profits' desc

------------------------------------------------------------
--total Sales by Months and Years

select 
p.[Calendar Year],
P.[Short Month],
SUM(P.[Ordered Quantity]) as TotalSold
from Purchases p
Group by [Calendar Year],P.[Short Month]
Order  by TotalSold desc

------------------------------------------------------------
--Who are the top suppliers by number of purchases?

Select 
P.Supplier,
COUNT(*) as 'number of purchases'
from Purchases P
Group by P.Supplier
Order by 'number of purchases' desc

------------------------------------------------------------
--What is the total ordered quantity per supplier?

Select 
P.Supplier,
SUM(p.[Ordered Quantity]) as 'total ordered quantity'
from Purchases P
Group by P.Supplier
Order by 'total ordered quantity' desc

------------------------------------------------------------
--Which category has the highest purchase value?

select
p.Category,
SUM(p.[Ordered Quantity]*p.[Unit Price]) as[highest purchase value]
from Purchases P
Group by p.Category
order by [highest purchase value] desc

------------------------------------------------------------
--How much tax is collected per supplier ?

select
p.Supplier ,
SUM(P.[Tax Rate]) as 'Total_TAX'
from Purchases P
Group by p.Supplier
order by  'Total_TAX' desc


