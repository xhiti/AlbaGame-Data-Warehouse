use AlbaGameRelationalDB;

--krijimi i tabelave te bazes se te dhenave
--krijimi i tablese KLIENT
create table Klient(
	id_klient	int identity(1,1),
	emri		varchar(50) NOT NULL,
	mbiemri		char(50),
	qyteti		char(50),
	kodi_postar char(10),
	constraint klient_pk primary key (id_klient)
);