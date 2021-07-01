--=======================================--
--	AlbaGame Data Warehouse
--	Sisteme Perpunim Informacioni	(SPI)
--	Master i Shkencave ne Informatike
--	Mexhit Kurti
--	Dt. 07 Shkurt 2021
--	PJESA 3

--	PERMBAJTJA
--	1. Eleminimi i nivelit te poshtem te nje dimensioni
--	2. Eleminimi i nivelit te poshtem ne dimensionin qe ka 2 hierarki
--	3. Eleminimi i nje niveli te mesem ne nje dimension
--	4. Eleminimi i dimensionit KOHE
--	5. Shtimi i dimensionit KOHE
--	6. Permbledhje e procedurave te krijuara
--	7. Restore

use AlbaGameDW
--==============================================================--
--		1. Eleminimi i nivelit te poshtem ne nje dimensioni		--
--==============================================================--
--Zgjedhim dimensionin KLIENT (dimension me 1 hirearki)
--Eleminojme nivelin me te poshtem (niveli KLIENT)
select * from dim_klient
select * from fakt_shitjet

delete dim_klient where id_dim_klienti is not null
--nk mund ta bejme dicka te tille(pse?)
--PROBLEMI:	te dhenat qe jane ne dimensionin DIM_KLIENT ndodhen tek tabela FAKT_SHITJET
--nje alternative zgjidhjeje eshte krijimi i nje tabele temporare me te dhenat e faktit
--tabela temporare sherben si kopje e faktit shitje por me te dhena te transformuara
create or alter procedure eleminoDimensioninKlient
as
begin
	select dk.id_dim_klienti, fsh.produkt, fsh.dyqan, fsh.kohe,
	sum(fsh.sasia) sasia,
	sum(fsh.sasia * fsh.cmimi_mes)/sum(fsh.sasia) cmimi_mes,
	min(fsh.cmimi_min) cmimi_min,
	max(fsh.cmimi_max) cmimi_max,
	sum(fsh.vlera) vlera into shitjet_tmp
	from fakt_shitjet fsh 
	join dim_klient dk on fsh.klient = dk.id_dim_klienti
	group by dk.id_dim_klienti, fsh.produkt, fsh.dyqan, fsh.kohe

	select * from shitjet_tmp

	--fshijme tabelen FAKT_SHITJET
	delete fakt_shitjet

	--te dhenat e transformuara nga tabela SHITJET_TMP i kalojme tek tabela FAKT_SHITJET
	insert into fakt_shitjet
	select * from shitjet_tmp

	--fshijme tabelen temporare SHITJET_TMP
	drop table shitjet_tmp

	--niveli qe kerkojme te heqim (KLIENT) ben pjese ne disa fakte
	drop table fakt_shitjet2

	--riemertojme kolonen
	exec sp_rename 'fakt_shitjet.klient', 'klienti_t', 'COLUMN'

	--fshijme te dhenat nga dimensioni KLIENT
	select * from dim_klient

	delete from dim_klient where id_dim_klienti is not null
	alter table dim_klient drop id_klienti, emri, mbiemri, adresa, nr_celulari, email, kodi_postar, data_regjistrimit, klient_burim

	--riemertojme dimensionin
	exec sp_rename 'dim_klient', 'dim_klient_t'

end
--ndryshojme script-et tek procedurat fillestare
--	...	...	...


--==============================================================================--
--		2. Eleminimi i nivelit te poshtem ne dimensionin qe ka 2 hierarki		--
--==============================================================================--
--Zgjedhim dimensionin PRODUKT (dimension me 2 hirearki)
--Eleminojme nivelin me te poshtem (niveli PRODUKT)
select * from dim_produkt
select * from fakt_shitjet

--fshirja e nivelit PRODUKT sjell si pasoje ndryshimin e lidhjes se dimensionit PRODUKT
--ne kete rast secila hirearki do perfaqesohet ne nje dimension te vetin
--krijimi i tabelave te reja te niveleve si dimensione me vete
create or alter procedure krijoDimensioneTeReja
as
begin
	--krijimi i tabeles dim_kategori
	if exists(
		select * from sys.tables where name = 'dim_kategori'
	)
	drop table dim_kategori
	create table dim_kategori(
		id_dim_kategori		int primary key,
		id_totali			int,
		totali				varchar(100),
		id_kategori			int,
		emer_kategorie		varchar(50),
		pershkrimi_k		varchar(100),
		kategori_burim		int
	)

	--krijimi i tabeles dim_furnitor
	if exists(
		select * from sys.tables where name = 'dim_furnitor'
	)
	drop table dim_furnitor

	create table dim_furnitor(
		id_dim_furnitor		int primary key,
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
		furnitor_burim		int
	)
end

--mbushja e dimensioneve te reja me vlera
create or alter procedure mbushDimensioneTeReja
as
begin
	--mbushja e dimensionit dim_kategori
	insert into dim_kategori
	select id_dim_produkt, id_totali, totali, id_kategori, emer_kategorie, pershkrimi_k, kategori_burim
	from dim_produkt 
	where id_shteti is null and id_kategori is null and id_furnitori is null 

	insert into dim_kategori 
	select id_dim_produkt, id_totali, totali , id_kategori, emer_kategorie, pershkrimi_k, kategori_burim
	from dim_produkt 
	where id_kategori is not null and id_dim_produkt is not null 

	--mbushja e dimensionit dim_furnitor
	insert into dim_furnitor(id_dim_furnitor, id_totali, totali)
	select id_dim_produkt, id_totali, totali 
	from dim_produkt
	where id_shteti is null and id_kategori is null and id_furnitori is null

	insert into dim_furnitor
	select id_dim_produkt, id_totali, totali, id_shteti, shteti, id_furnitori, emer_furnitori, marka, adresa, kodi_postar, nr_celulari, furnitor_burim
	from dim_produkt
	where id_shteti is not null and id_produkti is null 
end

select * from dim_kategori
select * from dim_furnitor

--krijojme tabelen fakt te re per keto dimensione
create or alter procedure krijoFaktTeRi
as
begin
	--krijimi i faktit te ri
	if exists(
		select * from sys.tables where name = 'fakt_shitje_te_reja'
	)
	drop table fakt_shitje_te_reja

	create table fakt_shitje_te_reja(
		klient		int foreign key references dim_klient(id_dim_klienti),
		dyqan		int foreign key references dim_dyqan(id_dim_dyqan),
		kategori	int foreign key references dim_kategori(id_dim_kategori),
		furnitor	int foreign key references dim_furnitor(id_dim_furnitor),
		kohe		int foreign key references dim_kohe(id_dim_kohe),
		sasia_re	int,
		cmimi_mes	money,
		cmimi_min	money,
		cmimi_max	money,
		vlera		money,
		primary key(klient, dyqan, kategori, furnitor, kohe)
	)

	--mbushja e faktit te ri me te dhena
	insert into fakt_shitje_te_reja
	select fsh.klienti_t, fsh.dyqan , dp.id_kategori, dp.id_furnitori, fsh.kohe,  
	sum(fsh.sasia) sasia_re, 
	sum(vlera)/sum(fsh.sasia) cmimi_mes, 
	min(cmimi_min) cmimi_min, 
	max(cmimi_max) cmimi_max, 
	sum(vlera) vlera
	from fakt_shitjet fsh 
	join dim_produkt dp on dp.id_dim_produkt = fsh.produkt
	group by fsh.klienti_t, fsh.dyqan, dp.id_kategori, dp.id_furnitori, fsh.kohe
end

--procedura per eleminimin e nivelit te poshtem me me sh se 1 hirearki
create or alter procedure eleminoDimensioninProdukt
as
begin
	exec krijoDimensioneTeReja
	exec mbushDimensioneTeReja
	exec krijoFaktTeRi
end

exec eleminoDimensioninProdukt


--==============================================================--
--		3. Eleminimi i nje niveli te mesem ne nje dimension		--
--==============================================================--
--Zgjedhim dimensionin DYQAN (dimension me 1 hirearki)
--Eleminojme nivelin e mesem (niveli DEGA)
select * from dim_dyqan
select * from fakt_shitjet

delete dim_dyqan where id_dim_dyqan is not null
--nk mund ta bejme dicka te tille(pse?)
--PROBLEMI:	te dhenat qe jane ne dimensionin DIM_DYQAN ndodhen tek tabela FAKT_SHITJET
--nje alternative zgjidhjeje eshte krijimi i nje tabele temporare me te dhenat e faktit
--tabela temporare sherben si kopje e faktit shitje por me te dhena te transformuara
create or alter procedure eleminoNivelinDege
as
begin
	select fsh.klienti_t, fsh.produkt, dd.id_dim_dyqan, fsh.kohe,
	sum(fsh.sasia) sasia,
	sum(fsh.sasia * fsh.cmimi_mes)/sum(fsh.sasia) cmimi_mes,
	min(fsh.cmimi_min) cmimi_min,
	max(fsh.cmimi_max) cmimi_max,
	sum(fsh.vlera) vlera into shitjet_tmp
	from fakt_shitjet fsh 
	join dim_dyqan dd on fsh.dyqan = dd.id_dim_dyqan
	group by fsh.klienti_t, fsh.produkt, dd.id_dim_dyqan, fsh.kohe

	select * from shitjet_tmp

	--fshijme tabelen FAKT_SHITJET
	delete fakt_shitjet

	--te dhenat e transformuara nga tabela SHITJET_TMP i kalojme tek tabela FAKT_SHITJET
	insert into fakt_shitjet
	select * from shitjet_tmp

	--fshijme tabelen temporare SHITJET_TMP
	drop table shitjet_tmp

	--niveli qe kerkojme te heqim (KLIENT) ben pjese ne disa fakte
	drop table fakt_shitjet2

	--riemertojme kolonen
	exec sp_rename 'fakt_shitjet.dyqan', 'dyqani_t', 'COLUMN'

	--fshijme te dhenat nga dimensioni KLIENT
	delete from dim_dyqan where id_dim_dyqan is not null
	alter table dim_dyqan drop id_dege, emer_dege, tipi, dege_burim

	--riemertojme dimensionin
	exec sp_rename 'dim_dyqan', 'dim_dyqan_t'

end
--ndryshojme script-et tek procedurat fillestare
--	...	...	...
exec eleminoNivelinDege


--==========================================--
--		4. Eleminimi i dimensionit kohe		--
--==========================================--
--krijojme nje tabele temporare te faktit
select * from fakt_shitjet

create or alter procedure eleminoDimensioninKohe
as 
begin
	select klienti_t, produkt, dyqani_t, kohe,
	sum(sasia) sasia,
	sum(sasia * cmimi_mes)/sum(sasia) cmimi_mes,
	min(cmimi_min) cmimi_min,
	max(cmimi_max) cmimi_max,
	sum(vlera) vlera into shitjet_temp
	from fakt_shitjet
	group by klienti_t, produkt, dyqani_t, kohe

	--fshijme tabelen e faktit
	delete fakt_shitjet

	--fshijme kolonat e dimensioneve te tjera(perjashtuar kolonen produkt)
	alter table shitjet_temp drop column klienti_t, dyqani_t, kohe

	--kalojme te dhenat nga tabela temporare ne tabelen fakt
	insert into fakt_shitjet
	select * from shitjet_temp

	--fshijme dimensionin kohe
	drop table dim_kohe

	--perditesojme scriptet
	--...	...	...	...	...
	
end

select * from shitjet_temp


--==========================================--
--		5. Shtimi i dimensionit kohe		--
--==========================================--
--shtimi i dimensionit kohe do te behet serish nga e para
--puna  perfshin krijimin e tabeles
--		mbushjen e tabeles me te dhena
--		krijimin e tabeles fakt perseri nga e para
create or alter procedure shtoDimensioninKohe
as
begin
	--krijimi i tabeles dim_kohe
	if exists(
		select * from sys.tables where name = 'dim_kohe'
	)
	drop table dim_kohe
	create table dim_kohe( 
		id_dim_kohe			int primary key identity(1, 1),
		id_totali			int,
		totali				varchar(100),
		id_viti				int,
		viti				varchar(100),
		pershkrim_viti		varchar(100),
		id_muaji			int, 
		muaji				varchar(100),
		pershkrim_muaji		varchar(100)
	)

	--mbushja me te dhena
	--ne kemi nje procedure qe e kemi ndertuar ne hapat e pare te ndertimit te DW
	--japim run procedures mbushKohaFillestare
	exec mbushKohaFillestare

	--krijimin e tabeles fakt_shitjet
	if exists(
		select * from sys.tables where name = 'fakt_shitjet'
	)
	drop table fakt_shitjet
	create table fakt_shitjet(
		klient		int foreign key references dim_klient(id_dim_klienti),
		produkt		int foreign key references dim_produkt(id_dim_produkt),
		dyqan		int foreign key references dim_dyqan_t(id_dim_dyqan),
		kohe		int foreign key references dim_kohe(id_dim_kohe),
		sasia		int,
		cmimi_mes	money,
		cmimi_min	money,
		cmimi_max	money,
		vlera		money,
		primary key(klient, produkt, dyqan, kohe)
	)
	--mbushja me te dhena
	--ne kemi nje procedure qe e kemi ndertuar ne hapat e pare te ndertimit te DW
	--japim run procedures mbushShitjetFillestare
	exec mbushShitjetFilestare
end

--==========================================--
--		5. Permbledhja e detyres 3			--
--==========================================--
--duhet te ekzekutohen te gjitha procedurat mesiperme
--eleminimi i nivelit te poshtem me 1 hirearki KLIENT
exec eleminoDimensioninKlient
--eleminimi i nivelit te poshtem me me sh se 1 hirearki PRODUKT
exec eleminoDimensioninProdukt
--eleminimi i nivelit te mesem DEGE
exec eleminoNivelinDege
--eleminimi i dimensionit KOHE
exec eleminoDimensioninKohe
--shtimi i dimensionit KOHE
exec shtoDimensioninKohe


--==========================================--
--			6.		RESTORE					--
--==========================================--
--keto jane ndryshime te perkohshme
--japim RESTORE databazes per ta rikthyer ne gjendjen e meparshme

