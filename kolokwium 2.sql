--Imiê i nazwisko:
--Data i godzina:
--Grupa laboratoryjna:
--Obowi¹zuj¹ca baza danych: sklep, http://fidytek.pl/bazy_danych/bd_skrypt_sql/sklep_mssql 

--Napisaæ instrukcje SQL (dla MS SQL Server) realizuj¹ce poni¿sze zadania.

--AN_41 [3 pkt]
--ZnajdŸ pracowników (id_pracownik, imie, nazwisko), którzy maj¹ pensjê (nie liczymy dodatku)
--wy¿sz¹ ni¿ 2600 z³ i pracuj¹ na stanowisku sprzedawcy.
--Wynik posortuj leksykograficznie po nazwisku i imieniu.
--Rozwi¹zanie:

SELECT id_pracownik, imie, nazwisko, stanowisko 
FROM pracownik 
WHERE pensja > 2600 AND stanowisko='sprzedawca'
ORDER BY nazwisko ASC, imie ASC; 


--AN_42 [4 pkt]
--Osobom, które s¹ klientami od co najmniej 4 (pe³nych) lat 
--zwiêksz dotychczasowy rabat o 5%.

--Rozwi¹zanie:

UPDATE klient 
SET rabat=rabat*1.05 
WHERE data_dodania BETWEEN '06-04-2012' AND GETDATE()

--AN_43 [4 pkt]
--Usuñ pracowników, którzy nie przyjêli ¿adnego zamówienia.
--Rozwi¹zanie:

SELECT * FROM pracownik
DELETE pracownik
FROM pracownik
JOIN zamowienie ON pracownik.id_pracownik=zamowienie.id_zamowienie
WHERE zamowienie.data_zamowienia IS NULL;

--AN_44 [4 pkt]
--Dla ka¿dego klienta (nazwisko i imie), wyœwietl informacjê ile z³o¿y³ on zamówieñ.
--Uwzglêdnij te¿ tych klientów, którzy nie z³o¿yli ¿adnego zamówienia.
--Wynik posortuj malej¹co po iloœci z³o¿ych zamówieñ, a dla takiej samej 
--iloœci zamówieñ leksykograficznie po nazwisku i imieniu.
--Uwaga: dwóch klientów mo¿e posiadaæ to samo imiê i nazwisko.
--Rozwi¹zanie:

SELECT k.imie, k.nazwisko , COUNT(z.id_klient) as Ile
FROM klient k 
LEFT JOIN zamowienie z ON k.id_klient=z.id_klient
GROUP BY k.nazwisko, k.imie, z.id_klient
ORDER BY Ile DESC, nazwisko ASC, imie ASC;

--AN_45 [5 pkt]
--ZnajdŸ nazwê podkategorii (jednej lub kilku), w której znajduj¹ siê produkty
--wyprodukowane przez najwiêksz¹ liczbê ró¿nych producentów.
--Proszê nie u¿ywaæ konstrukcji TOP 1 WITH TIES.
--Rozwi¹zanie:

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