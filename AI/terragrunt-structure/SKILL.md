---
name: terragrunt-structure
description: >-
  Twórz i aktualizuj konfiguracje Terragrunt w terraform-example/env: kontekst przez locals, bezpośrednie wejścia modułów, rzeczywiste dependency outputs, regionalne networking i nazwane połączenia. Zachowuj własność stanu i natywny wieloliniowy HCL.
---

# Struktura i użycie Terragrunt

Skill pozostaje wyłącznie w tym repozytorium, bez instalowania w Codex lub home.
Sprawdź instrukcje, stan Git, root.hcl i kontrakty używanych modułów. Ich implementację
opisuje [terraform-module](../terraform-module/SKILL.md). Nie modyfikuj cudzych zmian.

## Obecny układ

```text
root.hcl
modules/<funkcja>/
env/<środowisko>/
├── environment.hcl
└── <projekt>/
    ├── project.hcl
    └── <region>/
        ├── region.hcl
        └── networking/
            ├── network/<nazwa-vpc>/terragrunt.hcl
            ├── router/terragrunt.hcl
            ├── vpn-gateway/terragrunt.hcl
            └── connections/to-<peer-region>/
                ├── connection.hcl
                ├── tunnels/terragrunt.hcl
                └── bgp/terragrunt.hcl
```

Nie przywracaj pojedynczego regionalnego `tunnel` ani `router-config` zakładającego
jednego peera. Sieć, router i brama są współdzielone przez połączenia regionu.
Każda VPC ma osobną atomową jednostkę network/<nazwa-vpc>/ i osobny stan.
Routery i bramy wskazują dependency do konkretnego katalogu VPC.
Nowe połączenie nie duplikuje tych zasobów. Nie twórz automatycznie pełnej siatki
połączeń; wykonuj tylko żądaną topologię.

Parametry zasobu wpisuj bezpośrednio do inputs jednostki, która go tworzy:
nazwy VPC/subnetu i CIDR do network, nazwę routera i ASN do router, nazwę bramy
do vpn-gateway. Nie dodawaj zbiorczych plików z tymi wartościami ani pośredniego
local.site. Wspólne pliki kontekstowe to environment.hcl, project.hcl i region.hcl.
connection.hcl pozostaje metadanymi konkretnego połączenia używanymi przez jego
jednostki tunnels i bgp. ASN zdalnego routera pobieraj z rzeczywistego outputu
jego dependency, nie przez odczyt jego pliku konfiguracyjnego.

To aktualny wzorzec sieciowy, nie nakaz tworzenia tych katalogów dla każdej usługi.
Nowe jednostki mają odzwierciedlać rzeczywistą odpowiedzialność i własność stanu.

## Kontekst zawsze przez locals

`environment.hcl` udostępnia `inputs.environment`, `project.hcl` — `inputs.project`,
a `region.hcl` — `inputs.region`. Używaj dokładnie tych nazw. Każda jednostka
odczytuje te pliki w locals i przekazuje wartości bezpośrednio do inputs:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region

  network = {
    name = "example-vpc"
  }
}
```

Nie twórz zbiorczego obiektu konfiguracji providera, nie zmieniaj environment na
inną nazwę i nie wpisuj projektu/regionu/środowiska ponownie na sztywno w jednostce.
Dodatkowe ustawienia przekazuj wyłącznie zgodnie z wejściami modułu. Provider i jego
wersja należą do modułu — nie generuj konkurencyjnej konfiguracji w env.
Nazwy i parametry usług mogą pochodzić z tematycznego pliku odczytanego w locals.
Nie dodawaj nieużywanych locals ani nie wymyślaj automatycznego prefiksowania nazw.

## Zależności i granice projektów

Każde odwołanie do zasobu innej jednostki pochodzi z rzeczywistych
`dependency.<nazwa>.outputs`. Dla identyfikatorów URL używaj outputu `.self_link`;
gdy provider wymaga nazwy, użyj outputu `.name`. Nie składaj adresów googleapis.com
z projektu, regionu i nazwy. W env nie ma mock_outputs, skip_outputs ani fikcyjnych
ID. Izolowane mocki testów modułów nie są konfiguracją env.

`find_in_parent_folders("project.hcl")` znajduje najbliższy projekt. Obecny wzorzec
połączeń obsługuje regiony TEGO SAMEGO projektu: peer wskazuje lokalny connection.hcl,
a jego gateway znajduje się pod katalogiem tego projektu. Nie przedstawiaj tego
jako obsługi cross-project. Dla żądanego połączenia między projektami najpierw
rozszerz jawne dane endpointów o projekt/ścieżkę i wyznacz dependency do właściwego
projektu; nie zgaduj go i nie zmieniaj prawdziwego outputu na zbudowany URL.

Przykład zależności lokalnej w jednostce tunnels:

```hcl
dependency "gateway" {
  config_path = "../../../vpn-gateway"
}
```

Jej wynik jest używany w obiekcie tunelu jako
`vpn_gateway = dependency.gateway.outputs.gateways.main.self_link`.
Zweryfikuj istnienie ścieżki, nazwę outputu i klucz mapy w module.

## Składanie modułów bez cyklu

Aktualna kolejność: network → router / vpn-gateway → tunnels → bgp.
`router` tworzy Cloud Router, `vpn-ha` otrzymuje jego referencję, a jednostka bgp
używa ponownie MODUŁU router z pustą mapą routers, konfigurując tylko interfejsy
oraz peery danego połączenia. Nie tworzy drugiego routera ani drugiego właściciela
routera w stanie. Nie dodawaj modułu router-bgp.

Obie strony tunelu potrzebują swoich bram, zgodnych par interfejsów, pasujących
PSK i wzajemnej adresacji BGP. Sprawdzaj ASN, CIDR i nazwy także między wieloma
połączeniami na tym samym routerze. Graf dependency musi pozostać acykliczny.

## Formatowanie obowiązkowe

Natywny HCL: przypisania przez `=`, dwie spacje wcięcia, bez JSON-owych obiektów.
W każdym `terragrunt.hcl` zachowuj zawsze kolejność elementów najwyższego poziomu:
`include` → `terraform_binary` → `locals` → `terraform` → `inputs` → `dependency` / `dependencies`.
Wszystkie bloki zależności umieszczaj na samym dole, po inputs, również gdy inputs
odwołuje się do ich outputów. Pomijaj elementy, których jednostka nie potrzebuje.
Ta kolejność dotyczy także przykładów i szablonów; nie określa kolejności wdrażania.
Pomiędzy każdymi elementami najwyższego poziomu jest jedna pusta linia.
Komentarz należy do następującego elementu; pustą linię umieść przed komentarzem.

Każdy niepusty obiekt/mapę zapisuj wieloliniowo, także wewnątrz for i przykładów.
Po klamrze otwierającej zawartość zaczyna się w nowej linii. Każda klamra zamykająca
ma osobną linię i właściwy poziom wcięcia. Tylko puste `{}` mogą być zwarte.
Nie pozostawiaj pustej linii zaraz po otwierającej klamrze. Uruchom fmt i sprawdź
te reguły osobno — formatter nie rozwija sam wszystkich zwartych obiektów.

## Stan i sekrety

Przeczytaj aktualny root.hcl przed przeniesieniem jednostki. Obecnie korzysta z
istniejącego GCS bucketu TF_STATE_BUCKET, nie tworzy bucketu, pomija networking
w wyliczanej ścieżce i mapuje historyczne stany oryginalnego EU–US oraz istniejących VPC.
Zachowuj te klucze. To wyjątki migracyjne, nie wzorzec do kopiowania na nowe
połączenia. Każda nowa jednostka musi mieć własny prefix; nie migruj ani nie usuwaj
stanu tylko dlatego, że zmieniasz katalogi.

Plik PSK wskazuje dane połączenie, domyślnie względem root repozytorium.
Oba endpointy muszą otrzymać pasujące klucze. Prawdziwe `*.secrets.tfvars` są
ignorowane; śledzone przykłady zawierają wyłącznie placeholdery. Globalne ustawienie
VPN_SECRETS_FILE nadpisze ścieżkę również innym połączeniom w tym uruchomieniu —
nie używaj go przypadkiem przy wielu różnych plikach. Nie loguj sekretów.

## Weryfikacja i zakres pracy

Uruchom hcl fmt --check, sprawdź własne reguły layoutu, diff, ścieżki dependency,
kontrakty inputs/outputs, unikalność stanów i acykliczność grafu. Jeśli zależności
mają rzeczywiste outputy, można wykonać odpowiednią walidację/render. Nie zakładaj,
że hcl validate jest zawsze offline: może próbować odczytać zależności/backend.
Gdy stanów brak, ogranicz się do kontroli statycznych i izolowanych testów poza
env; nie wstawiaj mocków ani nie twórz zasobów tylko po to, aby uzyskać outputy.

Przy formatowaniu potwierdź brak zmiany wartości/wyrażeń. Przy zmianie interfejsu
modułu zaktualizuj wszystkie wywołania, przykłady i testy. Przy rozbudowie topologii
sprawdź, że nowe połączenie nie zmienia starego i nie duplikuje lokalnej bramy.
Przygotowanie kodu nie jest poleceniem wdrożenia: bez odpowiedniej instrukcji nie
uruchamiaj realnego plan/apply/destroy. Raportuj faktyczne kontrole, ograniczenia
oraz ewentualne brakujące dane do przyszłego wdrożenia.
