--Kolokwium 3
--Imiê i nazwisko: Karol Tymiñski		
--Data i godzina: 30-05-2014 12;30
--Grupa laboratoryjna: B
--Czas: 60 min
--Liczba punktów do zdobycia: 20 pkt
--Napisz instrukcje SQL (dla MS SQL Server) realizuj¹ce poni¿sze zadania.

--B1 [7 pkt]
--1) Utwórz tabelê o nazwie Autor zawieraj¹c¹ kolumny:
--a) id, jest unikatowym numerem nadawanym automatycznie, jest to klucz g³ówny [0.5 pkt],
--b) nazwisko, jest unikatowym nazwiskiem dziennikarza, niepustym [0.5 pkt],
--c) pseudonim, jest opcjonalny [0.5 pkt]
CREATE TABLE Autor (
id_autor INTEGER IDENTITY(1,1) PRIMARY KEY,
nazwisko VARCHAR(30) NOT NULL UNIQUE,
pseudonim VARCHAR(20)
);
GO

--2) Utwórz tabelê o nazwie Ksi¹¿ka zawieraj¹c¹ kolumny:
--a) id, jest unikatowym numerem nadawanym automatycznie, jest to klucz g³ówny [0.5 pkt],
--b) tytu³, jest niepustym ³añcuchem znaków zmiennej d³ugoœci od 3 do 30 znaków [0.5 pkt],
--c) rok, jest liczb¹ ca³kowit¹ wiêksz¹ od 1900 [0.5 pkt]
--d) stron, jest liczb¹ ca³kowit¹ z zakresu (0,1200), byæ mo¿e nieokreœlon¹ [1 pkt]
--f) id_au, jest to klucz obcy powi¹zany z kolumn¹ id tabeli Autor, 
--   który w przypadku instrukcji UPDATE wprowadza zmiany kaskadowo, a w przypadku 
--   instrukcji DELETE – wstawia wartoœæ nieokreœlon¹ [2 pkt].

CREATE TABLE ksiazka( 
id_ksiazka INTEGER PRIMARY KEY IDENTITY(1,1), 
tytul VARCHAR(30) NOT NULL CHECK(tytul>='3'), 
rok INTEGER CHECK(rok>'1900'), 
strony INTEGER CHECK(strony>=0 AND strony<=1200), 
id_au INTEGER REFERENCES Autor(id_autor) ON UPDATE CASCADE ON DELETE SET NULL );
GO


--3) Do ka¿dej z tabel dodaj po 2 rekordy [1 pkt]
--Rozwi¹zanie:
SET IDENTITY_INSERT [dbo].[autor] ON
insert into Autor(id_autor,nazwisko, pseudonim) values(1,'Sapkowski', 'Grim'); 
insert into Autor(id_autor,nazwisko, pseudonim) values(2,'Gal', 'Anonim');
SET IDENTITY_INSERT [dbo].[autor] OFF 
SET IDENTITY_INSERT [dbo].[ksiazka] ON
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(1,'Pan Tadeusz','1901', '186',2); 
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(2,'Potop','2003', '540',1);
SET IDENTITY_INSERT [dbo].[ksiazka] OFF
--B2 [6 pkt]
--1) Napisz wyzwalacz o nazwie "insert_ksi¹¿ka", który uniemo¿liwi dodanie drugiej 
--   ksi¹¿ki o takim samym tytule i roku wydania [2 pkt],
--2) Napisz wyzwalacz o nazwie "update_ksi¹¿ka", który uniemo¿liwi zmianê tytu³u 
--   i roku wydania ksi¹¿ki na takie, które ju¿ wystêpuje w bazie danych [2 pkt].
--   (Tak, ¿e w bazie nie bêdzie dwóch ksi¹¿ek o tym samym tytule i roku wydania)
--1///////////////////////////////////////////////////
CREATE TRIGGER insert_ksiazka ON ksiazka
AFTER INSERT AS
 DECLARE @tytul VARCHAR(30)
 DECLARE @rok INTEGER
 DECLARE @strony INTEGER
 SELECT @tytul=tytul, @rok=rok FROM inserted;
 IF (SELECT COUNT(*) FROM ksiazka WHERE @tytul=tytul AND @rok=rok)>1
 BEGIN
 RAISERROR('NIE WOLNO DODAC 2 RAZ TEJ SAMEJ KSIAZKI',1,2)
 ROLLBACK
 END 
--2//////////////////////////////////////////////////// 
CREATE TRIGGER update_ksiazka ON ksiazka 
AFTER UPDATE AS
 DECLARE @tytul VARCHAR(30)
 DECLARE @rok INTEGER
 DECLARE @strony INTEGER
 SELECT @tytul=tytul, @rok=rok FROM inserted;
 IF (SELECT COUNT(*) FROM ksiazka WHERE @tytul=tytul AND @rok=rok)>1
 BEGIN
 RAISERROR('NIE WOLNO DODAC 2 RAZ TEJ SAMEJ KSIAZKI',1,2)
 ROLLBACK
 END 
 
--3) Napisz instrukcje, które przetestuj¹ dzia³anie obu wyzwalaczy, uwzglêdnij testy, 
--   które generuj¹ duplikat tytu³u i numeru oraz te, które nie generuj¹ takiego 
--   duplikatu (razem 4 testy) [2 pkt]:
--Rozwi¹zanie:
--SPRAWDZANIE DO 1 TRIGGERA/////////////////////////////
SET IDENTITY_INSERT [dbo].[ksiazka] ON
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(4,'Pan Tadeusz','1901', '186',2); 
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(5,'Ogniem i Mieczem','2007', '540',1);
SET IDENTITY_INSERT [dbo].[ksiazka] OFF
--SPRAWDZENIE DO 2 TRIGGERA////////////////////////////
UPDATE ksiazka SET tytul='Pan Tadeusz', rok='1901' WHERE id_ksiazka=2
UPDATE ksiazka SET tytul='Bitwa Warszawska', rok='2004' WHERE id_ksiazka=1
--//////////////////////////////////////////////////////////
--B3 [6 pkt]
--1) Napisz procedurê o nazwie "usun_funkcje", która usunie wszystkie funkcje, które
--   zosta³y utworzone przez u¿ytkowników w bie¿¹cej bazie danych [4 pkt].
--   Wskazówka: skorzystaj z dynamicznego SQLa.
CREATE PROCEDURE usun_funkcje  
AS BEGIN DECLARE @sql 
NVARCHAR(50); 
WHILE EXISTS(SELECT * FROM sys.objects where type = 'fn') 
BEGIN SELECT @sql='DROP FUNCTION ' + name FROM sys.objects 
WHERE TYPE = 'fn' 
EXEC sp_executesql @sql 
END 
END 
GO 
EXEC usun_funkcje 
select name from sys.objects where type = 'fn'

drop procedure usun_funkcje
--2) Utwórz dowoln¹ funkcjê o nazwie "fun_testowa" (nie ma znaczenia co ona robi).
--   Napisz instrukcjê uruchamiaj¹c¹ procedurê "usun_funkcje" i udowodnij, ¿e
--   zosta³a ona usuniêta (napisz odpowiedni SELECT) [2 pkt].
--Rozwi¹zanie:

--Sebastian Matyjas, 224599, grupa A
--Utwórz tabele klient(id_klient, nazwisko, kod), gdzie:
--id_klient - automatycznie nadawany, niepusty numer klienta, klucz g³ówny,
--nazwisko - niepusty ³añcuch znaków zmiennej d³ugoœci od 3 do 20 znaków,
--kod - kod pocztowy, dok³adnie 6 znaków

drop table klient;

CREATE TABLE klient (
id_klient INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
nazwisko VARCHAR(20) NOT NULL check(len(nazwisko)>=3),
kod VARCHAR(6) check(len(kod)=6),
);

insert into klient(nazwisko,kod)
values('Kowalski','80-100');







--oraz tabelê zakup(id_zakup, id_klient,nazwa_towaru,ilosc,cena), gdzie:
--id_zakup - niepusty klucz g³ówny, wartoœci nadawane automatycznie,
--id_klient - niepusty klucz obcy powi¹zany z kolumn¹ id_klient tabeli klient,
--nazwa_towaru - unikatowy ³añcuch znaków o zmiennej d³ugoœci od 5 do 60 znaków
--ilosc - liczba nieujemna, wartoœæ domyœlna 0,
--cena - kwota nie ni¿sza ni¿ 5 z³
--Rozwi¹zanie [3pkt]:

drop table zakup;

CREATE TABLE zakup (
id_zakup INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
id_klient INT REFERENCES klient(id_klient),
nazwa_towaru VARCHAR(60) UNIQUE check(len(nazwa_towaru)>=5),
ilosc INT check(ilosc>=0),
cena MONEY check(cena>=5),
);

insert into zakup(id_klient,nazwa_towaru,ilosc,cena)
values(1,'czajnik',2,100);









--Utwórz widok raport(id_klient,nazwisko,kod,suma_wydanych_pieniedzy), gdzie
--id_klient, nazwisko, kod to kolumny z tabeli klient
--suma_wydanych_pieniedzy - ³¹czna suma wydanych pieniêdzy przed danego klienta (suma po ilosci*cena)
--Rozwi¹zanie [1 pkt]
drop view raport;

CREATE VIEW RAPORT AS
SELECT k.id_klient, k.nazwisko, k.kod, SUM( z.ilosc*z.cena ) AS suma_pieniedzy FROM klient k
INNER JOIN zakup z ON k.id_klient=z.id_klient
GROUP BY k.id_klient, k.nazwisko, k.kod;
go

select * from raport;







--Utwórz wyzwalacz, który po wykonaniu zapytania:
--INSERT INTO raport(nazwisko,kod) VALUES ('Gondek','80-287');
--doda nowego klienta do tabeli klient,
--Rozwi¹zanie [3 pkt]

create trigger dodaj_klienta on klient
instead of insert
as





--Do tabeli klient dodaj kolumnê usuniêty, z domyœln¹ wartoœci¹ 0,
--Napisaæ wyzwalacz, który zamiast usun¹æ fizycznie klienta zmieni
--wartoœæ kolumny usuniêty z 0 na 1,
--Rozwi¹zanie [3 pkt]:

drop trigger klient_del;

ALTER TABLE klient ADD usuniety BIT DEFAULT 0;
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'klient_del' AND type = 'TR')
DROP TRIGGER klient_del;
GO
CREATE TRIGGER klient_del on klient
INSTEAD OF DELETE AS
BEGIN
UPDATE klient
SET usuniety=1
WHERE id_klient IN (SELECT id_klient FROM deleted)
END

DELETE from klient where id_klient=1;
SELECT * from klient;

--Napisaæ wyzwalacz, który po dodaniu klienta poprawi jego nazwisko, tak
--aby zaczyna³o siê z wielkiej litery, a pozosta³e litery zmieni na ma³e,
--Uwzglêdnij nazwiska dwucz³onowe, np: Janicka-Nowak,
--Rozwi¹zanie [2 pkt]
drop trigger nazwisko_duze;

CREATE TRIGGER nazwisko_duze ON klient
AFTER INSERT AS
BEGIN
DECLARE kursor_duzy CURSOR
FOR SELECT id_klient, nazwisko from inserted
DECLARE @id int, @nazwisko varchar(20)
OPEN kursor_duzy
FETCH NEXT FROM kursor_duzy INTO @id, @nazwisko
WHILE @@FETCH_STATUS = 0
BEGIN

IF (ascii(SUBSTRING(@nazwisko, 1, 1)) > 96)
BEGIN
UPDATE klient SET nazwisko = UPPER(left(@nazwisko, 1)) + LOWER(SUBSTRING(@nazwisko,2,len(@nazwisko))) where id_klient = @id;
PRINT 'Poprawiono: '+ @nazwisko
END

FETCH NEXT FROM kursor_duzy INTO @id, @nazwisko
END
CLOSE kursor_duzy
DEALLOCATE kursor_duzy
END

INSERT into klient(kod,nazwisko)
VALUES ('80-250','malanowski');

select * from klient;

--Napisaæ funkcjê pomocnicz¹ sprawdz_kod(sprawdzany_kod) zwracaj¹c¹
--wartoœæ true, gdy kod jest napisany w prawid³owym formacie
--(dwie cyfry, myœlnik, trzy cyfry) lub false a w przeciwnym przypadku,
--Napisz wyzwalacz, który uniemo¿liwi modyfikacjê kodu pocztowego
--w tabeli klient na niepoprawny format, wykorzystaj funkcjê sprawdz_kod
--Rozwi¹zanie [3 pkt]

DROP FUNCTION sprawdz_kod;

CREATE FUNCTION sprawdz_kod(@kod VARCHAR(6))
RETURNS BIT
AS
BEGIN
IF (LEN(@kod)=6 AND ISNUMERIC(CONVERT(INT,LEFT(@kod,2)))=1 AND ISNUMERIC(CONVERT(INT,RIGHT(@kod,3)))=1 AND SUBSTRING(@kod,3,1)='-') RETURN 1
RETURN 0
END
GO

PRINT dbo.sprawdz_kod('123-45');
PRINT dbo.sprawdz_kod('12-345');