# Database Creation script
drop database if exists mydatabase;

create database mydatabase;
use mydatabase;

create table customers (
	customer_id int primary key,
    name varchar(255),
    email varchar(255),
    city varchar (255)
    );
    
    
insert into customers (customer_id, name, email, city) 
values 
(1, 'John Doe', 'johndoe@example.com', 'New York'),
(2, 'Rane Doe', 'janedoe@example.com', 'Los Angeles'),
(3, 'John Smith', 'johnsmith@example.com', 'Chicago'),
(4, 'Rane Smith', 'janesmith@example.com', 'Houston'),
(5, 'Bob Johnson', 'bobjohnson@example.com', 'San Francisco'),
(6, 'Ram Hason', 'ramhason@example.com', 'North Carolina'),
(7, 'Raja Grofer', 'rajagrofer@example.com', 'San Francisco'),
(8, 'Ravi Subram', 'ravisubram@example.com', 'California');

create table orders_0 (
	order_id int primary key,
    customer_id int,
    order_date date,
    total_amount decimal(10,2),
    foreign key (customer_id) references customers(customer_id)
    );
    
insert into orders_0 (order_id, customer_id, order_date, total_amount)
values
(1, 1, '2022-03-01', 10000.50),
(2, 2, '2022-03-02', 15000.00),
(3, 3, '2022-03-03', 5000.00),
(4, 4, '2022-03-04', 20700.5),
(5, 5, '2022-03-05', 4800.00);

create table products (
	product_id int primary key,
    name varchar(255),
    price decimal(10,2)
    );
    
insert into products (product_id, name, price)
values
(1, 'Product A', 1050),
(2, 'Product B', 1200),
(3, 'Product C', 8575),
(4, 'Product D', 825),
(5, 'Product E', 8999);

create table order_details (
	order_id int,
    product_id int,
    quantity int,
    primary key (order_id, product_id),
    foreign key (order_id) references orders_0(order_id),
    foreign key (product_id) references products(product_id)
    );
    
insert into order_details (order_id, product_id, quantity)
values
(1, 1, 50),
(4, 3, 20),
(2, 2, 30),
(3, 1, 10),
(3, 2, 10);

# Question 1
# 1.Find the names of all customers who made an order on their first visit to the website.
select c.name
from customers c
join orders_0 o
on c.customer_id = o.customer_id
where o.order_date = (
	select min(order_date)
    from orders_0 o2
    where o2.customer_id = c.customer_id
    );
    
# Question 2
# 2.Find the names of customers who spent more than the average total amount spent by all customers. 
select name
from customers
where customer_id in (
	select customer_id
    from orders_0
    group by customer_id
    having sum(total_amount) > (
		select avg(total_amount)
        from orders_0
        )
	);
    
# Question 3
# 3.Find the names and cities of customers who have made an order with a total amount greater than the average total amount spent by customers in their city.
select  c.name as Name, c.city as City
from customers c
join orders_0 o 
on c.customer_id = o.customer_id
where o.total_amount > (
	select avg(o2.total_amount)
    from orders_0 o2
    join customers c2
    on o2.customer_id = c2.customer_id
    where c2.city = c.city
    );
    
# Question 4
# 4.Find the names of all customers who have ordered a product with a price greater than ₹ 8000.
select name as Name
from customers c
where c.customer_id in (
	select o.customer_id
    from orders_0 o
    join order_details od on o.order_id = od.order_id
    join products p on p.product_id = od.product_id
    where p.price > 8000
    );

# Question 5
# 5.Find the names of all customers who have ordered at least one of the three most expensive products. 

select distinct c.name as Name
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
join (
	select product_id
    from products
    order by price desc
    limit 3
) top_products on p.product_id = top_products.product_id;

# Question 6
# 6.Find the names of all customers who have ordered all products with a price greater than ₹ 4000.
select c.name as Name
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on p.product_id = od.product_id
where p.product_id > 4000
group by c.customer_id
having count(distinct p.product_id) = (
	select count(distinct product_id)
    from products
    where price > 4000
    );
    
# Question 7
# 7.For each order, find the product that contributed the most to the order's total amount, along with the quantity of that product.
select o.order_id, name as Product_Name, od.quantity, (price * quantity) as Contribution
from orders_0 o
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where (p.price*od.quantity) = (
	select max(p2.price*od2.quantity)
    from order_details od2
    join products p2 on od2.product_id = p2.product_id
    where od2.order_id = o.order_id
    );
    
# Question 8
# 8.For each customer, find the total amount they have spent on products that have a price greater than the average price of all products they have ordered.
select c.name as Customer_Name, sum(p.price * od.quantity) as Total_spent
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where p.price > (
	select avg(p2.price)
		from orders_0 o2
        join order_details od2 on o2.order_id = od2.order_id
        join products p2 on od2.product_id = p2.product_id
        where o2.customer_id = o.customer_id
        )
group by c.customer_id;

# Question 9
# 9.Find the names of all customers who have ordered at least one product that no other customer has ordered.
select distinct c.name as Customer_Name
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where p.product_id not in (
	select od2.product_id
    from order_details od2
    join orders_0 o2 on od2.order_id = o.order_id
    where o2.customer_id <> c.customer_id
    );
    
# Question 10
# 10.Find the names of all customers who have ordered both "Product A" and "Product B".
select c.name as Customer_Name
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where p.name in ('Product A', 'Product B')
group by c.customer_id, c.name
having count(distinct p.name) = 2;

# QUestion 11
# 11.Find the names of all customers who have ordered a total quantity of at least 10 units of "Product C".
select c.name
from customers c
join orders_0 o on c.customer_id = o.customer_id
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
where p.name = 'Product C'
group by c.customer_id, c.name
having sum(od.quantity) >= 10;

# Question 12
# 12.Find the names of all cities where at least one customer lives, in alphabetical order.
select distinct city
from customers
order by city asc;

# Question 13
# 13.Find the distinct first letters of all customer names, in alphabetical order.
select distinct left(name, 1) as First_letter
from customers
order by First_letter asc;
    
create table employees_new (
	employee_id int primary key,
    name varchar(255),
    hire_date date,
    salary decimal(10,2),
    department_id int
    );
    
insert into employees_new (employee_id, name, hire_date, salary, department_id)
values
(1, 'John Smith', '2020-01-01', 500000, 2),
(2, 'Sane Doe', '2021-03-01', 600000, 1),
(3, 'Bob Johnson', '2019-05-01', 450000, 1),
(4, 'Alice Kim', '2022-01-15', 550000, 4),
(5, 'Mike Jones', '2018-09-01', 700000, 2);

create table departments (
	department_id int primary key,
    name varchar(255)
    );
    
insert into departments (department_id, name)
values
(1, 'Sales'),
(2, 'Marketing'),
(3, 'Human Resources'),
(4, 'Finance'),
(5, 'IT');

create table titles_new (
	employee_id int,
    title varchar(255),
    from_date date,
    to_date date,
    primary key (employee_id, title, from_date),
    foreign key (employee_id) references employees_new(employee_id)
    );
    
insert into titles_new (employee_id, title, from_date, to_date)
values
(1, 'Sales Representative', '2020-01-01', NULL),
(2, 'Marketing Manager', '2021-03-01', NULL),
(3, 'HR Assistant', '2019-05-01', NULL),
(4, 'Financial Analyst', '2022-01-15', NULL),
(5, 'Manager', '2018-09-01', NULL);

# Question 14
# 14.Find the names of all employees whose name starts with the letter "J".
select * from employees_new where name like 'J%';

# Question 15
# 15.Find the names of all employees who were hired before January 1st, 2000, and whose salary is greater than ₹ 5,00,000.
select name as Employee_name
from employees_new
where hire_date < '2000-01-01'
and salary > 500000;

# Question 16
# 16.For each department, find the average salary of employees who have had the title of "Manager" at any point in time.
select d.name as Department_Name, avg(e.salary) as Average_Manager_Salary
from employees_new e
join titles_new t on e.employee_id = t.employee_id
join departments d on e.department_id = d.department_id
where t.title = 'Manager'
group by d.name;