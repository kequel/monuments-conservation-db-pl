/*
Planista chce znale�� najbardziej do�wiadczonych konserwator�w do konserwacji zabytkowego �redniowiecznego ko�cio�a, planuje skontaktowa� si� z nimi mailowo.
Znajd� wszystkich konserwator�w ze specjalizacj� "Sztuka �redniowieczna" i nazw� oraz adresem mailowym firmy, kt�rzy wykonali co najmniej 2 konserwacje w ci�gu ostatniego roku
*/
SELECT k.imie, 
       k.nazwisko, 
       f.nazwa AS firma, 
       f.adres_email AS adres_email,
       liczba_konserwacji
FROM Konserwator k
JOIN Firma_Konserwatorska f ON k.zatrudnia = f.id
JOIN Konserwator_Specjalizacja ks ON k.id = ks.konserwator_id
JOIN Specjalizacja s ON ks.specjalizacja_id = s.id
JOIN (
    SELECT z.wykonuje_konserwacje AS konserwator_id, 
           COUNT(*) AS liczba_konserwacji
    FROM Zlecenie_Konserwacji z
    JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
    WHERE c.data_zakonczenia >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY z.wykonuje_konserwacje
    HAVING COUNT(*) >= 2
) liczby ON k.id = liczby.konserwator_id
WHERE s.nazwa = 'Sztuka �redniowieczna'
ORDER BY liczba_konserwacji DESC, f.nazwa, k.nazwisko;


/*
Ksi�gowy przygotowuje raport o efektywno�ci czasowej konserwacji.
Dla ka�dej konserwacji zako�czonej w 2024 roku poka� r�nic� mi�dzy planowan� a rzeczywist� dat� zako�czenia, wraz z nazw� zabytku i kosztem konserwacji.
*/
SELECT z.id AS zlecenie_id, 
	   zab.nazwa AS zabytek, 
       DATEDIFF(DAY, z.planowana_data_zakonczenia, c.data_zakonczenia) AS roznica_dni,
       c.koszt
FROM Zlecenie_Konserwacji z
JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
JOIN Zabytek zab ON z.zlecono = zab.id
WHERE YEAR(c.data_zakonczenia) = 2024
ORDER BY roznica_dni DESC;

/*
Planista planuje co w nast�pnej kolejno�ci powinno zosta� naprawiane. Chce sprawdzi�, kt�re zabytki s� w z�ym stanie i najbardziej wymagaj� renowacji.
Znajd� wszystkie zabytki o stanie technicznym poni�ej 4.
*/
SELECT zab.nazwa AS zabytek,
       p.stan_zabytku, 
       m.nazwa AS miasto,
       o.imie AS imie_opiekuna,
       o.nazwisko AS nazwisko_opiekuna,
       o.numer_telefonu AS kontakt_do_opiekuna
FROM Przeglad_Techniczny p
JOIN Zabytek zab ON p.dotyczy = zab.id
JOIN Miasto m ON zab.znajduje_sie_w = m.id
JOIN Opiekun o ON zab.opiekuje_sie = o.id
WHERE p.stan_zabytku < 4
ORDER BY p.stan_zabytku ASC;


/*
Zarz�d przygotowuje podsumowanie koszt�w kozystania z us�ug danych firm konserwatorskich. Ksi�gowy chce zobaczy� �rednie koszty konserwacji realizowane przez ka�d� firm� konserwatorsk�.
Wy�wietl �redni koszt us�ug ka�dej z firm konserwatorskich.
*/
CREATE VIEW SrednieKoszty AS
SELECT f.nazwa AS firma,
	   AVG(c.koszt) AS sredni_koszt
FROM Firma_Konserwatorska f
JOIN Konserwator k ON f.id = k.zatrudnia
JOIN Zlecenie_Konserwacji z ON k.id = z.wykonuje_konserwacje
JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
GROUP BY f.nazwa;

SELECT firma, 
	   sredni_koszt
FROM SrednieKoszty
ORDER BY sredni_koszt DESC;


/*
Kierownik chce sprawdzi�, kt�re zlecenia konserwacji przekroczy�y planowany termin zako�czenia. Planuje zadzwoni� do firm, kt�re sie op�ni�y, by wnioskowa� o zni�ke na cenie.
Wy�wietl wszystkie konserwacje, kt�re by�y op�nione wraz z odpowiedzialn� firm� i nr. telefonu do niej.
*/
SELECT z.id AS zlecenie_id, 
       zab.nazwa AS zabytek, 
       z.planowana_data_zakonczenia, 
       c.data_zakonczenia,
       f.nazwa AS firma_konserwatorska,
       f.numer_telefonu AS numer_telefonu
FROM Zlecenie_Konserwacji z
JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
JOIN Zabytek zab ON z.zlecono = zab.id
JOIN Konserwator k ON z.wykonuje_konserwacje = k.id
JOIN Firma_Konserwatorska f ON k.zatrudnia = f.id
WHERE c.data_zakonczenia > z.planowana_data_zakonczenia;


/*
Nowa firma konserwatorska chce wej�� na rynek konserwacji zabytk�w. Chcieliby wiedzie� jakie s� najrzadziej posiadane specjalizacje przez konserwator�w.
Wy�wietl specjalizacje rosnaco w kwestii liczb posiadanych j� konserwator�w.
*/
SELECT s.nazwa AS specjalizacja, 
       COUNT(DISTINCT k.id) AS liczba_konserwatorow
FROM Specjalizacja s
LEFT JOIN Konserwator_Specjalizacja ks ON s.id = ks.specjalizacja_id
LEFT JOIN Konserwator k ON ks.konserwator_id = k.id
GROUP BY s.nazwa
ORDER BY liczba_konserwatorow ASC, s.nazwa;

/*
W�adze chc� por�wna� koszt konserwacji zabytk�w mi�dzy miastami, aby dowiedzie� si� w kt�re okolice w 2024 roku posz�o najwi�cej koszt�w.
Wy�wietl wszystkie miasta i calkowity koszt wszytskich konserwacji w nich w 2024 roku.
*/
SELECT m.nazwa AS miasto, 
       SUM(koszty.koszt) AS calkowity_koszt
FROM Miasto m
JOIN Zabytek zab ON m.id = zab.znajduje_sie_w
JOIN (
    SELECT z.zlecono AS zabytek_id, 
           c.koszt
    FROM Zlecenie_Konserwacji z
    JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
    WHERE YEAR(c.data_zakonczenia) = 2024
) koszty ON zab.id = koszty.zabytek_id
GROUP BY m.nazwa
ORDER BY calkowity_koszt DESC;


/*
Kierownik konserwacji analizuje skuteczno�� firm konserwatorskich, planuje przyzna� premi� dla tych najlepiej wywi�zujacych si� ze swoich obowi�zk�w.
Znajd� firmy konserwatorskie, kt�rych konserwatorzy nigdy nie przekroczyli planowanego terminu zako�czenia prac w ostatnich 2 latach, wraz z liczb� wykonanych przez nich konserwacji
*/
SELECT f.nazwa AS firma, 
	   COUNT(c.id) AS liczba_konserwacji
FROM Firma_Konserwatorska f
JOIN Konserwator k ON f.id = k.zatrudnia
JOIN Zlecenie_Konserwacji z ON k.id = z.wykonuje_konserwacje
JOIN Konserwacja c ON z.id = c.przypisane_zlecenie
WHERE c.data_zakonczenia <= z.planowana_data_zakonczenia
  AND c.data_zakonczenia >= DATEADD(YEAR, -2, GETDATE())
GROUP BY f.nazwa
ORDER BY liczba_konserwacji DESC;
