--======================================================--
--	Krijimi i bazes se te dhenave relacionale AlbaGame	--
--======================================================--

--=======================================--
--	AlbaGame Database
--	Sisteme Perpunim Informacioni	(SPI)
--	Master i Shkencave ne Informatike
--	Mexhit Kurti
--	Dt. 10 Janar 2021

--	PERMBAJTJA
--	1.	Tabela	QYTET
--	2.	Tabela	KLIENT
--	3.	Tabela	DEGA
--	4.	Tabela	DYQAN
--	5.	Tabela	KATEGORI
--	6.	Tabela	SHTET
--	7.	Tabela	FURNITOR
--  8.	Tabela	PRODUKT
--	9.	Tabela	POROSI
--	10.	Tabela	DETAJE_POROSI

use AlbaGameRelationalDB

--==============================--
--		1. Tabela	QYTET		--
--==============================--
create table QYTET(
	id_qyteti	int	primary key identity(1, 1),
	qyteti		varchar(50)	not null
)

insert into QYTET values('Berat')
insert into QYTET values('Diber')
insert into QYTET values('Durres')
insert into QYTET values('Elbasan')
insert into QYTET values('Fier')
insert into QYTET values('Lushnje')
insert into QYTET values('Gjirokaster')
insert into QYTET values('Korce')
insert into QYTET values('Pogradec')
insert into QYTET values('Kukes')
insert into QYTET values('Lezhe')
insert into QYTET values('Shkoder')
insert into QYTET values('Tirane')
insert into QYTET values('Vlore')
insert into QYTET values('Sarande')

select * from QYTET order by qyteti asc

drop table QYTET


--==============================--
--		2. Tabela	KLIENT		--
--==============================--
create table KLIENT(
	id_klienti			int	primary key identity(1, 1),
	emri				varchar(50)	not null,
	mbiemri				varchar(50)	not null,
	adresa				varchar(100),
	nr_celulari			varchar(20),
	email				varchar(50),
	id_qyteti			int foreign key references QYTET(id_qyteti),
	kodi_postar			varchar(4),
	data_regjistrimit	date
)

insert into KLIENT(emri, mbiemri) values('Mexhit','Kurti')
insert into KLIENT(emri, mbiemri) values('Lorenc','Zhuka')
insert into KLIENT(emri, mbiemri) values('Marinel','Bektasha')
insert into KLIENT(emri, mbiemri) values('Naum','Todolli')
insert into KLIENT(emri, mbiemri) values('Kleina','Cika')
insert into KLIENT(emri, mbiemri) values('Marsiona','Stafa')
insert into KLIENT(emri, mbiemri) values('Kejsi','Asllanaj')
insert into KLIENT(emri, mbiemri) values('Ervin','Shehu')
insert into KLIENT(emri, mbiemri) values('Xhenaro','Ruci')
insert into KLIENT(emri, mbiemri) values('Jonida','Krraba')
insert into KLIENT(emri, mbiemri) values('Lorenc','Totri')
insert into KLIENT(emri, mbiemri) values('Alket','Kurti')
insert into KLIENT(emri, mbiemri) values('Redian','Kanani')
insert into KLIENT(emri, mbiemri) values('Ardit','Ademi')
insert into KLIENT(emri, mbiemri) values('Eraldo','Forgali')
insert into KLIENT(emri, mbiemri) values('Albion','Gjoni')
insert into KLIENT(emri, mbiemri) values('Erion','Isaku')
insert into KLIENT(emri, mbiemri) values('Aleksander','Deda')
insert into KLIENT(emri, mbiemri) values('Loresa','Hoxha')
insert into KLIENT(emri, mbiemri) values('Elsa','Imeraj')
insert into KLIENT(emri, mbiemri) values('Mario','Malja')
insert into KLIENT(emri, mbiemri) values('Anjeza','Sejdiu')
insert into KLIENT(emri, mbiemri) values('Serafin', 'Frroku')
insert into KLIENT(emri, mbiemri) values('Eva', 'Biba')
insert into KLIENT(emri, mbiemri) values('Amela', 'Beshiri')

update top(25) KLIENT set data_regjistrimit = GETDATE()
update top(25) KLIENT set kodi_postar = (select DISTINCT(ABS(CHECKSUM(NEWID()) % (1033 - 1001 - 1)) + 1001))

declare @i int, @n int 
set @n = (select count(id_klienti) from KLIENT)
set @i = 1
while ( @i <= @n)
begin
	print @i
    update KLIENT set id_qyteti = (select top 1 id_qyteti from QYTET order by NEWID()) where id_klienti = @i
	update KLIENT set email = (select LOWER(emri+mbiemri+'@gmail.com') from KLIENT where id_klienti = @i) where id_klienti = @i
	update KLIENT set nr_celulari = (select top 1 Phone from Northwind.dbo.Customers order by NEWID()) where id_klienti = @i
	update KLIENT set adresa = (select top 1 Address from Northwind.dbo.Customers order by NEWID()) where id_klienti = @i
	print 'Updating...'
	if @i >= 25
	begin
	  break
	end
	  set @i = @i + 1
end

select * from KLIENT order by emri asc

drop table KLIENT

--==============================--
--		3. Tabela	DEGA		--
--==============================--
create table DEGA(
	id_dege		int primary key identity(1, 1),
	emri		varchar(100) not null,
	tipi		varchar(50)
)

insert into DEGA values('AlbaGame Selvia', 'Distributor')
insert into DEGA values('AlbaGame TEG', 'Full outlet')
insert into DEGA values('AlbaGame Blloku', 'Full outlet')
insert into DEGA values('AlbaGame Rruga e Kavajes', 'Distributor')

select * from DEGA order by emri asc

drop table DEGA


--==============================--
--		4. Tabela	DYQAN		--
--==============================--
create table DYQAN(
	id_dyqani		int primary key identity(1, 1),
	emri			varchar(100) not null,
	adresa			varchar(100),
	nr_celulari		varchar(20),
	id_dege			int foreign key references DEGA(id_dege)
)

insert into DYQAN values('AlbaGame', 'Rruga e Saracve Tirane, 1001, Albania', '+355694052404', 1)
insert into DYQAN values('AlbaGame', 'Rruga Mujo Ulqinaku, Tiranë, Albania', '+355696023830', 4)
insert into DYQAN values('AlbaGame', '1001, Rruga Deshmoret e 4 Shkurtit, Tirana, Albania', '+355682121526', 3)
insert into DYQAN values('AlbaGame', 'Tirana East Gate Rruga e Elbasanit KM 5, Tiranë, Albania', '+355697035450', 2)

select * from DYQAN order by emri asc

drop table DYQAN


--==================================--
--		5. Tabela	KATEGORI		--
--==================================--
create table KATEGORI(
	id_kategori		int primary key identity(1, 1),
	emri			varchar(50) not null,
	pershkrimi		varchar(200)
)

insert into KATEGORI values('Videogames', 'Videogames for all gaming platform')
insert into KATEGORI values('Playstation 5', 'Videogames for all gaming platform')
insert into KATEGORI values('XBox Series X', 'Videogames for all gaming platform')
insert into KATEGORI values('XBox One', 'Videogames for all gaming platform')
insert into KATEGORI values('Switch', 'Videogames for all gaming platform')
insert into KATEGORI values('PC Gaming', 'Videogames for all gaming platform')
insert into KATEGORI values('Mobile Gaming', 'Videogames for all gaming platform')
insert into KATEGORI values('Digital & Downloads', 'Videogames for all gaming platform')
insert into KATEGORI values('Storage', 'Electronics & Computers')
insert into KATEGORI values('PC Peripheral', 'Electronics & Computers')
insert into KATEGORI values('Network', 'Electronics & Computers')
insert into KATEGORI values('Charger & Adapters', 'Electronics & Computers')
insert into KATEGORI values('XBox Series X', 'Electronics & Computers')
insert into KATEGORI values('Audio', 'Electronics & Computers')
insert into KATEGORI values('Smart Devices', 'Electronics & Computers')
insert into KATEGORI values('Sports & Outdoor', 'Electronics & Computers')
insert into KATEGORI values('Action Figures', 'Hobby & Toys')
insert into KATEGORI values('Sport Toys', 'Hobby & Toys')
insert into KATEGORI values('Board Games', 'Hobby & Toys')
insert into KATEGORI values('Electornic Toys', 'Hobby & Toys')

select * from KATEGORI order by emri asc

drop table KATEGORI


--==============================--
--		6. Tabela	SHTET		--
--==============================--
create table SHTET(
	id_shteti	int primary key identity(1, 1),
	emri		varchar(100) not null,
)

insert into SHTET values('Japan')
insert into SHTET values('United States of America')
insert into SHTET values('Germany')
insert into SHTET values('Great Britain')
insert into SHTET values('Singapore')
insert into SHTET values('Netherlands')
insert into SHTET values('France')
insert into SHTET values('Italy')
insert into SHTET values('China')

select * from SHTET order by emri asc

drop table SHTET


--==================================--
--		7. Tabela	FURNITOR		--
--==================================--
create table FURNITOR(
	id_furnitori	int primary key identity(1, 1),
	emri			varchar(50) not null,
	marka			varchar(50),
	pershkrimi		varchar(100),
	id_produkti		int foreign key references PRODUKT(id_produkti),
	adresa			varchar(50),
	kodi_postar		varchar(10),
	nr_celulari		varchar(20),
	id_shteti		int foreign key references SHTET(id_shteti)
)

insert into FURNITOR values('Play Station', 'PS', 'Gaming Platform', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Nintendo Switch', 'NS', 'Gaming Platform', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('XBox', 'XBox', 'Gaming Platform', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Razer', 'Razer', 'Devices', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Trust Gaming', 'Trust Gaming', 'Gaming Platform', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Steam', 'Steam', 'Gaming Platform', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('EA', 'EA Sports', 'Video Games', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Fortnite', 'Fortnite', 'Video Game', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Marvel', 'Marvel', 'Video Games', 1, ' ', ' ', ' ', 1)
insert into FURNITOR values('Konami', 'Konami', 'Video Games', 1, ' ', ' ', ' ', 1)

update top(10) FURNITOR set kodi_postar = (select DISTINCT(ABS(CHECKSUM(NEWID()) % (1033 - 1001 - 1)) + 1001))

declare @j int, @m int 
set @m = (select count(id_produkti) from PRODUKT)
set @j = 1
while ( @j <= @m)
begin
	print @j
	update FURNITOR set adresa = (select top 1 Address from Northwind.dbo.Customers order by NEWID()) where id_furnitori = @j
	update FURNITOR set id_shteti   = (select top 1 id_shteti from SHTET order by NEWID()) where id_furnitori = @j
	update FURNITOR set id_produkti = (select top 1 id_produkti from PRODUKT order by NEWID()) where id_furnitori = @j
	if @j >= @m
	begin
	  break
	end
	  set @j = @j + 1
end

select * from FURNITOR order by emri asc

drop table FURNITOR


--==================================--
--		8. Tabela	PRODUKT			--
--==================================--
create table PRODUKT(
	id_produkti		int primary key identity(1, 1),
	emri			varchar(50) not null,
	pershkrimi		varchar(100),
	id_kategori		int foreign key references KATEGORI(id_kategori),
	cmimi			money,
	sasia			int,
	status			int
)

insert into PRODUKT values('Console Nintendo Switch', 'Console Nintendo Switch Mario Red & Blue Special Edition', 5, 397, 100, 1)
insert into PRODUKT values('U-PlayStation VR', 'U-PlayStation VR', 1, 245, 50, 1)
insert into PRODUKT values('Gaming Chair Trust', 'Gaming Chair Trust GXT 712 Resto PRO', 11, 327, 20, 1)
insert into PRODUKT values('Keyboard Gaming Razer', 'Keyboard Gaming Razer BlackWidow V3 Mechanical (Green Switch)', 10, 151, 30, 1)
insert into PRODUKT values('Cooling Fan Gaming Redragon', 'Cooling Fan Gaming Redragon Ivy GCP500', 10, 28, 50, 1)
insert into PRODUKT values('Headset Gaming Redragon', 'Headset Gaming Redragon Pandora H350 RGB', 10, 32, 50, 1)
insert into PRODUKT values('Microphone Gaming Redragon', 'Microphone Gaming Redragon Quasar 2 GM200-1', 10, 43, 50, 1)
insert into PRODUKT values('PS4 Puyo', 'PS4 Puyo Puyo Tetris 2', 5, 31, 50, 1)
insert into PRODUKT values('XBox Puyo', 'XBox Puyo Puyo Tetris 2', 3, 35, 50, 1)
insert into PRODUKT values('PS5 Puyo', 'PS5 Puyo Puyo Tetris 2', 5, 40, 50, 1)
insert into PRODUKT values('Colorfilm Instax Square', 'Colorfilm Instax Square Rainbow WW1', 15, 15, 50, 1)
insert into PRODUKT values('Camera Instax Mini', 'Camera Instax Mini 11 Sky Blue Bundle Box', 9, 127, 50, 1)
insert into PRODUKT values('Gaming Chair Nacon', 'Gaming Chair Nacon PCCH-310', 8, 147, 50, 1)
insert into PRODUKT values('Game Capture Card Razer Ripsaw HD', 'Game Capture Card Razer Ripsaw HD', 6, 176, 50, 1)
insert into PRODUKT values('Controller Xbox Series X', 'Controller Xbox Series X Wireless Shock Black + USB Cable', 3, 77, 50, 1)
insert into PRODUKT values('Usb Charger Ldnio', 'Usb Charger Ldnio 4 Ports 5V/4.4A 22W with LED Lamp White', 12, 16, 50, 1)
insert into PRODUKT values('PS4 Resident Evil 6 PlayStation Hits', 'PS4 Resident Evil 6 PlayStation Hits', 1, 20, 50, 1)
insert into PRODUKT values('Tablet Amazon Fire HD', 'Tablet Amazon Fire HD 8” 64GB B07TMJ1R3X Black', 7, 151, 50, 1)
insert into PRODUKT values('Kindle Amazon Touch 6', 'Kindle Amazon Touch 6” 8GB B07DLPWYB7 White', 7, 131, 50, 1)
insert into PRODUKT values('Electric Scooter Razor', 'Electric Scooter Razor Power Core E90 Black/Pink', 15, 155, 50, 1)
insert into PRODUKT values('Playdoh Kitchen', 'Playdoh Kitchen Creations Grocery Goodies', 17, 22, 50, 1)
insert into PRODUKT values('Lego Storage Minifigure', 'Lego Storage Minifigure Display Case Black 4066', 19, 25, 50, 1)
insert into PRODUKT values('Lego Marvel Super Heroes Avengers', 'Lego Marvel Super Heroes Avengers Helicarrier 76153', 19, 139, 50, 1)
insert into PRODUKT values('Lego Marvel Super Heroes Avengers', 'Lego Marvel Super Heroes Avengers Helicarrier 76153', 19, 139, 50, 1)
insert into PRODUKT values('PS5 Fortnite The Last Laugh Bundle', 'PS5 Fortnite The Last Laugh Bundle', 1, 39, 50, 1)
insert into PRODUKT values('Console PlayStation 5', 'Console PlayStation 5', 1, 508, 50, 1)
insert into PRODUKT values('Controller PS5 Sony', 'Controller PS5 Sony Dualsense Wireless Standalone', 1, 73, 50, 1)
insert into PRODUKT values('Camera PS5 HD', 'Camera PS5 HD', 1, 61, 50, 1)
insert into PRODUKT values('PS5 Marvel’s Spider-Man', 'PS5 Marvel’s Spider-Man Miles Morales', 1, 61, 50, 1)
insert into PRODUKT values('PS5 Final Fantasy XVI', 'PS5 Final Fantasy XVI', 1, 73, 50, 1)


update top(25) PRODUKT set sasia = (select DISTINCT(ABS(CHECKSUM(NEWID()) % (100 - 50 - 1)) + 50))

--nqs eshte bere furnizmi atehere produkti eshte i disponueshem per porosi
update PRODUKT set status = 1 where id_produkti IN(select id_produkti from FURNITOR)

alter table PRODUKT add data_regjistrimit datetime

update PRODUKT set data_regjistrimit = '01-01-2020'

select * from PRODUKT

drop table PRODUKT


--==================================--
--		9. Tabela	POROSI			--
--==================================--
create table POROSI(
	id_porosi		int primary key identity(1,1),
	id_klienti		int foreign key references KLIENT(id_klienti),
	id_dyqani		int foreign key references DYQAN(id_dyqani),
)

declare @k int, @x int 
set @x = (select count(id_klienti) from KLIENT)
set @k = 1
while ( @k <= @x)
begin
	print @k
	insert into POROSI values(1, 1)
	update POROSI set id_klienti = (select top 1 id_klienti from KLIENT order by NEWID())
	update POROSI set id_dyqani  = (select top 1 id_dyqani from DYQAN order by NEWID())
	if @k >= @x
	begin
	  break
	end
	  set @k = @k + 1
end

select * from POROSI

drop table POROSI

--==========================================--
--		10. Tabela	DETAJE_POROSI			--
--==========================================--
create table DETAJE_POROSI(
	id_produkti		int foreign key references PRODUKT(id_produkti),
	id_porosi		int foreign key references POROSI(id_porosi),
	cmimi			money,
	sasia			int,
	data_porosise	date,
	status			int
)

declare @a int, @b int, @data_fillestare Date = '2020-01-01'
set @b = (select count(id_porosi) from POROSI)
set @a = 1
while ( @a <= @b)
begin
	print @a
	insert into DETAJE_POROSI values(1, 1, 1, 1, '2021-01-18', 1)
	update DETAJE_POROSI set id_produkti = (select top 1 id_produkti from PRODUKT order by NEWID())
	update DETAJE_POROSI set id_porosi  = (select top 1 id_porosi from POROSI order by NEWID())
	update DETAJE_POROSI set data_porosise = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 364 ), @data_fillestare)
	if @a >= @b
	begin
	  break
	end
	  set @a = @a + 1
end

update DETAJE_POROSI set cmimi = p.cmimi - p.cmimi * (0.01 * ABS(DATEDIFF(month, d.data_porosise, p.data_regjistrimit))) from DETAJE_POROSI d INNER JOIN PRODUKT p on d.id_produkti = p.id_produkti;
update DETAJE_POROSI set sasia = (select (ABS(CHECKSUM(NEWID()) % (10 - 1 - 1)) + 1))
update DETAJE_POROSI set status = p.status from DETAJE_POROSI d INNER JOIN PRODUKT p on d.id_produkti = p.id_produkti

select * from DETAJE_POROSI order by id_produkti

drop table DETAJE_POROSI