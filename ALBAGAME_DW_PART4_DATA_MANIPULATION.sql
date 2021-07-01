--==================================--
--		Testimi i te dhenave		--
--==================================--

--=======================================--
--	AlbaGame Data Warehouse
--	Sisteme Perpunim Informacioni	 (SPI)
--	Master i Shkencave ne Informatike
--	Mexhit Kurti
--	Dt. 20 Janar 2021

--	PERMBAJTJA
--	1.	Krijimi i tabeles seriteBruto
--	2.	Testi i limiteve
--	3.	Testi spacial nr. 1
--	4.	Testi spacial nr. 2
--	5.	Testi i dispersionit

use AlbaGameDW

--======================================--
--	1.  Krijimi i tabeles seriteBruto	--
--======================================--
go
if exists(
	select * from sys.tables where name = 'seriteBruto'
)
drop table seriteBruto
go
create table seriteBruto(
	id			int identity(1, 1)	not null,
	variabel	int					null,
	vendodhje	int					null,
	vlera		float				null,
	data		datetime			null
)

--unifikimi i vlerave
update seriteBruto set vlera = -55555 where vlera is null

--mbushim tabelen seriteBruto me te dhena
insert into seriteBruto
select fsh.produkt, fsh.klient, fsh.cmimi_mes, convert(datetime, right('0' + cast(dh.dita as varchar(2)), 2) + '-' + right('0' + cast(dh.muaji as varchar(2)), 2) + '-' + cast(dh.viti as varchar), 103) from fakt_shitjet fsh
join dim_kohe dh on fsh.kohe = dh.id_dim_kohe


--shtojme 2 kolona ne tabele
alter table seriteBruto add diferenca float(3)
alter table seriteBruto add perqindje numeric(10, 3)

--krijojme nje procedure per te gjeneruar diferencat
go
create or alter procedure gjenero_diferencen
as
begin
	declare @variabli int
	set @variabli = 1
	while @variabli <= (select max(variabel) from seriteBruto)
	begin
		update seriteBruto set diferenca = abs(vlera - (
			   select max(vlera) from seriteBruto sb2
			   where sb2.variabel = @variabli
			   )
		)
		where variabel = @variabli
		set @variabli = @variabli + 1
	end
end
go
--krijojme nje procedure per te gjeneruar perqindjet
create or alter procedure gjenero_perqindjen
as
begin
	declare @variabli int
	set @variabli = 1
	while @variabli <= (select max(variabel) from seriteBruto)
	begin
		update seriteBruto set perqindje = abs(vlera / (
			   select max(vlera) from seriteBruto sb2
			   where sb2.variabel = @variabli
			   ) - 1
		)
		where variabel = @variabli
		set @variabli = @variabli + 1
	end
end

exec gjenero_diferencen
exec gjenero_perqindjen
select * from seriteBruto order by variabel desc




--==========================--
--	2.  Testi i limiteve	--
--==========================--
--krijojme tabelen ku do te vendosim testet
go
if exists(
	select * from sys.tables where name = 'testet'
)
drop table testet
go
create table testet(
	id				int identity(1, 1)	not null,
	testues			nvarchar(50)		null,
	kategori		nvarchar(200)		null,
	tabela			nvarchar(200)		null,
	kushti			nvarchar(200)		null,
	pershkrim		nvarchar(200)		null,
	fusha1			nvarchar(200)		null,
	fusha2			nvarchar(200)		null,
	limiti_poshtem	float				null,
	limiti_siperm	float				null
)

go
create or alter procedure gjenero_testet_limiteve @kategori varchar(200)
as
begin
	declare @id int, @vlera float, @limiti_poshtem float, @limiti_siperm float
	set @id = 1
	--vendosim limitet per cmimet e produkteve
	set @limiti_poshtem = 0.0
	set @limiti_siperm  = 1000.0
	while @id <= (select max(id) from seriteBruto)
	begin
		set @vlera = (select vlera from seriteBruto where id = @id)
		if @vlera > 0 and @vlera <= 1000
		begin
			insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
			values('Testi i limiteve ' + cast(@id as varchar), 'Kategoria 1', 'testet', 'vlera > 0 and vlera <= 1000', 'Vlera ploteson kushtin!', 'Plotesohet', 'Plotesohet', @limiti_poshtem, @limiti_siperm)
		end
		else
		begin
			insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
			values('Testi i limiteve ' + cast(@id as varchar), 'Kategoria 1', 'testet', 'vlera > 0 and vlera <= 1000', 'Vlera nuk ploteson kushtin!', 'Duhet te vleresohet', 'Duhet te vleresohet', @limiti_poshtem, @limiti_siperm)
		end
		set @id = @id + 1
	end
	select id, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm
	from testet where kategori = @kategori order by id

	--kursori per listen e vlerave qe nk plotesojne kushtin
	declare @test varchar, @tabela varchar, @kushti varchar, @pershkrim varchar, @fusha1 varchar, @fusha2 varchar
	declare cursor_vlera_test cursor
	for
	select * from testet where @fusha1 != 'Plotesohet' or @fusha2 != 'Plotesohet' 
	open cursor_vlera_test
	fetch next from cursor_vlera_test into
		@id,
		@test,
		@kategori,
		@tabela,
		@kushti,
		@pershkrim,
		@fusha1,
		@fusha2,
		@limiti_poshtem,
		@limiti_siperm

	while @@FETCH_STATUS = 0
	begin
		select @id, @test, @kategori, @tabela, @kushti, @pershkrim, @fusha1, @fusha2, @limiti_poshtem, @limiti_siperm 
        FETCH NEXT FROM cursor_product INTO 
            @id, 
			@test, 
			@kategori, 
			@tabela, 
			@kushti, 
			@pershkrim, 
			@fusha1, 
			@fusha2, 
			@limiti_poshtem, 
			@limiti_siperm
	end
end
go

exec gjenero_testet_limiteve @kategori = 'Kategoria 1'




--==============================--
--	3.  Testi spacial nr. 1		--
--==============================--
go
create or alter procedure gjenero_testet_spaciale
as
begin
	declare @id int, @limit_1 float, @limit_2 float, @vlera_1 float, @vlera_2 float, @vlera_3 float, @variabel int
	set @id = 1
	while @id <= (select max(variabel) from seriteBruto)
	begin
		set @variabel = (select variabel from seriteBruto where id = @id)
		set @vlera_1 = (select vlera from seriteBruto where id = @id and variabel = @variabel)
		set @vlera_2 = (select vlera from seriteBruto where id = @id + 1 and variabel = @variabel)
		set @vlera_3 = (select vlera from seriteBruto where id = @id + 2 and variabel = @variabel)
		set @limit_1 = @vlera_1 * 0.3
		set @limit_2 = @vlera_1 * 0.01
		if abs(@vlera_1 - @vlera_2) > @limit_1
		begin
			if @id = 1
			begin
				if abs(@vlera_1 - @vlera_2) > @limit_2
				begin
					insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
					values('Testi spacial ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar) + ' and vlera > ' + cast(@limit_2 as varchar) +  '1000', 'Vlere e dyshuar!', 'Nuk plotesohet', 'Nuk Plotesohet', @limit_1, @limit_2)
				end
			end
			else if abs((@vlera_2 - @vlera_3) - (@vlera_1 - @vlera_2)) > @limit_2
			begin
				insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
				values('Testi spacial ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar) + ' and vlera > ' + cast(@limit_2 as varchar) +  '1000', 'Vlere e dyshuar!', 'Nuk plotesohet', 'Nuk Plotesohet', @limit_1, @limit_2)
			end
			else if abs((@vlera_2 - @vlera_3) - (@vlera_1 - @vlera_2)) = 0
			begin
				insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
				values('Testi spacial ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar) + ' and vlera > ' + cast(@limit_2 as varchar), 'Vlere e sakte! Nk ka ndryshim', 'Plotesohet', 'Plotesohet', @limit_1, @limit_2)
			end
			else if @vlera_1 is null or @vlera_2 is null or @vlera_3 is null
			begin
				print('Raste dyshimi qe duhen kontrolluar')
			end
		end
		else
		begin
			insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
			values('Testi spacial ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar) + ' and vlera > ' + cast(@limit_2 as varchar), 'Vlere e sakte! Nk ka ndryshim', 'Plotesohet', 'Plotesohet', @limit_1, @limit_2)
		end
		set @id = @id + 1
	end
end
go

exec gjenero_testet_spaciale




--==============================--
--	4.  Testi spacial nr. 2		--
--==============================--
go
create or alter procedure gjenero_testet_spaciale_2
as
begin
	declare @id int, @limit_1 float, @vlera_1 float, @vlera_2 float, @vlera_3 float, @variabel int
	set @id = 1
	while @id <= (select max(variabel) from seriteBruto)
	begin
		set @variabel = (select variabel from seriteBruto where id = @id)
		set @vlera_1 = (select vlera from seriteBruto where id = @id and variabel = @variabel)
		set @vlera_2 = (select vlera from seriteBruto where id = @id + 1 and variabel = @variabel)
		set @vlera_3 = (select vlera from seriteBruto where id = @id + 2 and variabel = @variabel)
		set @limit_1 = @vlera_1 * 0.3
		if abs(@vlera_1 - @vlera_2) > @limit_1 and abs(@vlera_2 - @vlera_3) > @limit_1 and abs(@vlera_1 - @vlera_3) > @limit_1
		begin
			set @vlera_1 = (@vlera_1 + @vlera_2 + @vlera_3) / 3
			insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
			values('Testi spacial nr. 2 - ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar), 'Vlere e pasakte! Aplikohet intepoli gjeografik', 'Plotesohet', '-', @limit_1, 0)
			update seriteBruto set vlera = @vlera_1 where id = @id
		end
		else
		begin
			insert into testet(testues, kategori, tabela, kushti, pershkrim, fusha1, fusha2, limiti_poshtem, limiti_siperm)
			values('Testi spacial nr. 2 - ' + cast(@id as varchar), 'Kategoria 2', 'testet', 'vlera < ' + cast(@limit_1 as varchar), 'Vlere e sakte!', 'Plotesohet', '-', @limit_1, 0)
		end
		set @id = @id + 1
	end
end
go

exec gjenero_testet_spaciale_2

select * from testet
select * from seriteBruto




--==============================--
--	5.  Testi i dispersionit	--
--==============================--
--krijimi i tabeles vleraTemp
go
if exists(
	select * from sys.tables where name = 'vleraTemp'
)
drop table vleraTemp
go
create table vleraTemp(
	id		int,
	vlera	float
)

--krijimi i tabeles vleraTest
go
if exists(
	select * from sys.tables where name = 'vleraTest'
)
drop table vleraTest
go
create table vleraTest(
	variabli	int,
	stacioni	int,
	data		date,
	t			float,
	s			float,
	vlera		float
)

go
create or alter procedure testiDispersionit
@variabli int
as	
begin
	declare @i int, @vendodhje int, @data datetime, @data1 datetime, @data2 datetime, @vlera float, @t float, @s float, @seri varchar, @stacioni varchar
	declare kursori_vendodhje cursor local for 
	select vendodhje from seriteBruto
	--hapim kursorin e vendodhjes
	open kursori_vendodhje
	fetch next from kursori_vendodhje into @vendodhje
	while @@FETCH_STATUS = 0
	begin
		fetch next from kursori_vendodhje into @vendodhje
		set @i = 1
		delete vleraTemp
		
		declare kursori_date cursor local for 
		select data, vlera from seriteBruto
				where vendodhje = @vendodhje and variabel = @variabli order by data
		open kursori_date
		fetch next from kursori_date into @data, @vlera
		while @@FETCH_STATUS = 0
		begin
			fetch next from kursori_date into @data, @vlera
			if @i = 1
				set @data1 = @data
			else
				set @data2 = @data

			if DATEADD(DAY, 1, @data1) != @data2
			begin
				delete vleraTemp
				set @data1 = @data
				set @i = 1
			end
			if @i < 31
			begin
				insert into vleraTemp values(@i, @vlera)
				set @i = @i + 1
			end
			else
			begin
				set @seri = (select variabel from seriteBruto where id = @i)
				set @stacioni = (select vendodhje from seriteBruto where id = @i)
				select @t = ROUND(SUM(vlera) / 30, 2) from vleraTemp
				select @s = ROUND(SUM(POWER(vlera - @t, 2)) / 30, 2) from vleraTemp
				if ABS(@t - @vlera) > 2.05 * ROUND(SQRT(@s), 2) * ROUND(SQRT(30), 2)
					insert into vleraTest values(@seri, @stacioni, @data, @t, 2.05 * ROUND(SQRT(@s), 2) * ROUND(SQRT(31 / 30), 2), @vlera)
					insert into vleraTemp values(@i, @vlera)
					delete vleraTemp where id = @i - 30
					set @i = @i + 1
				end
				set @data1 = @data
			end
		end
		close kursori_date
		deallocate kursori_date
	end
	close kursori_vendodhje
	deallocate kursori_vendodhje
go

go
create or alter procedure ekzekuto_testin_dispersionit
as
begin
	declare @j int
	set @j = 1
	while @j <= (select max(variabel) from seriteBruto)
	begin
		exec testiDispersionit @variabli = @j
		set @j = @j + 1
	end
end
go

exec ekzekuto_testin_dispersionit

select * from seriteBruto order by variabel asc
select * from vleraTemp
select * from vleraTest



