---
name: terragrunt-structure
description: Twórz i rozwijaj konfiguracje środowisk Terragrunt w terraform-example/env, korzystając z lokalnych modułów, jawnych zależności i spójnego formatowania HCL. Nie służy do implementowania zasobów wewnątrz modułów Terraform.
---

# Konfiguracje Terragrunt

Skill należy wyłącznie do `terraform-example/AI/`. Nie instaluj go w Codex ani
w katalogu domowym. Przed zmianami odczytaj istniejącą strukturę, instrukcje
repozytorium, kontrakty wykorzystywanych modułów i stan Git. Zachowaj niezwiązane
zmiany. Implementację samych modułów opisuje
[terraform-module](../terraform-module/SKILL.md).

## Struktura i odpowiedzialność

- `root.hcl` w root repozytorium: współdzielona konfiguracja stanu i ustawienia
  rzeczywiście wspólne dla środowisk. Nie kopiuj jej do każdej jednostki.
- `modules/<funkcja>/`: moduły Terraform. W Terragrunt wskazuj lokalny moduł przez
  `${get_repo_root()}//modules/<funkcja>`; nie powielaj resource w konfiguracji env.
- `env/<środowisko>/environment.hcl`: kontekst środowiska.
- `env/<środowisko>/<projekt>/project.hcl`: kontekst projektu.
- `env/<środowisko>/<projekt>/<region>/region.hcl`: kontekst regionu.
- `env/<środowisko>/<projekt>/<region>/<jednostka>/terragrunt.hcl`: wejścia,
  źródło modułu oraz zależności konkretnej jednostki.

Dostosuj liczbę jednostek do zakresu i granic własności stanu. Nie twórz dodatkowych
katalogów lub modułów tylko dla kolejnych kroków instrukcji. Jeżeli kolejność
API rzeczywiście wymaga rozdzielenia tworzenia zasobu i konfiguracji powiązań,
wyjaśnij ten podział i zapewnij, że tylko jedna jednostka zarządza danym zasobem.
Nie twórz cykli zależności ani dwóch stanów zarządzających tym samym obiektem.
Nie przebudowuj istniejącego układu przy okazji samego formatowania.

## Obowiązkowe formatowanie

Używaj natywnego HCL: przypisania przez `=`, obiekty i mapy zamiast JSON-owych
właściwości z `:`. Wcięcie to dwie spacje, układ wewnątrz bloków formatuje
`terragrunt hcl fmt`.

**Pomiędzy każdymi dwoma elementami najwyższego poziomu zawsze pozostaw jedną
pustą linię.** Dotyczy to zarówno bloków, jak i zwykłych przypisań: `include`,
`terraform_binary`, `locals`, `terraform`, każdego `dependency`, `dependencies`,
`inputs`, `remote_state`, `generate` itd. Po zamykającym `}` nie zaczynaj kolejnego
bloku bez pustej linii. Nie sklejaj `terraform_binary` z sąsiednimi blokami.
Reguła dotyczy wszystkich plików konfiguracyjnych `.hcl`, nie tylko `root.hcl`.
Komentarz należy do opisywanego elementu; pustą linię wstaw przed komentarzem.

Zachowuj czytelne grupy w `locals`. Rozbudowane obiekty i mapy zapisuj wieloliniowo;
nie ściskaj całej konfiguracji w jednej linii. Nie zmieniaj kolejności kolekcji,
której semantyka zależy od kolejności.

Przykład układu:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  project = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  project = local.project.inputs.project
  region  = local.region.inputs.region

  network = {
    name = "example-vpc"
  }
}
```


Niepuste obiekty i mapy zapisuj zawsze wieloliniowo. Po otwierającej klamrze
zaczynaj zawartość w nowej linii; każda para klamer ma własny poziom wcięcia.
Nie używaj formy `gateways = { main = { ... } }` ani dwóch klamer zamykających
w jednej linii. Tak samo formatuj obiekty w wyrażeniach for, testach i przykładach.
Puste `{}` mogą pozostać w jednej linii. Zwykły fmt nie zastępuje tej reguły.

## Dane i kontrakty modułów

Odczytuj projekt i region z najbliższych plików kontekstowych. Wspólne dane jednej
konfiguracji, np. obu końców VPN, trzymaj w jednym tematycznym pliku `.hcl`, jeśli
eliminuje to rzeczywiste duplikowanie. Nie przenoś tam niepowiązanych ustawień.
Przekazuj tylko wejścia, które przyjmuje moduł. Projekt i region przekazuj bezpośrednio, np. `project = local.project.inputs.project`
i `region = local.region.inputs.region`. Nie buduj zbiorczego obiektu konfiguracji
providera w locals ani inputs. Nie wstawiaj nieużywanego kontekstu
ani locals bez potrzeby. Definicje i wersje providerów pozostają w module, jeśli
taki jest jego kontrakt; nie generuj drugiego konkurencyjnego providera.

Wiele zasobów przekazuj jako mapę obiektów z trwałymi, znaczącymi kluczami.
Nie identyfikuj zasobów po pozycji w liście. Nazwy zasobów są jawnie określone
w konfiguracji środowiska i niezależne od kluczy mapy. Zachowuj wartości false,
zero i świadomie puste kolekcje oraz semantykę optional/default modułu.

## Zależności i stan

Do przekazania danych z innej jednostki używaj `dependency` i rzeczywistych
`dependency.<nazwa>.outputs`. Nie zastępuj outputów skonstruowanymi na sztywno ID.
Ścieżki zależności muszą prowadzić do istniejących jednostek, a graf musi być
acykliczny. Zweryfikuj obie strony połączenia: regiony, adresy, ASN i kierunki
odwołań, jeśli mają znaczenie dla zadania.

W konfiguracji `env/` nie dodawaj `mock_outputs`, `skip_outputs` ani zastępczych
linków/ID. Każde odwołanie do zasobu innej jednostki pobieraj z jej rzeczywistych
outputów przez `dependency`. Używaj `.self_link` tam, gdzie wymagany jest link;
gdy argument providera wymaga nazwy, używaj `.name` z outputu zależności.
Nie składaj adresów `googleapis.com` z nazw projektu, regionu i zasobu.

Jeśli poprzednia jednostka nie została wdrożona i nie ma outputów, nie maskuj
tego fikcyjnymi danymi. Sprawdź statycznie składnię i ścieżki zależności oraz
wyjaśnij, że pełny render/plan wymaga rzeczywistych outputów. Izolowane testy
modułów nie są konfiguracją środowiska i pozostają poza `env/`.

Utrzymuj unikalny prefix stanu dla każdej jednostki. Przeniesienie istniejącego
katalogu może zmienić `path_relative_to_include()` i adres stanu; uwzględnij to
przed zmianą układu. Nie usuwaj ani nie migruj stanu w ramach przygotowania kodu.

## Sekrety i sprawdzenie wyniku

PSK, hasła i tokeny nie należą do śledzonych plików. Używaj ignorowanych plików
zmiennych albo istniejącego mechanizmu sekretów. Jeśli jednostki muszą użyć tego
samego sekretu, wskaż im wspólne źródło. Przykłady zawierają wyłącznie jawnie
opisane placeholdery. Nie drukuj wyrenderowanych sekretów podczas kontroli.

Po zmianach uruchom formatowanie i sprawdź osobno obowiązkowe puste linie:
`terragrunt hcl fmt` nie musi ich sam dodać. Wykonaj `terragrunt hcl validate`,
a w przypadku zmian logicznych także bezpieczny render i kontrolę grafu zależności.
Walidacja nie może przypadkiem inicjalizować prawdziwego backendu lub używać
prawdziwych poświadczeń do testowego apply. Przy zmianie wyłącznie odstępów
porównaj treść bez białych znaków, żeby potwierdzić brak zmian konfiguracji.
Przejrzyj diff, zakres plików i reguły ignorowania sekretów.

Przygotowanie konfiguracji nie oznacza wdrożenia. Nie uruchamiaj rzeczywistego
plan/apply/destroy ani nie twórz zasobów bez odpowiedniego polecenia użytkownika.
W podsumowaniu podaj przygotowane ścieżki, wykonane kontrole i dane nadal
wymagane do późniejszego wdrożenia.
