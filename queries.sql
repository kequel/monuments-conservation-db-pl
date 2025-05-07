/*
Planista chce znaleŸæ najbardziej doœwiadczonych konserwatorów do konserwacji zabytkowego œredniowiecznego koœcio³a, planuje skontaktowaæ siê z nimi mailowo.
ZnajdŸ wszystkich konserwatorów ze specjalizacj¹ "Sztuka œredniowieczna" i nazw¹ oraz adresem mailowym firmy, którzy wykonali co najmniej 2 konserwacje w ci¹gu ostatniego roku
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
WHERE s.nazwa = 'Sztuka œredniowieczna'
ORDER BY liczba_konserwacji DESC, f.nazwa, k.nazwisko;


/*
Ksiêgowy przygotowuje raport o efektywnoœci czasowej konserwacji.
Dla ka¿dej konserwacji zakoñczonej w 2024 roku poka¿ ró¿nicê miêdzy planowan¹ a rzeczywist¹ dat¹ zakoñczenia, wraz z nazw¹ zabytku i kosztem konserwacji.
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
Planista planuje co w nastêpnej kolejnoœci powinno zostaæ naprawiane. Chce sprawdziæ, które zabytki s¹ w z³ym stanie i najbardziej wymagaj¹ renowacji.
ZnajdŸ wszystkie zabytki o stanie technicznym poni¿ej 4.
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
Zarz¹d przygotowuje podsumowanie kosztów kozystania z us³ug danych firm konserwatorskich. Ksiêgowy chce zobaczyæ œrednie koszty konserwacji realizowane przez ka¿d¹ firmê konserwatorsk¹.
Wyœwietl œredni koszt us³ug ka¿dej z firm konserwatorskich.
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
Kierownik chce sprawdziæ, które zlecenia konserwacji przekroczy³y planowany termin zakoñczenia. Planuje zadzwoniæ do firm, które sie opóŸni³y, by wnioskowaæ o zni¿ke na cenie.
Wyœwietl wszystkie konserwacje, które by³y opóŸnione wraz z odpowiedzialn¹ firm¹ i nr. telefonu do niej.
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
Nowa firma konserwatorska chce wejœæ na rynek konserwacji zabytków. Chcieliby wiedzieæ jakie s¹ najrzadziej posiadane specjalizacje przez konserwatorów.
Wyœwietl specjalizacje rosnaco w kwestii liczb posiadanych j¹ konserwatorów.
*/
SELECT s.nazwa AS specjalizacja, 
       COUNT(DISTINCT k.id) AS liczba_konserwatorow
FROM Specjalizacja s
LEFT JOIN Konserwator_Specjalizacja ks ON s.id = ks.specjalizacja_id
LEFT JOIN Konserwator k ON ks.konserwator_id = k.id
GROUP BY s.nazwa
ORDER BY liczba_konserwatorow ASC, s.nazwa;

/*
W³adze chc¹ porównaæ koszt konserwacji zabytków miêdzy miastami, aby dowiedzieæ siê w które okolice w 2024 roku posz³o najwiêcej kosztów.
Wyœwietl wszystkie miasta i calkowity koszt wszytskich konserwacji w nich w 2024 roku.
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
Kierownik konserwacji analizuje skutecznoœæ firm konserwatorskich, planuje przyznaæ premiê dla tych najlepiej wywi¹zujacych siê ze swoich obowi¹zków.
ZnajdŸ firmy konserwatorskie, których konserwatorzy nigdy nie przekroczyli planowanego terminu zakoñczenia prac w ostatnich 2 latach, wraz z liczb¹ wykonanych przez nich konserwacji
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
