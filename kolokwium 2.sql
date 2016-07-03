--Imi� i nazwisko:
--Data i godzina:
--Grupa laboratoryjna:
--Obowi�zuj�ca baza danych: sklep, http://fidytek.pl/bazy_danych/bd_skrypt_sql/sklep_mssql 

--Napisa� instrukcje SQL (dla MS SQL Server) realizuj�ce poni�sze zadania.

--AN_41 [3 pkt]
--Znajd� pracownik�w (id_pracownik, imie, nazwisko), kt�rzy maj� pensj� (nie liczymy dodatku)
--wy�sz� ni� 2600 z� i pracuj� na stanowisku sprzedawcy.
--Wynik posortuj leksykograficznie po nazwisku i imieniu.
--Rozwi�zanie:

SELECT id_pracownik, imie, nazwisko, stanowisko 
FROM pracownik 
WHERE pensja > 2600 AND stanowisko='sprzedawca'
ORDER BY nazwisko ASC, imie ASC; 


--AN_42 [4 pkt]
--Osobom, kt�re s� klientami od co najmniej 4 (pe�nych) lat 
--zwi�ksz dotychczasowy rabat o 5%.

--Rozwi�zanie:

UPDATE klient 
SET rabat=rabat*1.05 
WHERE data_dodania BETWEEN '06-04-2012' AND GETDATE()

--AN_43 [4 pkt]
--Usu� pracownik�w, kt�rzy nie przyj�li �adnego zam�wienia.
--Rozwi�zanie:

SELECT * FROM pracownik
DELETE pracownik
FROM pracownik
JOIN zamowienie ON pracownik.id_pracownik=zamowienie.id_zamowienie
WHERE zamowienie.data_zamowienia IS NULL;

--AN_44 [4 pkt]
--Dla ka�dego klienta (nazwisko i imie), wy�wietl informacj� ile z�o�y� on zam�wie�.
--Uwzgl�dnij te� tych klient�w, kt�rzy nie z�o�yli �adnego zam�wienia.
--Wynik posortuj malej�co po ilo�ci z�o�ych zam�wie�, a dla takiej samej 
--ilo�ci zam�wie� leksykograficznie po nazwisku i imieniu.
--Uwaga: dw�ch klient�w mo�e posiada� to samo imi� i nazwisko.
--Rozwi�zanie:

SELECT k.imie, k.nazwisko , COUNT(z.id_klient) as Ile
FROM klient k 
LEFT JOIN zamowienie z ON k.id_klient=z.id_klient
GROUP BY k.nazwisko, k.imie, z.id_klient
ORDER BY Ile DESC, nazwisko ASC, imie ASC;

--AN_45 [5 pkt]
--Znajd� nazw� podkategorii (jednej lub kilku), w kt�rej znajduj� si� produkty
--wyprodukowane przez najwi�ksz� liczb� r�nych producent�w.
--Prosz� nie u�ywa� konstrukcji TOP 1 WITH TIES.
--Rozwi�zanie:

SELECT podkategoria.nazwa, COUNT(produkt.id_produkt) AS Ile
FROM podkategoria
JOIN produkt ON podkategoria.id_podkategoria = produkt.id_podkategoria 
JOIN producent ON produkt.id_producent = producent.id_producent
GROUP BY podkategoria.id_podkategoria, podkategoria.nazwa
HAVING COUNT(produkt.id_producent) =
(
	SELECT TOP 1 COUNT(produkt.id_producent) AS ilosc_prodocentow, produkt.nazwa
	FROM produkt
	GROUP BY produkt.id_producent, produkt.nazwa
	ORDER BY ilosc_prodocentow ASC
)
ORDER BY podkategoria.nazwa ASC;