---
name: terraform-module
description: >-
  Twórz i rozwijaj moduły Terraform w terraform-example/modules zgodnie z kontraktami tego repozytorium: pełne argumenty zasobów, typowane obiekty i mapy, jawne nazwy, osobne wejścia kontekstu i bezpieczne testy. Konfigurację env obsługuje skill terragrunt-structure.
---

# Moduły Terraform

Ten skill jest lokalną częścią repozytorium. Nie instaluj go w Codex ani nie
kopiuj do katalogu domowego lub innych repozytoriów. Przeczytaj instrukcje
repozytorium, stan Git, istniejące wejścia/wyjścia oraz wywołania zmienianego modułu.
Dla konfiguracji środowiska używaj [terragrunt-structure](../terragrunt-structure/SKILL.md).

## Labels i Resource Manager Tags

Kontrakt plików kontekstowych, namespace tagów i ich przekazywanie opisuje
[terragrunt-structure](../terragrunt-structure/SKILL.md#labels-i-resource-manager-tags).
Nie twórz pomocniczego modułu tags ani jednostki zarządzającej katalogiem tagów.
Moduły przyjmują params.resource_manager_tags jawnie na danym zasobie; nie
zamieniają automatycznie environment ani default_labels w tagi GCP.
Provider otrzymuje default_labels. Bezpośrednie labels zasobu mogą je nadpisać;
przy regionalnym override trzeba przekazać właściwe oznaczenie regionu.
Sprawdzaj wsparcie w schemacie konkretnego zasobu. Obecnie network, subnetwork
oraz router mają resource_manager_tags, ale nie labels. HA VPN gateway i tunnel
mają oba mechanizmy; interfejsy routera i peery BGP nie mają żadnego z nich.
Nie dodawaj nieobsługiwanych pól. Zwykłe network tags VM nie są zamiennikiem.

## Nazwy zasobów w chmurze

Nazwy nadawane zasobom muszą być krótkie i opisowe, np. `atlas`, `orion`,
`application`, `to-orion-primary`. Nie umieszczaj w nich typu zasobu ani skrótów
tego typu: `vpn`, `vpc`, `network`, `subnet`, `router`, `gateway`, `interface`, `peer`.
Nie umieszczaj w nazwach środowiska, projektu, regionu ani strefy; nie doklejaj
prefiksów ani sufiksów z tych wartości. Kontekst przekazuj osobnymi argumentami.
Reguła obejmuje konfigurację env, przykłady i nazwy zasobów w danych testowych.
Nazwy pól API, typy resource, nazwy modułów i katalogi określające ich funkcję
pozostają techniczne, np. `network`, `vpn-ha`, `subnetworks`.
Moduł przyjmuje jawne `name` bez modyfikacji i nie narzuca tej konwencji walidacją
odrzucającą poprawne nazwy istniejących zasobów użytkownika.
Sprawdzaj unikalność w zakresie wymaganym przez GCP: dwie VPC w tym samym
projekcie muszą mieć różne nazwy, np. `atlas` i `orion`. Nie rozwiązuj kolizji
przez dopisywanie regionu lub typu zasobu. Zachowuj stabilne klucze map i stan.

## Sposób tworzenia i rozszerzania

Najpierw wybierz odpowiedzialność modułu i sprawdź istniejący kontrakt. Rozbudowa
argumentów nie może zmieniać liczby zasobów głównych ani dokładać tworzenia ich
zależności. W szczególności dodatkowe opcje routera nie uzasadniają mapy routerów,
a obsługa kolejnego połączenia nie uzasadnia mapy bram w vpn-ha.
Nowe pola prowadź przez typ wejścia, przypisanie w resource i odpowiedni przykład
lub test zachowania. Nie wystarczy zadeklarować zmiennej bez jej użycia.
Jeżeli zmieniasz publiczny kontrakt, w tej samej zmianie popraw wszystkie wywołania,
przykłady, testy oraz oba skille; usuń sprzeczne instrukcje zamiast je dopisywać.

## Granice odpowiedzialności

Moduły znajdują się w `modules/<funkcja>`. Nazwa opisuje funkcję bez prefiksu
providera, np. `google_compute_network` → `network`.

Aktualne granice, których nie należy mieszać:

| Moduł | Zasoby i zachowanie |
|---|---|
| `network` | Jedna VPC oraz mapa subnetów; bez VM, VPN, routerów, NAT i firewalli |
| `router` | Dokładnie jeden Cloud Router, wymagany obiekt router; bez interfejsów i peerów |
| `vpn-ha` | Dokładnie jedna brama HA VPN, wymagany obiekt gateway; bez tuneli |
| `router-connection` | Mapy interfejsów i peerów jednego istniejącego routera; router jako nazwa, bez tworzenia routera |
| `vpn-tunnel` | Mapa tuneli między istniejącymi bramami; bez tworzenia bram i routerów |

Network, router i brama VPN są atomowe: jeden zasób główny na wywołanie modułu.
Nie stosuj do nich map, count, for_each ani opcjonalnego trybu tworzenia zera zasobów.
Resource ma adres this, a output jest pojedynczym obiektem network/router/gateway.
Wiele zasobów głównych realizuj przez osobne katalogi Terragrunt
network/<nazwa-jednostki>/, router/<nazwa-jednostki>/ i vpn-gateway/<nazwa-jednostki>/.
Mapy pozostają dla subnetów, tuneli, interfejsów, peerów i bloków podrzędnych.
Konfiguracja interfejsów/BGP jest osobna, ponieważ zależy od istniejących tuneli;
nie dodawaj jej do tworzenia routera, tworząc cykl router → tunel → router.
Nie dodawaj backendu ani konfiguracji środowiska do modułów.

| Moduł | Wejście zasobu | Output zasobu |
|---|---|---|
| network | network: object, subnetworks: map(object) | network: object, subnetworks: map(object) |
| router | router: object | router: object |
| vpn-ha | gateway: object | gateway: object |
| router-connection | router: string, interfaces i peers: map(object) | interfaces i peers: map(object) |
| vpn-tunnel | tunnels: map(object), osobne mapy PSK | tunnels: map(object) |

Dla atomowych wejść nie stosuj default = {} lub null; wymagaj obiektu z nazwą.
Opcjonalne bloki wewnątrz zasobu nie zmieniają atomowości samego zasobu.

## Argumenty i typowanie

Dla nowego modułu sprawdź aktualną stabilną wersję providera w oficjalnym Registry,
a następnie jego schemat i dokumentację. Obecne moduły przypinają Google 8.10.0;
nie aktualizuj ich przy okazji innego zadania. Odczyt `terraform providers schema
-json` jest technicznym formatem narzędzia, a nie formatem pisanej konfiguracji.

Uwzględnij wszystkie konfigurowalne argumenty i bloki zagnieżdżone zasobów w zakresie
modułu. Każdy z nich musi być wejściem, udokumentowanym powiązaniem wewnętrznym
lub uzasadnionym wyłączeniem, np. argument Classic VPN w module HA. Nie deklaruj
obsługi brakującej w providerze. Nie obchodź braków przez provisionery/CLI.

Computed-only nie jest wejściem. Optional+computed może być konfigurowalne.
Sprawdzaj walidację providera: syntetyczne główne `id` bywa opisane przez SDK jako
optional, ale nie wolno go ustawiać. Nie usuwaj mechanicznie każdego pola `id`:
np. `vpn_interfaces.id` wewnątrz HA gateway jest prawidłowym argumentem.

- `environment`, `project`, `region` są osobnymi wejściami. `environment` jest
  kontekstem, nie automatycznym prefiksem nazwy. W GCP `project` jest wymagany,
  `region` może mieć null jako domyślną wartość.
- Pozostałe opcje providera również są osobnymi zmiennymi. Nie opakowuj kontekstu
  w dodatkowy obiekt konfiguracji. Provider odczytuje np. `var.project`.
- Jeden zasób: `object({...})`; kolekcja zasobów: `map(object({...}))`, zwykle
  `default = {}` i `nullable = false`. Bez `any` i bez rozbijania zasobu na setki
  luźnych scalarów. Kontekst providera jest świadomym wyjątkiem od grupowania.
- Zachowaj wymagane pola. Stosuj `optional`; `default` określa wartość całego
  wejścia, a `optional(typ, wartość)` domyślną wartość pola. Nie gub false, 0 ani
  pustych kolekcji. Nie wymyślaj defaultów zmieniających znaczenie konfiguracji.
- Waliduj sensowne ograniczenia, wybory wzajemnie wykluczające się i klucze
  odwołań. Nie odrzucaj poprawnych zaawansowanych trybów GCP.

## Pliki i nazwy

| Plik | Zawartość |
|---|---|
| `versions.tf` | Blok `terraform`: `required_version` oraz `required_providers` z source i wersjami |
| `provider.tf` | Wyłącznie bloki `provider`, bez `terraform` i wymagań wersji |
| `v-provider.tf` | Osobne, typowane wejścia providera, np. project, region, impersonacja |
| `v-environment.tf` | Wejście environment, bez automatycznej zmiany nazw |
| `v-<zasób>.tf` | Typowany obiekt/mapa danego zasobu i jego walidacje |
| `r-<zasób>.tf` | Resource, argumenty i dynamiczne bloki danego rodzaju |
| `locals-naming.tf` | Wyłącznie nazwy podane przez użytkownika |
| `locals.tf` / `locals-<temat>.tf` | Potrzebne wyliczenia, normalizacja i rozwiązywanie powiązań |
| `outputs.tf` | Jawne wyniki, dla kolekcji mapy zachowujące klucze wejść |

Nazwy plików są małymi literami: `r-network.tf`, `v-subnetwork.tf`,
`r-proxy-https.tf`, `v-proxy-https.tf`. Nie twórz `l-*` ani pustych locals.
Para r-<zasób>.tf i v-<zasób>.tf ma ten sam człon nazwy: np.
r-ha-vpn-gateway.tf i v-ha-vpn-gateway.tf. Zmienne wspólnego kontekstu są wyjątkiem.
W locals-naming.tf tylko przekaż jawne name; nie mieszaj tam tagów, adresacji,
wyboru projektu/regionu ani generowania nazw.
Blok resource nazywaj `this`; rozróżniane funkcje mogą mieć nazwy `proxy_http`,
`proxy_https`. Każdy tworzony zasób otrzymuje jawne `name` od użytkownika.
Nie dodawaj prefiksów/sufiksów, numerów ani nazwy wyliczonej z klucza mapy.

## Kolekcje, powiązania i stan

Subnety i inne wielokrotne zasoby iteruj przez `for_each` ze stabilnymi kluczami.
Nie używaj count, indeksów list ani map zbudowanych po indeksach. Klucz jest
adresem Terraform; `name` jest osobną nazwą w chmurze. Zmiana kolejności albo
innego wpisu nie może renumerować istniejących instancji. Zmianę klucza obsłuż
przez jawne moved, jeśli zasób ma zostać zachowany.

Dla map zawierających sekrety można iterować po `nonsensitive(toset(keys(...)))`
i odczytywać wartości przez klucz. Odtajniane mogą być tylko publiczne klucze,
nie wartości sekretów. Klucze muszą być znane przed apply. Listy pozostaw dla
wartości/protokołów i bloków, których kolejność ma znaczenie. Mapa nie usuwa
wymiany wymuszonej zmianą niezmiennego argumentu providera.

Domyślnie wiąż zasoby deklaratywnie, np. subnet → self_link utworzonej VPC.
Zachowaj jawne nadpisania i udokumentuj pierwszeństwo. Moduł router-connection
przyjmuje jedną nazwę routera; peer wybiera interface_key z lokalnej mapy albo
interface jako istniejącą nazwę, nigdy oba. Moduł vpn-tunnel przyjmuje referencje
vpn_gateway i peer_gcp_gateway albo peer_external_gateway, bez gateway_key.
Nie konstruuj URL-i zamiast referencji do zarządzanych zasobów.

## Format i sekrety

Cała konfiguracja jest natywnym HCL (`=`), nie JSON-em ani `.tf.json`.
Dwie spacje wcięcia. Puste linie oddzielają elementy najwyższego poziomu.
Każdy niepusty obiekt/mapę rozwijaj na wiele linii, także w for, testach i przykładach.
Nie umieszczaj zagnieżdżonego przypisania po otwierającej klamrze ani kilku klamer
zamykających w jednej linii. Puste `{}` mogą zostać zwarte. Sam fmt nie wymusza
wszystkich tych zasad — przejrzyj wynik.

Dobierz sposób przekazywania sekretu do kontraktu zasobu:
- PSK tuneli przekazuj osobnymi mapami sensitive, wybieranymi przez secret_key;
  nie umieszczaj ich w obiektach definiujących topologię tuneli.
- Pola uwierzytelniania należące do zagnieżdżonego bloku zasobu, np. klucze MD5
  routera/peera, mogą pozostać w typowanym obiekcie tego bloku. Zachowaj ich
  wrażliwość, a przy przekazaniu do zasobu użyj sensitive, jeśli schema providera
  nie oznacza pola jako wrażliwego. Nie wymuszaj przebudowy takiego kontraktu na
  osobną mapę tylko dla ujednolicenia go z PSK.

Sekrety nigdy nie są kluczami iteracji, nazwami zasobów ani wartościami outputów.
Nie odtajniaj całego obiektu w celu użycia for_each — tylko jego publiczne klucze.
Sprawdź testem, że wrażliwe wejście nie blokuje iteracji ani nie trafia do wyjść.
Sensitive ukrywa prezentację wartości, lecz samo w sobie nie usuwa jej ze stanu.
Dla obsługiwanych write-only argumentów można używać wejść ephemeral i wersji
rotacji; uwzględnij wtedy wymaganie Terraform >= 1.11. Opisz przechowywanie sekretów
w stanie dla standardowych argumentów, w tym PSK i MD5. Nie zapisuj prawdziwych
sekretów w repozytorium.

## Przykłady, testy i zakończenie

Zachowaj istniejące przykłady. Potrzebny nowy przykład rozdziela wywołanie przez
var.* w main.tf, typy w variables.tf i wartości w terraform.tfvars.example.
Nie dodawaj demonstracyjnych środowisk ani podłączenia do env poza zakresem zadania.
Nie twórz README.md; dokumentację konwencji utrzymuj w lokalnych skillach AI/.

Uruchom fmt, init z wyłączonym backendem, validate i testy zachowania na mockach:
minimalny wymagany obiekt dla modułu atomowego, pusta mapa dla kolekcji, powiązania i nadpisania, opcjonalne bloki, błędne wejścia,
zachowanie ID po dodaniu/usunięciu innego klucza. Nie używaj realnego apply jako testu.
Po testach wykonaj osobną kontrolę kompletności dla każdego rodzaju zasobu.
Porównaj aktualny schemat przypiętej wersji providera z typami wejść i przypisaniami
w resource, rekurencyjnie przez wszystkie bloki zagnieżdżone. Dla każdej ścieżki
konfigurowalnego argumentu wskaż wejście i miejsce przekazania wartości, jawne
powiązanie wewnętrzne albo udokumentowany powód wyłączenia. Sprawdź także
optional+computed oraz szczególne przypadki pól id opisane wyżej. Brak przypisania
lub nieuzasadnione pominięcie oznacza nieukończony moduł. Samo wystąpienie nazwy
pola w pliku nie wystarcza — musi być poprawnie podłączone we właściwym bloku.
W podsumowaniu podaj wersję sprawdzonego schematu i ewentualne wyłączenia.
Fmt, validate i testy wybranych scenariuszy nie zastępują tej kontroli: mogą
przejść mimo pominięcia opcjonalnej funkcji.

Provider jest konfigurowany wewnątrz modułu; module call nie może więc używać
count/for_each/depends_on. Root mock nie musi zastąpić providera zagnieżdżonego.
W kopiach testowych pomiń provider.tf, ale zachowaj versions.tf. Wykrywaj
pozostawione bloki provider również na początku pliku. Przy zmianie podziału modułów
aktualizuj listę modułów i ścieżki w tym teście; nie pozostawiaj starego testu,
który omija nowo wydzielony moduł.
Przy testach złożenia użyj izolowanych kopii bez konfiguracji providerów, przekaż
mock jawnie i zablokuj prawdziwe API/poświadczenia. Wzorem jest
`modules/vpn-ha/tests/verify_composition.py`.

Przy zmianie kontraktu zaktualizuj wywołania w env, przykłady, testy i dokumentację.
Nie zmieniaj przy tym nazw zasobów, kluczy map lub stanów bez potrzeby. Raportuj
wykonane kontrole i ograniczenia: mocki nie dowodzą zestawienia VPN ani dostępu
sieciowego. Pisanie modułu nie upoważnia do wdrożenia infrastruktury.

Przy migracji starych jednostek main zachowaj klucze backendu i moved z
this["main"] do this dla routera/bramy. Inne historyczne klucze wymagają osobnej
migracji; nie zakładaj, że moved dla main obsługuje całą dawną mapę.
