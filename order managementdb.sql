create database ordermanagementdb;

use ordermanagementdb;

create table seller(
Seller_id int primary key not null,
Seller_name varchar(50) not null,
Email varchar(50) not null unique);

desc seller;

create table customer(
Customer_id int primary key not null,
Customer_name varchar(50) not null,
Email varchar(50) not null unique,
Phone varchar(15) not null unique,
Address varchar(100) not null);

desc customer;

create table product(
Product_id int primary key not null,
Product_name varchar(50) not null,
Category varchar(50) not null,
Price decimal(10,2) not null check(Price > 0),
Stock  int not null check(Stock >=0),
Seller_id int not null,
constraint fk_product_seller foreign key(Seller_id) references seller(Seller_id));

desc product;

create table Orders(
Order_id int primary key not null,
Customer_id int not null,
Order_date date not null,
Total_amount decimal(10,2) not null default 0 check(Total_amount >= 0),
Order_status varchar(50) not null default 'Pending' check(Order_status in ('Pending','Shipped','Delivered','Cancelled')),
constraint fk_order_customer foreign key(Customer_id) references customer(Customer_id));

desc Orders;

create table Order_details(
Order_Details_id int primary key not null,
Order_id int not null,
Product_id int not null,
Quantity int not null check(Quantity > 0),
Price decimal(10,2) not null check(Price > 0),
constraint fk_detail_order foreign key(Order_id) references Orders(Order_id) on delete cascade,
constraint fk_detail_product foreign key(Product_id) references product(Product_id),
constraint uk_order_product unique(Order_id,Product_id));

desc Order_details;

insert into seller(Seller_id,Seller_name,Email)
values
(1, 'ABC Electronics', 'abc@example.com'),
(2, 'Tech World', 'techworld@example.com');

select * from seller;

insert into customer(Customer_id,Customer_name,Email,Phone,Address)
values
(1, 'Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
(2, 'Priya Sharma', 'priya@gmail.com', '9876543211', 'Coimbatore'),
(3, 'Rahul Raj', 'rahul@gmail.com', '9876543212', 'Madurai'),
(4, 'Divya S', 'divya@gmail.com', '9876543213', 'Trichy'),
(5, 'Karthik M', 'karthik@gmail.com', '9876543214', 'Salem'),
(6, 'Anitha R', 'anitha@gmail.com', '9876543215', 'Chennai');

select * from customer;

insert into product(Product_id,Product_name,Category,Price,Stock,Seller_id)
values
(101, 'Wireless Mouse', 'Accessories', 799.00, 50, 1),
(104, 'Dell Inspiron Laptop', 'Computers', 58999.00, 15, 2),
(110, 'Cisco Network Switch', 'Networking', 8999.00, 10, 1),
(112, 'USB-C Hub', 'Accessories', 1499.00, 25, 1),
(115, 'Ethernet Cable', 'Networking', 299.00, 100, 2);

select * from product;

insert into Orders(Order_id,Customer_id,Order_date,Total_amount,Order_status)
values
(1001, 1, '2026-10-01', 9598.00, 'Delivered'),
(1002, 2, '2026-10-03', 61997.00, 'Shipped'),
(1003, 1, '2026-10-08', 1798.00, 'Pending'),
(1004, 3, '2026-10-10', 9298.00, 'Delivered'),
(1005, 4, '2026-10-12', 299.00, 'Cancelled'),
(1006, 5, '2026-10-15', 1798.00, 'Pending'),
(1007, 2, '2026-10-18', 1499.00, 'Delivered');

select * from Orders;

insert into Order_details(Order_Details_id,Order_id,Product_id,Quantity,Price)
values
 (1, 1001, 110, 1, 8999.00),
(2, 1001, 101, 1, 599.00),
(3, 1002, 104, 1, 58999.00),
(4, 1002, 110, 1, 2998.00),
(5, 1003, 101, 2, 799.00),
(6, 1003, 112, 1, 200.00),
(7, 1004, 110, 1, 8999.00),
(8, 1004, 115, 1, 299.00),
(9, 1005, 115, 1, 299.00),
(10, 1006, 101, 1, 799.00),
(11, 1006, 112, 1, 999.00),
(12, 1007, 112, 1, 1499.00);

select * from Order_details;

insert into Orders(Order_id,Customer_id,Order_date,Total_amount,Order_status)
values
(1008, 6, CURRENT_DATE, 0, 'Pending');

select * from Orders;

insert into Order_details(Order_Details_id,Order_id,Product_id,Quantity,Price)
values
(13, 1008, 101, 2, 799.00),
(14, 1008, 115, 3, 299.00);

select * from Order_details;

update Orders
set Total_amount = (
    select coalesce(sum(Quantity * Price), 0)
    from Order_details
    where Order_id = 1008
)
where Order_id = 1008;

select * from Orders;

update Orders set Order_status = 'Shipped' where Order_id = 1008;

select * from Orders;

update Order_details
set Quantity = 3
where Order_id = 1008 and Product_id = 101;

select * from Order_details;

update Orders o
set Total_amount = (
    select coalesce(sum(od.Quantity * od.Price), 0)
    from Order_details od
    where od.Order_id = o.Order_id
)
where o.Order_id = 1008;

select * from Orders;

select o.Order_id, o.Order_date, o.Order_status, o.Total_amount,
       c.Customer_id, c.Customer_name, c.Email,
       p.Product_id, p.Product_name, od.Quantity, od.Price,
       (od.Quantity * od.Price) as Line_total
from Orders o
join customer c on c.Customer_id = o.Customer_id
join Order_details od on od.Order_id = o.Order_id
join product p on p.Product_id = od.Product_id
order by o.Order_ID, od.Order_Details_id;

delete from Orders where Order_status = 'Cancelled';

select c.Customer_id, c.Customer_name, o.Order_id, o.Order_date,
       o.Order_status, o.Total_amount
from customer c
join Orders o on o.Customer_id = c.Customer_id
order by c.Customer_id, o.Order_date desc;

select p.Product_id, p.Product_name, count(distinct od.Order_id) as Number_of_Orders,
       sum(od.Quantity) as Total_Quantity_Sold,
       sum(od.Quantity * od.Price) as Gross_Line_Sales
from product p
left join Order_details od on od.Product_id = p.Product_id
left join Orders o on o.Order_ID = od.Order_id and o.Order_status <> 'Cancelled'
group by p.Product_id, p.Product_name
order by Total_Quantity_Sold desc;

select p.Product_id, p.Product_name,
       count(distinct case when o.Order_status <> 'Cancelled' then o.Order_id end)
           as Times_Ordered
from product p 
left join Order_details od on od.Product_id = p.Product_id
left join Orders o on o.Order_id = od.Order_id
group by p.Product_id, p.Product_name
order by Times_Ordered desc;

select p.Product_id, p.Product_name,
       coalesce(sum(case when o.Order_status <> 'Cancelled' then od.Quantity else 0 end), 0)
           as Total_Quantity_Sold
FROM product p
left join Order_details od on od.Product_id = p.Product_id
left join Orders o on o.Order_id = od.Order_id
group by p.Product_id, p.Product_name
order by Total_Quantity_Sold desc;

with CustomerOrderCounts as (
    select c.Customer_id, c.Customer_name,
           count(o.Order_id) as Order_Count
    FROM customer c
    left join Orders o
	  on o.Customer_id = c.Customer_id and o.Order_status <> 'Cancelled'
    group by c.Customer_id, c.Customer_name
)
select Customer_id, Customer_name, Order_Count
from CustomerOrderCounts
where Order_Count = (select max(Order_Count) from CustomerOrderCounts);

select c.Customer_id, c.Customer_name,
       coalesce(sum(case when o.Order_status <> 'Cancelled' then o.Total_amount else 0 end), 0)
           as Total_Spending
from customer c
left join Orders o on o.Customer_id = c.Customer_id
group by c.Customer_id, c.Customer_name
order by Total_Spending desc;

select round(avg(Total_amount), 2) as Average_Order_Value
from Orders
where Order_status <> 'Cancelled';

select round(coalesce(sum(Total_amount), 0), 2) as Total_Sales_Amount
from Orders
where Order_status <> 'Cancelled';

select o.Order_id, o.Total_amount as Stored_Total,
       coalesce(sum(od.Quantity * od.Price), 0) as Calculated_Total
from Orders o
left join Order_details od on od.Order_id = o.Order_id
group by o.Order_id, o.Total_amount
having Stored_Total <> Calculated_Total;




















