---
name: terraform-module-create
description: Twórz i rozszerzaj moduły Terraform w terraform-example/modules, z pełnym pokryciem argumentów providera, typowanymi wejściami i stabilnymi mapami zasobów. Używaj przy pracy nad modułami tego repozytorium, nie do wdrażania środowisk.
---

# Moduły Terraform w tym repozytorium

Skill należy wyłącznie do `terraform-example/AI/`. Nie instaluj go ani nie kopiuj
do konfiguracji Codex, katalogu domowego lub innych repozytoriów. Przed edycją
sprawdź instrukcje repozytorium i stan Git; zachowaj niezwiązane zmiany.

## Zakres i elastyczność

Moduł odpowiada jednej funkcji infrastruktury. Nazwa jest domenowa, bez prefiksu
providera: `google_compute_network` → `modules/network`. Zasoby zależne należące
do tej funkcji mogą być w tym samym module: network zawiera VPC i jego subnety.
Nie dodawaj przy tym niezwiązanych VM, IAM, NAT, firewalli ani backendu stanu.

Dla wybranej wersji providera odczytaj oficjalny schemat przez
`terraform providers schema -json` i sprawdź dokumentację zasobów. To techniczny
format API narzędzia, nie format konfiguracji modułu. Wszystkie pliki Terraform,
wywołania i przykłady zapisuj w natywnym HCL: `nazwa = wartość`, bez JSON-owych
obiektów i bez generowania konfiguracji `.tf.json`.

Uwzględnij wszystkie konfigurowalne argumenty i bloki zagnieżdżone zasobów w
zakresie modułu, także mniej typowe tryby. Nie ograniczaj modułu do jednego
przykładu. Dla każdego pola zdecyduj: wejście użytkownika, jawne powiązanie z
innym zasobem modułu lub wartość wynikowa. Udokumentuj pola wiązane wewnętrznie,
dopuszczalne nadpisania oraz rzeczywiste braki providera. Nie udawaj obsługi
funkcji, której provider nie wystawia.

Nie wystawiaj computed-only jako wejść. `optional + computed` może być
konfigurowalne; sprawdź rzeczywistą walidację providera. Wyjątek: syntetyczne `id`
bywa oznaczone optional w starym SDK, lecz nie jest argumentem do ustawiania.
Nie generuj go bez sprawdzenia. Zachowaj wymagane pola, konflikty, ograniczenia
trybów i wrażliwość danych; nie obchodź ograniczeń przez local-exec lub CLI.

## Układ plików

- `versions.tf`: `terraform.required_version`, czyli uzasadniona minimalna wersja
  Terraform potrzebna implementacji i testom.
- `provider.tf`: `terraform.required_providers` z source i przypiętą wersją każdego
  providera oraz bloki `provider`. Konfiguracja projektu/regionu pochodzi z wejść.
  Dla nowego modułu sprawdź najnowszą stabilną wersję w oficjalnym Registry.
  Istniejące przypięcia zmieniaj tylko w zakresie zadania.
- `v-provider.tf`: typowana konfiguracja providera, np. obiekt `provider_config`.
  Preferuj ADC/standardowy łańcuch poświadczeń i opcjonalną impersonację. Nie
  zapisuj sekretów w repozytorium.
- `r-<zasób>.tf`: deklaracje resource konkretnego rodzaju, np. `r-network.tf`,
  `r-subnetwork.tf`, `r-proxy-https.tf`, `r-proxy-http.tf`.
- `v-<zasób>.tf`: odpowiadające im wejścia i walidacje, np. `v-network.tf`,
  `v-subnetwork.tf`, `v-proxy-https.tf`. Grupuj po zasobie; unikaj setek luźnych
  scalarów i jednego gigantycznego obiektu obejmującego cały moduł.
- `locals-naming.tf`: wyłącznie nazwy zasobów. Obecnie użytkownik podaje `name`;
  nie dopisuj prefiksów, sufiksów ani numerów, nie wyprowadzaj nazwy z klucza mapy.
- `locals.tf` lub `locals-<temat>.tf`: tylko rzeczywiście potrzebne normalizacje
  i wyliczenia inne niż nazewnictwo. Nie twórz pustych plików ani `l-*`.
- `outputs.tf`: użyteczne, jawne wyniki, dla kolekcji mapy zachowujące klucze wejść.
- `tests/*.tftest.hcl` i `examples/`: testy zachowania oraz parametryzowane przykłady.

Używaj małych liter w nazwach plików. Pojedynczy blok danego typu resource nazywaj
`this`; rozróżniane funkcje nazywaj jawnie, np. `proxy_http`, `proxy_https`.
Provider wewnątrz modułu jest obecną konwencją repozytorium. Wyjaśnij ograniczenie
Terraform: taki moduł nie może mieć `count`, `for_each` ani `depends_on` na
wywołaniu module. Wielokrotność obsługuj przez mapy wejściowe wewnątrz modułu.

## Wejścia i tożsamość zasobów

Pojedynczy zasób otrzymuje `object({...})`; kolekcja zasobów otrzymuje
`map(object({...}))`, zwykle `default = {}` i `nullable = false`. Subnety zawsze
są mapą. Iteruj bezpośrednio przez `for_each`; adres ma zawierać stabilny klucz,
np. `google_compute_subnetwork.this["application"]`.

Klucz mapy to tożsamość Terraform, a `name` to nazwa zasobu w chmurze. Nie używaj
`count`, indeksów list, `zipmap` z numeracją ani konwersji listy na mapę po indeksie
do identyfikowania zasobów. Dodanie wpisu w środku lub zmiana kolejności mapy nie
może przesuwać adresów pozostałych instancji. Zmiana klucza oznacza zmianę adresu;
przy refaktoryzacji stosuj jawne `moved`, jeśli ma być zachowany istniejący zasób.

Mapa nie gwarantuje braku każdej wymiany: zmiana niezmiennego argumentu, np. nazwy
lub regionu, nadal może wymusić odtworzenie zgodnie z providerem. Mów o zachowaniu
adresów/ID przy zmianie pozostałych wpisów, nie o ogólnej gwarancji zero destroy.
Listy są dopuszczalne dla pól o istotnej kolejności i zwykłych wartości. Dla
nazwanych, nieuporządkowanych bloków preferuj mapę; uwzględnij semantykę list/set
providera i nie deklaruj, że mapa zmienia jego sposób przechowywania bloków.

Używaj precyzyjnych typów, `optional` i rozsądnych defaultów; bez `any` jako
ucieczki od typowania. `default` dotyczy całego wejścia, `optional(typ, wartość)`
pól obiektu. Nie gub jawnych `false`, `0` i pustych kolekcji. Waliduj znaczące
ograniczenia, ale nie blokuj poprawnych zaawansowanych trybów providera.
Opcjonalny pojedynczy blok renderuj z `value == null ? [] : [value]`; kolekcję przez
`for_each` po mapie. Nie wyprowadzaj kluczy for_each z wartości computed po apply.

Domyślne połączenia między zasobami muszą być deklaratywne: subnet wskazuje VPC
utworzone przez moduł. Dopuszczaj jawne nadpisania, jeżeli mają uzasadnienie w
zakresie modułu, i opisuj ich pierwszeństwo. Nie wpisuj nazw projektów, VPC,
regionów ani sekretów na sztywno w zasobach.

## Przykłady i weryfikacja

Przykład rozdziela `main.tf` (wywołanie przez var.*), `variables.tf` (typy) i
`terraform.tfvars.example` (przykładowe wartości do uzupełnienia). Przykład nie
jest zgodą na wdrożenie ani na podłączenie go do `env/`.

Wykonaj fmt, init z wyłączonym backendem, validate oraz testy `mock_provider`.
Sprawdź minimalny zasób, pustą kolekcję, powiązanie zasobów, jawne nadpisania,
opcjonalne bloki, istotne błędne wejścia i zachowanie ID po dodaniu/usunięciu
innego klucza. Testy apply są dozwolone wyłącznie na mockach. Nie wykonuj realnego
plan/apply/destroy, nie zmieniaj istniejących środowisk i nie dotykaj stanu chmury
w ramach samego pisania modułu.

Opisz wynik, zakres argumentów, pominięcia wynikające z API i wykonane testy.
Nie utożsamiaj testów mockowanych z dowodem działania całej infrastruktury w GCP.

W testach złożenia nie zakładaj, że mock providera w root zastępuje konfiguracje
providerów wewnątrz modułów potomnych. Stosuj izolowane kopie bez tych konfiguracji,
przekaż mock jawnie przez providers i zablokuj użycie prawdziwych poświadczeń/API.
Nie używaj bezpośredniego apply przykładu jako testu integracyjnego modułów.
