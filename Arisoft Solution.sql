create database sample;

use sample;

show tables;

desc employees;

select * from employees;

desc customers;

select * from customers order by salesrepemployeenumber;

desc offices;

select * from offices;

desc products;

select * from products;

desc productlines;

select * from productlines;

desc orders;

select * from orders;

desc orderdetails;

select * from orderdetails;

desc payments;

select * from payments;

/*ARISOFT Corporation wants to implement a system where 
the credit limit of a customer is automatically updated 
based on the total amount of payments received for that 
customer. Design an SQL query or procedure to calculate 
the total payments received for each customer and update 
their credit limit accordingly.*/

-- total payment received by each customer

select customernumber, sum(amount)
from payments
group by customernumber;

select * from customers where customernumber = 112;

-- update, subquery, joins
update customers c
set creditlimit = 
	(select sum(amount)
    from payments p
    where c.customernumber = p.customernumber);
    
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

/*ARISOFT Corporation wants to identify employees who 
are eligible for promotion based on their job performance. 
Create an SQL query or procedure to check if an employee 
has achieved a specified sales target (consider the orders 
and orderdetails tables) and, if so, update their job title 
to indicate a promotion.*/

-- salesTarget that we will assume 600000

-- each customers has how much order amount

select employeenumber, 
sum(od.quantityordered * od.priceeach)
from employees e join customers c
on(e.employeenumber = c.salesrepemployeenumber)
join orders o
using(customernumber)
join orderdetails od
using(ordernumber)
group by employeenumber
having sum(od.quantityordered * od.priceeach) >= 600000;

use sample;

drop procedure CheckEmployeePromotion;

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

/*The territories assigned to each office need to be updated based 
on the country of the office location. Design an SQL query or procedure 
to automatically assign the correct territory code to each office based 
on its country. Use the offices table for this operation.*/

select * from offices;

/*case 
when condition1 then statement1
when condition2 then statement2
when condition3 then statement3
else statement4
end case*/

update offices
set territory = case
				when country = 'USA' then 'America'
                when country in ('france','uk') then 'Europe'
                else 'Others'
                end;

/*ARISOFT Corporation wants to monitor product stock levels and generate alerts 
when the quantity in stock falls below a specified threshold. Create an SQL query 
or trigger that automatically notifies the relevant stakeholders when a product's 
stock level becomes critical.*/

/*Trigger is a special stored procedure that is called automatically when a DML
operation is performed on the table. DML operations are insert, update and delete
In trigger creation we can specify whether the trigger should be called after or
before the DML operation. In all any table can have six triggers created as follow
1. before insert
2. after insert
3. before update
4. after update
5. before delete
5. after delete

for each row means trigger will be fired on each row that 
is undergoing DML operation.
if 5 rows are updated and we have create update trigger on 
this table then the trigger will executed 5 times
*/

/*Syntax:
create trigger triggername
after/before insert/update/delete on tablename
for each row
begin
statement;
end
*/

select * from products;

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

/*The marketing team at ARISOFT Corporation is interested in analyzing
 the effectiveness of product line descriptions. Develop an SQL query 
 to retrieve the average length of product line descriptions 
 (textDescription column in the productlines table) and identify which 
 product lines have descriptions above or below the average length.*/
 
 select * from productlines;
 
 -- average length ?
 
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
        
/*ARISOFT Corporation wants to provide customers with a summary 
of their order history, including the total amount spent and the 
number of orders placed. Design an SQL query or procedure to retrieve 
this information for a specific customer.*/

select * from customers;
select * from orders order by customernumber;
select * from orderdetails order by ordernumber;

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

/*The logistics department needs a way to identify orders with late 
shipments. Develop an SQL query or procedure to list orders that have 
a status of 'Shipped' but where the shipped date is later than the 
required date.*/

select * from orders;

select ordernumber, requireddate, shippeddate
from orders
where shippeddate > requireddate
and status = 'shipped';

/*The procurement team wants to analyze the distribution of products 
among different vendors. Create an SQL query to retrieve the count of 
products supplied by each vendor (productVendor column in the products 
table) and order the results by the count in descending order.*/

select * from products;

select productvendor, count(productcode) 'productssupplied'
from products
group by productvendor
order by 2 desc;

/*ARISOFT Corporation wants to ensure that the reporting hierarchy 
of employees is correctly represented. Design an SQL query or procedure 
to validate that the reportsTo field in the employees table accurately 
reflects the organizational reporting structure.*/

select * from employees;

-- self join - where the single joins itself

select emp.firstname 'employeename', mgr.firstname 'managername'
from employees emp join employees mgr
on(emp.reportsto = mgr.employeenumber);

/*The finance department needs a comprehensive report on customer payment 
history. Create an SQL query to retrieve the payment details for a specific 
customer, including check numbers, payment dates, and amounts.*/

select * from payments;

-- natural join can be used to join two tables with common column

select c.customernumber, customername, checknumber, paymentdate, amount
from customers c natural join payments p
where c.customernumber = 124;








