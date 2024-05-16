# Arisoft Case Study 
## Problem Statement
ARISOFT Corporation is a global company specializing in the distribution of various products. The company maintains a relational database to manage information about its customers, employees, offices, orders, payments, product lines, and products. As a database administrator at ARISOFT Corporation, you are tasked with designing and implementing several SQL queries and operations to address specific business requirements. Your goal is to ensure the integrity of the data and provide valuable insights for decision-making. Please consider the following scenarios:

### Customer Credit Limit Update:
ARISOFT Corporation wants to implement a system where the credit limit of a customer is automatically updated based on the total amount of payments received for that customer. Design an SQL query or procedure to calculate the total payments received for each customer and update their credit limit accordingly.

```sql
delimiter $
create procedure UpdateCustomerCreditLimit()
begin
update customers c
set creditlimit = 
	(select sum(amount)
    from payments p
    where c.customernumber = p.customernumber);
end$

call UpdateCustomerCreditLimit();
```

### Employee Promotion Check:
ARISOFT Corporation wants to identify employees who are eligible for promotion based on their job performance. Create an SQL query or procedure to check if an employee has achieved a specified sales target (consider the orders and orderdetails tables) and, if so, update their job title to indicate a promotion.

```sql
delimiter $
create procedure CheckEmployeePromotion(salesTarget int)
begin
create temporary table employeesTemp as
select employeenumber
	from employees e join customers c
	on(e.employeenumber = c.salesrepemployeenumber)
	join orders o
	using(customernumber)
	join orderdetails od
	using(ordernumber)
	group by employeenumber
	having sum(od.quantityordered * od.priceeach) >= salesTarget;
update employees e 
join employeesTemp et
using(employeeNumber)
set jobtitle = concat('Senior ', jobtitle);	    
drop temporary table employeesTemp;
end$
    
call CheckEmployeePromotion(600000);

select * from employees;
```

### Office Territory Update:
The territories assigned to each office need to be updated based on the country of the office location. Design an SQL query or procedure to automatically assign the correct territory code to each office based on its country. Use the offices table for this operation.

```sql
update offices
set territory = case
		when country = 'USA' then 'America'
                when country in ('france','uk') then 'Europe'
                else 'Others'
                end;
```

### Product Stock Monitoring:
ARISOFT Corporation wants to monitor product stock levels and generate alerts when the quantity in stock falls below a specified threshold. Create an SQL query or trigger that automatically notifies the relevant stakeholders when a product's stock level becomes critical.

```sql
create table alerts(
	id int auto_increment primary key,
	productCode varchar(25),
	message varchar(255),
	createdAt datetime default now());
    
delimiter $
create trigger after_update_products
after update on products
for each row
begin
	if new.quantityinstock < 1000 then
		insert into alerts(productcode,message)
        values(new.productcode, 'Stock level critical');
	end if;
end$

select * from alerts;

update products
set quantityinstock = 800
where productcode = 'S10_1949';
```

### Product Line Description Analysis:
The marketing team at ARISOFT Corporation is interested in analyzing the effectiveness of product line descriptions. Develop an SQL query to retrieve the average length of product line descriptions (textDescription column in the productlines table) and identify which product lines have descriptions above or below the average length.

```sql
-- above the avg length
select productline, textdescription
from productlines 
where length(textdescription) > 
		(select avg(length(textdescription))
		from productlines);

-- below the avg length
select productline, textdescription
from productlines 
where length(textdescription) < 
		(select avg(length(textdescription))
		from productlines);
```

### Customer Order History:
ARISOFT Corporation wants to provide customers with a summary of their order history, including the total amount spent and the number of orders placed. Design an SQL query or procedure to retrieve this information for a specific customer.

```sql
delimiter $
create procedure GetCustomerOrderHistory(customerNum int)
begin
	select c.customernumber, c.customername, 
    count(o.ordernumber) 'ordercount',
    sum(od.quantityordered * od.priceeach) 'totalamountspent'
    from customers c join orders o
    using (customernumber)
    join orderdetails od
    using (ordernumber)
    where c.customernumber = customerNum
    group by c.customernumber;
end$

call GetCustomerOrderHistory(103);
```

### Identify Late Shipments:
The logistics department needs a way to identify orders with late shipments. Develop an SQL query or procedure to list orders that have a status of 'Shipped' but where the shipped date is later than the required date.

```sql
select ordernumber, requireddate, shippeddate
from orders
where shippeddate > requireddate
and status = 'shipped';
```

### Product Vendor Analysis:
The procurement team wants to analyze the distribution of products among different vendors. Create an SQL query to retrieve the count of products supplied by each vendor (productVendor column in the products table) and order the results by the count in descending order.

```sql
select productvendor, count(productcode) 'productssupplied'
from products
group by productvendor
order by 2 desc;
```

### Employee Reporting Hierarchy:
ARISOFT Corporation wants to ensure that the reporting hierarchy of employees is correctly represented. Design an SQL query or procedure to validate that the reportsTo field in the employees table accurately reflects the organizational reporting structure.

```sql
select emp.firstname 'employeename', mgr.firstname 'managername'
from employees emp join employees mgr
on(emp.reportsto = mgr.employeenumber);
```

### Customer Payment History:
The finance department needs a comprehensive report on customer payment history. Create an SQL query to retrieve the payment details for a specific customer, including check numbers, payment dates, and amounts.

```sql
select c.customernumber, customername, checknumber, paymentdate, amount
from customers c natural join payments p
where c.customernumber = 124;
```
