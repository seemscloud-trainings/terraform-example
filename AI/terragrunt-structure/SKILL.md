---
name: terragrunt-structure
description: >-
  Twórz i aktualizuj konfiguracje Terragrunt w terraform-example/env: kontekst przez locals, bezpośrednie wejścia modułów, rzeczywiste dependency outputs, regionalne networking i nazwane połączenia. Zachowuj własność stanu i natywny wieloliniowy HCL.
---

# Struktura i użycie Terragrunt

Skill pozostaje wyłącznie w tym repozytorium, bez instalowania w Codex lub home.
Sprawdź instrukcje, stan Git, root.hcl i kontrakty używanych modułów. Ich implementację
opisuje [terraform-module](../terraform-module/SKILL.md). Nie modyfikuj cudzych zmian.

## Oznaczenia zasobów

W plikach environment.hcl, project.hcl i region.hcl trzymaj kontekst i labels
w locals; inputs przekazuje local.environment/project/region i local.labels.
Scalaj labels z kontekstów i przekazuj przez default_labels. Bramy i tunele VPN
obsługują labels; VPC, subnety, routery i interfejsy/peery nie mają tego pola
w obecnie używanym providerze. Nie dodawaj nieobsługiwanych argumentów.
Nie konfiguruj Resource Manager Tags w env i nie twórz dodatkowej jednostki,
modułu ani procedury ręcznego zakładania tagów. Jeśli oznaczenie wymaga takich
obejść, pomiń je. Opcjonalne pola providera w uniwersalnych modułach mogą pozostać,
ale ich dostępność nie oznacza, że wdrożenie ma ich używać.
Nie wykonuj ręcznych zmian zasobów chmurowych przez CLI/API; wdrażaj przez
Terraform/Terragrunt. CLI do dostępu, odczytu i uruchomienia Terraform jest dozwolone.

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

## Granice katalogów

Zachowuj hierarchię env/<środowisko>/<projekt>/<zakres>/<obszar>/<jednostka>.
Zakres to global dla zasobów globalnych albo rzeczywisty region dla regionalnych.
Bezpośrednio w env są katalogi środowisk, w środowisku katalogi projektów,
a w projekcie global i katalogi regionów. Na tych poziomach dopuszczone są odpowiednie
pliki kontekstowe environment.hcl, project.hcl i region.hcl.
Nie dodawaj bezpośrednio przy projekcie katalogów usługowych, np. tags lub network.
Globalne VPC należą do global/networking/network/<nazwa-jednostki>/.
Subnety należą do <region>/networking/subnetwork/<nazwa-jednostki>/.
Routery, bramy, tunele i BGP również pozostają pod właściwym regionem.
Networking jest kategorią, nie zakresem GCP: występuje zarówno w global, jak i w regionach.
Nie twórz region.hcl z region = "global"; globalna jednostka nie czyta region.hcl.
Nie dodawaj jednostek pomocniczych dla metadanych odczytywanych z plików
kontekstowych. Nie zmieniaj hierarchii bez polecenia użytkownika.
Przy przenoszeniu jednostki popraw wszystkie dependency i zachowaj klucz stanu.

## Obecny układ

```text
root.hcl
modules/<funkcja>/
env/<środowisko>/
├── environment.hcl
└── <projekt>/
    ├── project.hcl
    ├── global/
    │   └── networking/network/<nazwa-jednostki>/terragrunt.hcl
    └── <region>/
        ├── region.hcl
        └── networking/
            ├── subnetwork/<nazwa-jednostki>/terragrunt.hcl
            ├── router/<nazwa-jednostki>/terragrunt.hcl
            ├── vpn-gateway/<nazwa-jednostki>/terragrunt.hcl
            └── connections/<nazwa-połączenia>/
                ├── connection.hcl
                ├── tunnels/terragrunt.hcl
                └── bgp/terragrunt.hcl
```

Nie przywracaj pojedynczego regionalnego `tunnel` ani `router-config` zakładającego
jednego peera. Sieć, router i brama mogą być współdzielone przez połączenia;
każde połączenie wskazuje konkretne potrzebne jednostki. Nie twórz ich ponownie
na każde połączenie ani nie wymuszaj współdzielenia, gdy użytkownik chce osobne.
Każdy router i brama również ma osobną jednostkę oraz stan.
Każda VPC ma osobną atomową jednostkę network/<nazwa-jednostki>/ i osobny stan.
Nazwa katalogu jest stabilnym identyfikatorem jednostki, np. main; nie musi być
nazwą zasobu GCP, np. atlas. Nie synchronizuj tych nazw automatycznie.
Routery i bramy wskazują dependency do konkretnego katalogu VPC.
Nowe połączenie nie duplikuje tych zasobów. Nie twórz automatycznie pełnej siatki
połączeń; wykonuj tylko żądaną topologię.

Parametry zasobu wpisuj bezpośrednio do inputs jednostki, która go tworzy:
nazwę VPC do network, nazwę subnetu i CIDR do subnetwork, nazwę routera i ASN do router, nazwę bramy
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

Plik kontekstowy definiuje również mapy w locals, a inputs je tylko udostępnia:

```hcl
locals {
  environment = "prod"

  labels = {
    environment = local.environment
  }

}

inputs = {
  environment = local.environment
  labels      = local.labels
}
```

project.hcl:

```hcl
locals {
  project = "prod-common-temp"

  labels = {
    project = local.project
  }

}

inputs = {
  project = local.project
  labels  = local.labels
}
```

region.hcl:

```hcl
locals {
  region = "europe-west1"

  labels = {
    region = local.region
  }

}

inputs = {
  region = local.region
  labels = local.labels
}
```

Nazwy środowiska, projektu i regionu powyżej są przykładem; dla nowej jednostki
odczytaj jej najbliższe pliki kontekstowe. Nie kopiuj tych literałów do jednostek.
Jednostka regionalna dodatkowo czyta region.hcl w locals i przekazuje
region = local.region.inputs.region. Jednostka globalna pomija oba te elementy.
Przykład jednostki tworzącej globalną VPC:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project

  network = {
    name = "atlas"

  }
}
```

Nie twórz zbiorczego obiektu konfiguracji providera, nie zmieniaj environment na
inną nazwę i nie wpisuj projektu/regionu/środowiska ponownie na sztywno w jednostce.
Dodatkowe ustawienia przekazuj wyłącznie zgodnie z wejściami modułu. Provider i jego
wersja należą do modułu — nie generuj konkurencyjnej konfiguracji w env.
W module `versions.tf` zawiera `terraform.required_version` i `required_providers`;
`provider.tf` zawiera wyłącznie bloki konfiguracji `provider`.
Nie wynoś nazw, CIDR, ASN ani argumentów zasobów do nowych zbiorczych plików.
Wyjątkiem jest istniejący connection.hcl współdzielony przez tunnels i bgp
konkretnego połączenia. Nie przywracaj sites.hcl, vpn.hcl ani networking.hcl.
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
  config_path = "../../../vpn-gateway/main"
}
```

Jej wynik jest używany w obiekcie tunelu jako
`vpn_gateway = dependency.gateway.outputs.gateway.self_link`.
Zweryfikuj istnienie ścieżki i nazwę outputu. Router/brama mają pojedyncze outputy
router i gateway — bez mapy oraz bez .main.

## Składanie modułów bez cyklu

Aktualne zależności: globalny network → regionalny subnetwork;
globalny network → regionalny router / vpn-gateway → tunnels → bgp.
Subnet korzysta z dependency do konkretnej globalnej VPC i jej network.self_link.
Jednostka router/<nazwa>/ używa modułu router i tworzy dokładnie jeden router.
Jednostka vpn-gateway/<nazwa>/ używa vpn-ha i tworzy dokładnie jedną bramę.
Tunnels używa vpn-tunnel, a bgp używa router-connection dla istniejącego routera.
Żaden z tych modułów nie tworzy ponownie zasobów należących do innych jednostek.
Przekazuj router = { ... } i gateway = { ... }, nigdy routers/gateways jako mapy.
Wiele routerów lub bram oznacza więcej katalogów jednostek, nie więcej wpisów mapy.

Obie strony tunelu potrzebują swoich bram, zgodnych par interfejsów, pasujących
PSK i wzajemnej adresacji BGP. Sprawdzaj ASN, CIDR i nazwy także między wieloma
połączeniami na tym samym routerze. Graf dependency musi pozostać acykliczny.

## Ograniczenia obecnego env

Obecne nazwy katalogów to to-us-east1 i to-europe-west1; nie są regułą ograniczającą
liczbę połączeń. Kilka połączeń do tego samego regionu otrzymuje różne stabilne
nazwy jednostek, a nie jedną współdzieloną konfigurację z nadpisywanymi wartościami.
Obecne połączenia wskazują katalogi router/main i vpn-gateway/main. Nowe
połączenie może wskazać inną jednostkę. Nie zakładaj jednej bramy/routera na region;
wybieraj odpowiednią ścieżkę dependency i korzystaj z jej pojedynczego outputu.
Adresy peer_ip_address są obecnie jawne w connection.hcl. Sprawdzaj je względem
ip_range po drugiej stronie i unikaj kolizji. Nie twierdź, że pochodzą z outputs.
Nie dodawaj wzajemnych dependency pomiędzy jednostkami bgp: tworzą cykl.
Zmiana właściciela interfejsów lub peerów wymaga uwzględnienia migracji stanu.
Nie zmieniaj tej topologii przy samym poprawianiu skillów lub formatowania.

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

Nie twórz README.md; opis konwencji utrzymuj w lokalnych skillach AI/.
Nie instaluj tych skillów globalnie.

## Tworzenie kolejnej jednostki

1. Wybierz istniejący moduł według odpowiedzialności i przeczytaj jego wejścia
   oraz outputy. Nie zmieniaj atomowego modułu na mapę dla wygody wywołania.
2. Ustal zakres z API zasobu: global lub region. VPC umieść w global/networking/network/,
   subnet w <region>/networking/subnetwork/, a router i bramę pod regionem.
   Dodaj osobny katalog jednostki; nie łącz zasobów o różnych zakresach w jednym module.
3. Odczytaj kontekst przez locals, przekaż go do inputs i umieść jawne argumenty
   zasobu w tej jednostce. Dodaj labels zgodnie z obsługą zasobu i zakresem.
4. Wskaż konkretne zależności i ich outputy, a bloki dependency zapisz na końcu.
   Dla sieci/routera/bramy używaj pojedynczego outputu, bez wyboru klucza main.
5. Sprawdź graf, unikalność nazwy i stanu oraz kolizje adresacji. Kopia jednostki
   nie może zachować backendu oryginału ani otrzymać jego wyjątku migracyjnego.

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

Router/main oraz vpn-gateway/main zachowują stare klucze stanu sprzed zmiany
katalogów. Moduły zawierają moved this["main"] → this. Przeniesienie kodu tuneli
i BGP do osobnych modułów zachowuje ich dotychczasowe adresy zasobów i backendy.
Nie uruchamiaj migracji na żywo podczas samej zmiany struktury kodu.

Po rozdzieleniu VPC/subnetów stare klucze backendu sieci są zachowane przez aliasy
w root.hcl, mimo globalnej ścieżki jednostki. Subnety otrzymują osobne backendy.
Istniejące subnety trzeba przenieść między stanami lub zaimportować i usunąć ich
stary zapis stanu, nigdy odtwarzać zasobu. Przed migracją wykonaj kopie stanów,
a po niej sprawdź brak create/delete i dalsze działanie BGP. Samo przestawienie
folderów ani moved wewnątrz jednego modułu nie przenosi zasobu między backendami.

## Instancje Compute Engine

Moduł instance tworzy jedną google_compute_instance.this. Nie tworzy automatycznie
VPC, subnetu, reguł firewall ani konta usługi. Jawnie przekazuj istniejące zależności;
strefa musi należeć do regionu subnetu. Instance.zone nadpisuje wejście zone.
VM należy do konkretnej strefy, nie do global. W env użyj jednostki pod regionem
(np. compute/instance/<nazwa>), a strefę przekaż jawnie; nie wymyślaj domyślnej.
Network_interface jest listą, bo kolejność określa nic0, nic1 itd. Nie zmieniaj
kolejności istniejących kart i nie udawaj, że klucz mapy zapewnia im niezależny stan.
Powtarzalne pozostałe bloki są mapami. Publiczne IP pojawia się tylko przy jawnym
access_config; pusta mapa oznacza brak publicznego dostępu. Firewall jest osobny.
Labels są obsługiwane. Pole tags w VM to network tags dla firewalla, nie Resource
Manager Tags. Sekrety szyfrowania nie trafiają do outputu ani przykładów z danymi
rzeczywistymi. Metadata może zawierać sekrety, więc również nie eksportuj jej.
Boot disk: wybierz source albo initialize_params. Zmiana metadata_startup_script
może wymienić VM; metadata["startup-script"] ma inne zachowanie. Aktualizacje
machine_type mogą wymagać allow_stopping_for_update. Nie ustawiaj automatycznie
tej zgody ani publicznego IP.

## Reguły VPC Firewall

Firewall jest globalny w obrębie VPC: jednostka należy do global/networking/firewall/<nazwa>/.
Moduł firewall tworzy jedną google_compute_firewall.this i przyjmuje obiekt firewall.
Sieć przekazuj przez dependency.network.outputs.network.self_link. Allow i deny są
mapami bloków; wybierz tylko jedną akcję. Otwarcie portu z internetu wymaga jawnego
source_ranges i target_tags lub target_service_accounts, zgodnie z poleceniem użytkownika.
VM używa tags (network tags) do dopasowania reguły; to nie są Resource Manager Tags.
Klucz publiczny SSH może być śledzony w repo; kluczy prywatnych nigdy nie kopiuj.
