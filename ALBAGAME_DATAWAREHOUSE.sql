--==========================================--
--	Krijimi i data warehouse per AlbaGame	--
--==========================================--

--=====================================--
--	AlbaGame Data Warehouse
--	Sisteme Perpunim Informacioni (SPI)
--	Master i Shkencave ne Informatike
--	Mexhit Kurti
--	Dt. 15 Janar 2021

--	PERMBAJTJA
--	1. Konfigurimi i DW
--	2. Dimensioni KLIENT
--	3. Dimensioni DYQAN
--	4. Dimensioni PRODUKT
--	5. Dimensioni KOHE
--	6. Fakti SHITJET
--	7. Fakti SHITJET2
--	8. Celja Fillestare


--==============================--
--		1. Konfigurimi i DW		--
--==============================--
go
alter database AlbaGame set recovery simple
go
alter database AlbaGame set auto_shrink off
go
alter database AlbaGame set auto_create_statistics on
go
alter database AlbaGame set auto_update_statistics on
go

use AlbaGameDW

--==============================--
--		2. Dimensioni KLIENT	--
--==============================--
go
if exists(
	select * from sys.tables where name = 'dim_klient'
)
drop table dim_klient
go
create table dim_klient(
	id_dim_klienti		int primary key identity(1, 1),
	id_totali			int,
	totali				varchar(100),
	id_qyteti			int,
	qyteti				varchar(50),
	id_klienti			int,
	emri				varchar(50),
	mbiemri				varchar(50),
	adresa				varchar(100),
	nr_celulari			varchar(20),
	email				varchar(50),
	kodi_postar			varchar(4),
	data_regjistrimit	date,
	klienti_burim		int
)

--mbushja e dimensionit Klient
create or alter procedure mbushKlienteFillestare 
as 
begin
	delete dim_klient
	--mbushja e nivelit Total
	insert into dim_klient(totali) values('Totali i klienteve')
	update dim_klient set id_totali = id_dim_klienti

	--mbushja e nivelit Qytet
	insert into dim_klient(id_totali, totali, id_qyteti, qyteti)
	select dk.id_totali, dk.totali, q.id_qyteti, q.qyteti
	from AlbagameDW.dbo.dim_klient dk, AlbaGameRelationalDB.dbo.QYTET q 
	join AlbaGameRelationalDB.dbo.KLIENT k
	on q.id_qyteti = k. id_qyteti
	order by q.id_qyteti, q.qyteti
	--update dim_klient set id_qyteti = id_dim_klienti where qyteti is not null

	--mbushja e nivelit Klient
	insert into dim_klient(id_totali, totali, id_qyteti, qyteti, emri, mbiemri, adresa, nr_celulari, email, kodi_postar, data_regjistrimit, klienti_burim)
	select dk.id_totali, dk.totali, dk.id_qyteti, dk.qyteti, k.emri, k.mbiemri, k.adresa, k.nr_celulari, k.email, k.kodi_postar, k.data_regjistrimit , k.id_klienti
	from dim_klient dk join AlbaGameRelationalDB.dbo.KLIENT k
	on dk.id_qyteti = k.id_qyteti
	update dim_klient set id_klienti = id_dim_klienti where klienti_burim is not null
end



--==============================--
--		3. Dimensioni DYQAN	--
--==============================--
go
if exists(
	select * from sys.tables where name = 'dim_dyqan'
)
drop table dim_dyqan
go
create table dim_dyqan(
	id_dim_dyqan		int primary key identity(1, 1),
	id_totali			int,
	totali				varchar(100),
	id_dege				int,
	emer_dege			varchar(100),
	tipi				varchar(50),
	dege_burim			int,
	id_dyqani			int,
	emer_dyqani			varchar(100),
	adresa				varchar(100),
	nr_celulari			varchar(20),
	dyqan_burim			int
)

--mbushja e dimensionit Dyqan
create or alter procedure mbushDyqaneFillestare 
as 
begin
	delete dim_dyqan
	--mbushja e nivelit Total
	insert into dim_dyqan(totali) values('Totali i dyqaneve')
	update dim_dyqan set id_totali = id_dim_dyqan

	--mbushja e nivelit Dege
	insert into dim_dyqan(id_totali, totali, emer_dege, tipi, dege_burim)
	select dd.id_totali, dd.totali, dg.emri, dg.tipi, dg.id_dege
	from AlbagameDW.dbo.dim_dyqan dd, AlbaGameRelationalDB.dbo.DEGA dg 
	join AlbaGameRelationalDB.dbo.DYQAN dq
	on dg.id_dege = dq. id_dege
	order by dg.id_dege, dg.emri

	update dim_dyqan set id_dege = id_dim_dyqan where dege_burim is not null
	
	--mbushja e nivelit Dyqan
	insert into dim_dyqan(id_totali, totali, id_dege, emer_dege, tipi, dege_burim, emer_dyqani, adresa, nr_celulari, dyqan_burim)
	select dd.id_totali, dd.totali, dd.id_dege, dd.emer_dege, dd.tipi, dd.dege_burim, dq.emri, dq.adresa, dq.nr_celulari, dq.id_dyqani
	from AlbagameDW.dbo.dim_dyqan dd
	join AlbaGameRelationalDB.dbo.DYQAN dq
	on dd.id_dege = dq. id_dege
	order by dd.id_dege, dd.emer_dege

	update dim_dyqan set id_dyqani = id_dim_dyqan where dyqan_burim is not null
end



--==================================--
--		4. Dimensioni PRODUKT		--
--==================================--
go
if exists(
	select * from sys.tables where name = 'dim_produkt'
)
drop table dim_produkt
go
create table dim_produkt(
	id_dim_produkt		int primary key identity(1, 1),
	id_totali			int,
	totali				varchar(100),
	id_shteti			int,
	shteti				varchar(100),
	id_furnitori		int,
	emer_furnitori		varchar(50),
	marka				varchar(50),
	adresa				varchar(50),
	kodi_postar			varchar(10),
	nr_celulari			varchar(20),
	furnitor_burim		int,
	id_kategori			int,
	emer_kategorie		varchar(50),
	pershkrimi_k		varchar(100),
	kategori_burim		int,
	id_produkti			int,
	emer_produkti		varchar(50),
	pershkrimi_p		varchar(100),
	cmimi				int,
	sasia				int,
	status				int,
	produkt_burim		int
)

--mbushja e diemnsionit Produkt
create or alter procedure mbushProdukteFillestare
as
begin
	delete dim_produkt
	--mbushja e nivelit Total
	insert into dim_produkt(totali) values('Totali i produkteve')
	update dim_produkt set id_totali = id_dim_produkt

	--mbushja e nivelit Shtet
	insert into dim_produkt(id_totali, totali, id_shteti, shteti)
	select dp.id_totali, dp.totali, s.id_shteti, s.emri
	from AlbagameDW.dbo.dim_produkt dp, AlbaGameRelationalDB.dbo.SHTET s
	join AlbaGameRelationalDB.dbo.FURNITOR f
	on s.id_shteti = f.id_shteti
	order by s.id_shteti, s.emri
	--update dim_klient set id_qyteti = id_dim_klienti where qyteti is not null

	--mbushja e nivelit Furnitor
	insert into dim_produkt(id_totali, totali, id_shteti, shteti, emer_furnitori, marka, adresa, kodi_postar, nr_celulari, furnitor_burim)
	select dp.id_totali, dp.totali, dp.id_shteti, dp.shteti, f.emri, f.marka, f.adresa, f.kodi_postar, f.nr_celulari, f.id_furnitori
	from AlbagameDW.dbo.dim_produkt dp
	join AlbaGameRelationalDB.dbo.FURNITOR f
	on dp.id_shteti = f.id_shteti
	order by dp.id_shteti, dp.shteti

	update dim_produkt set id_furnitori = id_dim_produkt where furnitor_burim is not null

	--mbushja e nivelit Kategori
	insert into dim_produkt(id_totali, totali, emer_kategorie, pershkrimi_k, kategori_burim)
	select dp.id_totali, dp.totali, k.emri, k.pershkrimi, k.id_kategori
	from AlbagameDW.dbo.dim_produkt dp
	join AlbaGameRelationalDB.dbo.FURNITOR f
	on dp.furnitor_burim = f.id_furnitori
	join AlbaGameRelationalDB.dbo.PRODUKT p
	on f.id_produkti = p.id_produkti
	join AlbaGameRelationalDB.dbo.KATEGORI k
	on p.id_kategori = k.id_kategori
	order by dp.kategori_burim, emer_kategorie

	update dim_produkt set id_kategori = id_dim_produkt where kategori_burim is not null

	--mbushja e nivelit Produkt
	insert into dim_produkt(id_totali, totali, emer_kategorie, pershkrimi_k, kategori_burim, emer_produkti, pershkrimi_p, cmimi, sasia, status, produkt_burim)
	select dp.id_totali, dp.totali, dp.emer_kategorie, dp.pershkrimi_p, dp.kategori_burim, p.emri, p.pershkrimi, p.cmimi, p.sasia, p.status, p.id_produkti
	from AlbagameDW.dbo.dim_produkt dp
	join AlbaGameRelationalDB.dbo.PRODUKT p
	on dp.kategori_burim = p.id_kategori
	order by dp.kategori_burim, emer_kategorie

	update dim_produkt set id_produkti = id_dim_produkt where produkt_burim is not null
end







--==============================--
--		6. Fakti SHITJET		--
--==============================--
go
if exists(
	select * from sys.tables where name = 'fakt_shitjet'
)
drop table fakt_shitjet

go
create table fakt_shitjet(
	klient		int foreign key references dim_klient(id_dim_klienti),
	produkt		int foreign key references dim_produkt(id_dim_produkt),
	dyqan		int foreign key references dim_dyqan(id_dim_dyqan),
	kohe		int foreign key references dim_kohe(id_dim_kohe),
	sasia		int,
	cmimi_mes	money,
	cmimi_min	money,
	cmimi_max	money,
	vlera		money,
	primary key(klient, produkt, dyqan, kohe)
)


--mbushja e faktit Shitjet
create or alter procedure mbushShitjetFilestare
as
begin
	insert into fakt_shitjet
	select distinct dk.id_dim_klienti, dp.id_dim_produkt, dd.id_dim_dyqan, dkh.id_dim_kohe, 
	sum(d.sasia) sasia, 
	avg(d.cmimi) cmimi_mes, 
	min(d.cmimi) cmimi_min, 
	max(d.cmimi) cmimi_max, 
	sum(d.sasia * d.cmimi) vlera
	from AlbaGameRelationalDB.dbo.POROSI p
	join AlbaGameRelationalDB.dbo.DETAJE_POROSI d on p.id_porosi = d.id_porosi
	join dim_klient dk on p.id_klienti = dk.klienti_burim
	join dim_dyqan dd on p.id_dyqani = dd.dyqan_burim
	join dim_produkt dp on dp.produkt_burim = d.id_produkti
	join dim_kohe dkh on dkh.muaji = month(d.data_porosise) and dkh.viti = year(d.data_porosise) and dkh.dita = day(d.data_porosise)
	group by dk.id_dim_klienti, dd.id_dim_dyqan, dp.id_dim_produkt, dkh.id_dim_kohe
end


--==============================--
--		7. Fakti SHITJET2		--
--==============================--
go
if exists(
	select * from sys.tables where name = 'fakt_shitjet2'
)
drop table fakt_shitjet2
go
create table fakt_shitjet2(
	klient		int foreign key references dim_klient(id_dim_klienti),
	dyqan		int foreign key references dim_dyqan(id_dim_dyqan),
	kohe		int foreign key references dim_kohe(id_dim_kohe),
	sasia		int,
	vlera		money,
	primary key(klient, dyqan, kohe)
)


--mbushja e faktit Shitjet2
create or alter procedure mbushShitjetFilestare2
as
begin
	insert into fakt_shitjet2
	select dk.id_dim_klienti, dd.id_dim_dyqan, dkh.id_dim_kohe, 
	sum(d.sasia) sasia, 
	sum(d.sasia * d.cmimi) vlera
	from AlbaGameRelationalDB.dbo.POROSI p
	join AlbaGameRelationalDB.dbo.DETAJE_POROSI d on p.id_porosi = d.id_porosi
	join dim_klient dk on p.id_klienti = dk.klienti_burim
	join dim_dyqan dd on p.id_dyqani = dd.dyqan_burim
	join dim_kohe dkh on dkh.muaji = month(d.data_porosise) and dkh.viti = year(d.data_porosise) and dkh.dita = day(d.data_porosise)
	group by dk.id_dim_klienti, dd.id_dim_dyqan, dkh.id_dim_kohe
end


--==============================--
--		8. Celja Fillestare		--
--==============================--
--procedura e pergjithshme
create or alter procedure mbushShitjet
as
begin
	exec dbo.mbushKlienteFillestare
	exec dbo.mbushProdukteFillestare
	exec dbo.mbushDyqaneFillestare
	exec dbo.mbushKohaFillestare

	exec dbo.mbushShitjetFilestare
	exec dbo.mbushShitjetFilestare2
end

select * from fakt_shitjet
select * from fakt_shitjet2