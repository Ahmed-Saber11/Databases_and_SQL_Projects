 --1. Retrieve all customers from Sales.Customer who placed an order after January 1, 2019
select CustomerID
from Sales.Customer
where ModifiedDate > '2019-1-1'
--Note only 2014 in table

-----------------------------------------------------------------
--2. List all products with their category and subcategory names.
select p.Name as productName,s.Name as Subcategory,c.Name as Category
from Production.Product P,Production.ProductCategory c,
Production.ProductSubcategory s
where  s.ProductSubcategoryID = p.ProductSubcategoryID
and  c.ProductCategoryID = s.ProductCategoryID

---------------------------------------------------------
--3.Update the phone number of a specific employee in HumanResources.Employee.
select *
from HumanResources.Employee c
where BusinessEntityID = 196
--Not Found Phone Number Column in this table

----------------------------------------------------------
--4.Delete records of vendors in Purchasing.Vendor who haven’t supplied anything in the last 5 years.
delete from Purchasing.Vendor 
where  ActiveFlag = 'false'
-------------------
update Purchasing.Vendor 
set ActiveFlag = 'false'
where  BusinessEntityID	in (
select BusinessEntityID 
from Purchasing.Vendor v left join Purchasing.PurchaseOrderHeader P
on v.BusinessEntityID = p.vendorID 
group by BusinessEntityID
having MAX(p.OrderDate) < DATEADD(YEAR, -5, GETDATE()) 
OR MAX(p.OrderDate) IS NULL )
--------------------------------------------------
--5. Count the total number of orders in Sales.SalesOrderHeader
select count(SalesOrderID)
from Sales.SalesOrderHeader

------------------------------------------------------------
--6.Find all employees working the second shift from HumanResources.Shift
select E.BusinessEntityID
from HumanResources.Shift S,HumanResources.Employee E,HumanResources.EmployeeDepartmentHistory DE
where s.ShiftID = De.ShiftID and DE.BusinessEntityID = E.BusinessEntityID and s.ShiftID = 2

------------------------------------------------------------------
--7.Display products that start with the letter “B” using the LIKE operator.
select p.ProductID,p.Name
from Production.Product  p
where p.Name like 'B%'

------------------------------------------------------------------------
--8.Retrieve orders where the total due is greater than $10,000.
select s.SalesOrderID
from Sales.SalesOrderHeader s
where TotalDue > 10000

--------------------------------------------------------------------------
--9.List all unique product categories available in Production.ProductCategory
select distinct p.Name
from Production.ProductCategory p

-------------------------------------------------------------------
--10.Create a new view that lists customers and their total purchase amounts.
create view v1 as
	select c.CustomerID,sum(s.TotalDue) as total
	from sales.Customer c,Sales.SalesOrderHeader s
	where c.CustomerID = s.CustomerID
	group by c.CustomerID

---------------------------------------------------------------------------
--11. Calculate the average unit price of all products
select Avg(listPrice)
from Production.Product 

-----------------------------------------------
--12.Use a CASE statement to categorize orders into "High Value" and "Low Value" based on a threshold of $5,000.

select SalesOrderID,case
		when  TotalDue >= 5000 then 'High Value'
		else 'Low Value'
		end
from Sales.SalesOrderHeader

------------------------------------------------
--13.Find the top 5 customers with the highest total order amounts.

select top(5) CustomerID
from Sales.SalesOrderHeader
order by TotalDue desc
---------------------------------------------------
--14. Join Sales.SalesOrderDetail and Production.Product to display product names for each order.
select D.SalesOrderID,p.Name
from Sales.SalesOrderDetail D,Production.Product p
where p.ProductID = D.ProductID

-----------------------------------------------------
--15.Use GROUP BY to calculate total sales per sales territory.
select TerritoryID,sum(TotalDue) as total
from  Sales.SalesOrderHeader D
group by TerritoryID

-----------------------------------------------------
--16.Find orders where the shipping address is the same as the billing address.
select SalesOrderID,CustomerID,ShipToAddressID,BillToAddressID
from  Sales.SalesOrderHeader
where ShipToAddressID = BillToAddressID

-------------------------------------------------------
--17. Create a stored procedure to retrieve orders for a specific customer ID.
create proc sp @ID int
as
	select SalesOrderID
	from Sales.SalesOrderHeader
	where CustomerID = @ID

exec sp 29825
--------------------------------------------------------
--*18. Retrieve all vendors located in a specific state.
select v.BusinessEntityID ,v.Name,a.City,sp.Name  
from Purchasing.Vendor v ,Person.BusinessEntityAddress bea ,
Person.[Address De] a,Person.StateProvince sp
where v.BusinessEntityID = bea.BusinessEntityID and bea.AddressID = a.AddressID
and  a.StateProvinceID = sp.StateProvinceID and sp.Name = 'California'  

------------------------------------------------------------------------
--19. Use the IN operator to find employees belonging to specific departments.
select E.*
from  HumanResources.Employee E,HumanResources.EmployeeDepartmentHistory  ED
where E.BusinessEntityID = ED.BusinessEntityID and ED.DepartmentID in (1,2,16)

---------------------------------------------------------------------------
--20.List all products that are part of a special offer.
select  p.ProductID,p.Name
from  Sales.SpecialOfferProduct sop ,Production.Product p ,  Sales.SpecialOffer so
where  sop.ProductID = p.ProductID and sop.SpecialOfferID = so.SpecialOfferID

----------------------------------------------------------------------------
--21. Create a UNION query to combine data from Purchasing.Vendor and Sales.Customer.
select V.BusinessEntityID
from Purchasing.Vendor V
union 
select C.CustomerID
from Sales.Customer C

------------------------------------------------------------------------------
--22. Retrieve all orders placed in the last 30 days.
select *
from Sales.SalesOrderHeader
where day(GETDATE() - OrderDate) = 30

-----------------------------------------------------------------
--23. Display the most expensive product in each category.
select pc.Name,p.Name
from Production.ProductSubcategory PS,Production.Productcategory PC,Production.Product p
where  ps.ProductSubcategoryID = p.ProductSubcategoryID 
and PC.ProductCategoryID = Ps.ProductCategoryID 
and p.ListPrice = (select max(p.ListPrice) 
from Production.ProductSubcategory PS,Production.Productcategory PC,Production.Product p
where  ps.ProductSubcategoryID = p.ProductSubcategoryID  )

---------------------------------------------------------
--24.Write a subquery to find customers who have placed more than 5 orders.

select c.CustomerID,count(h.SalesOrderID) as  count_Orders
from sales.SalesOrderHeader h,Sales.Customer c
where c.CustomerID = h.CustomerID
group by c.CustomerID
having count(h.SalesOrderID) > 5

---------------------------------------------------------------------
--25. List all employees who work in the same department as a specific employee

create proc EmplDepar @ID int
as
	select E.NationalIDNumber,ED.DepartmentID
	from HumanResources.Employee E,HumanResources.EmployeeDepartmentHistory ED
	where E.BusinessEntityID = E.BusinessEntityID and ED.DepartmentID = @ID
 
exec EmplDepar 16
---------------------------------------------------------------------------
--26. Create a new index on Sales.SalesOrderDetail for the ProductID column.
create nonclustered index VSales
on Sales.SalesOrderDetail(ProductID)

----------------------------------------------------------------------------
--27. Write a query to calculate the total discount offered on all orders.
select SalesOrderDetailID,sum(unitPriceDiscount) as total_discount 
from Sales.SalesOrderDetail
group by SalesOrderDetailID

-----------------------------------------------------------------------------
--28. Retrieve employees with salaries greater than the department average.

select E.NationalIDNumber
from HumanResources.Employee E,HumanResources.Department D,
HumanResources.EmployeePayHistory EPH,HumanResources.EmployeeDepartmentHistory EDH
where E.BusinessEntityID = EPH.BusinessEntityID and EDH.BusinessEntityID = E.BusinessEntityID
and EDH.DepartmentID= D.DepartmentID and 
EPH.Rate > ( select avg(EPH2.Rate)
from HumanResources.EmployeePayHistory EPH2,HumanResources.EmployeeDepartmentHistory EDH2
where EPH2.BusinessEntityID = EDH2.BusinessEntityID 
and EDH2.DepartmentID = EDH.DepartmentID )

------------------------------------------
--29.Find customers who haven’t placed any orders in the past year.

select C.CustomerID
from sales.SalesOrderHeader h right join Sales.Customer C
on C.CustomerID =h.CustomerID and h.OrderDate >= DATEADD(YEAR, -1, GETDATE())
WHERE C.CustomerID IS NULL;


-------------------------------------------------------------------
--30.Create a view to list sales data aggregated by year.
create view VS2
as
	select YEAR(OrderDate) AS SalesYear,COUNT(SalesOrderID) AS TotalOrders,
    SUM(TotalDue) AS TotalSales
	from Sales.SalesOrderHeader
	group by YEAR(OrderDate);

select * from VS2


-------------------------DONE-----------------------------------------
