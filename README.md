# tim-15

## Članovi tima

| Ime i prezime | Broj indeksa | GitHub nalog |
|---|---|---|
| Lav Andrić | 61/24 SI | landric04 |
| Anja Varga | 88/24 SI | avarga04 |

## Opis sistema

Scoreboard Management System je multiplatformski softverski sistem koji omogućava korisnicima da pretražuju igrice, pregledaju liderboarde za izabranu igricu i, ukoliko žele, prijave se i dodaju sebe na odgovarajući liderboard. Administratori imaju posebna ovlašćenja za upravljanje korisnicima — mogu da dodaju, uklanjaju i menjaju korisničke naloge i njihove rezultate.

Sistem se sastoji od četiri dela koji dele isti domenski kod napisan u Dartu: mobilna aplikacija za korisnike, backoffice aplikacija za administratore, server koji čuva podatke i sprovodi pravila, i javni veb sajt koji prikazuje sadržaj dostupan pretraživačima.

## Zahtevi

### Uloge

Sistem ima najmanje dve uloge sa različitim ovlašćenjima: korisnik (gost) i administrator. Korisnik može da pretražuje igrice, pregleda liderboarde i prijavi sebe na liderboard, dok administrator može da upravlja korisnicima (dodaje, uklanja, menja naloge) i kontroliše sadržaj liderboarda.

### Stanja

Glavni pojam sistema — prijava na liderboard — prolazi kroz najmanje četiri stanja: na čekanju (korisnik je poslao prijavu), odobrena (administrator je potvrdio prijavu), odbijena (administrator je odbio prijavu) i arhivirana (prijava je završena ili povučena).

### Pravila

Korisnik može imati samo jedan upis na istom liderboardu, a svoj postojeći rezultat može ažurirati bez kreiranja duplog upisa. Svaki rezultat mora biti u dozvoljenom opsegu za datu igricu i validira se na serveru. Administrator može da deaktivira korisnika, pri čemu se njegovi prethodni rezultati i istorija prijava čuvaju. Administrator može da odobri ili odbije samo prijave koje su na čekanju. Ukoliko je liderboard ograničen na određeni broj učesnika, novi rezultat mora biti dovoljno dobar da se plasira među dozvoljeni broj najboljih rezultata, u suprotnom, upis se odbija.

### Rad bez mreže

Korisnik može da povuče svoju prijavu sa liderboarda ili da sačuva izmenu svog rezultata dok je offline; izmena se čuva lokalno i sinhronizuje sa serverom kada se veza ponovo uspostavi.

### Posao za osoblje

Administratori rade sa većim brojem zapisa, što zahteva veći ekran. Backoffice aplikacija omogućava pregled svih korisnika, svih igrica i svih prijava na liderboardima, sa mogućnošću filtriranja, pretrage i masovnih izmena — sve to u interfejsu prilagođenom desktop ekranima.

### Javni sadržaj

Deo podataka dostupan je svima, bez prijave, i ima smisla za pretraživače. Javni veb sajt prikazuje listu igrica, liderboarde i osnovne statistike (npr. top 10 igrača za svaku igricu), što omogućava pretraživačima da indeksiraju sadržaj i korisnicima da ga pronađu bez registracije.

## Tehnologije

- **Dart** — domenski kod koji dele sva četiri dela sistema
- **Flutter** — mobilna aplikacija i backoffice aplikacija
- **Server** — čuva podatke i proverava pravila
- **Javni veb** — prikazuje sadržaj dostupan pretraživačima
