SELECT * FROM pracownik

SELECT imie, nazwisko, dzial 
FROM pracownik

SELECT imie, nazwisko, pensja 
FROM pracownik
ORDER BY  pensja DESC

SELECT nazwisko, imie
FROM pracownik
ORDER BY nazwisko DESC, imie DESC

SELECT nazwisko, dzial, stanowisko 
FROM pracownik
ORDER BY dzial ASC, stanowisko DESC

SELECT DISTINCT * FROM pracownik

SELECT DISTINCT dzial,stanowisko
FROM pracownik
ORDER BY dzial DESC, stanowisko DESC

SELECT imie, nazwisko 
FROM pracownik
WHERE imie='Jan';