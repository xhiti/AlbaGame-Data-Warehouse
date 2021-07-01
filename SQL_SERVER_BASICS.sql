/*test query on Northwind DB*/
select * from Employees;

/*Customers*/
select distinct city from Customers;

create table CityTBL(
	id int,
	city nvarchar(500),
	kryetari nvarchar(50)
);

insert into CityTBL (id, city)

select ROW_NUMBER() over (partition by city order by city), city from (
	select city from Customers
	       group by city
) a

select c.city, COUNT(*), COUNT(cs.CustomerID) from CityTBL c JOIN Customers cs
       ON c.city = cs. City
	      group by c.id, c.city;




