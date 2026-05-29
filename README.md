# Weblication CMS Docker Installation

Eine vollständige Docker-Installation für das Weblication CMS mit Apache, PHP 8.3 und automatischem Setup.

## 🚀 Features

- **Weblication CMS** - Vollständiges Content Management System
- **PHP 8.3** - Neueste PHP-Version mit allen notwendigen Extensions
- **Apache 2.4** - Webserver mit mod_rewrite und mod_headers
- **Automatisches Setup** - Lädt und installiert Weblication automatisch
- **Health Checks** - Überwachung der Container-Gesundheit
- **Zeitzone** - Konfiguriert für Europa/Berlin
- **Persistente Daten** - Webroot-Verzeichnis wird gemountet

## 📋 Voraussetzungen

- Docker
- Docker Compose
- Git (für das Install-Skript)
- curl (für das Install-Skript)
- Mindestens 2GB freier RAM
- Mindestens 5GB freier Speicherplatz

## 🛠️ Installation

### Schnellinstallation (empfohlen)

Mit dem interaktiven Install-Skript klonen, konfigurieren und starten — in einem Schritt:

```bash
curl -fsSL https://raw.githubusercontent.com/BernardTeske/weblication-docker/main/install-weblication.sh | bash
```

Alternativ erst herunterladen und prüfen:

```bash
curl -fsSL https://raw.githubusercontent.com/BernardTeske/weblication-docker/main/install-weblication.sh -o install-weblication.sh
chmod +x install-weblication.sh
./install-weblication.sh
```

Das Skript fragt nacheinander:

1. **Projektname** (z. B. `meinseseite`) — wird als `container_name` in der `docker-compose.yml` gesetzt
2. **Zielverzeichnis** — standardmäßig **`<aktuelles-verzeichnis>/<projektname>`**; alternativ `~/webprojects/<projektname>` oder ein frei wählbarer Pfad
3. Startet danach `docker compose up -d --build`, wartet auf das Setup und öffnet den Browser unter:

```
http://localhost:8080/wSetup.php
```

**Hinweise:**

- Das Zielverzeichnis muss leer sein (außer es existiert bereits als Git-Repository desselben Projekts).
- Bei `curl | bash` wird das Repository von GitHub geklont — unabhängig davon, woher das Skript geladen wurde.
- Port **8080** ist fest vorgegeben; bei Konflikten muss er in der `docker-compose.yml` angepasst werden.

### Manuelle Installation

#### 1. Repository klonen
```bash
git clone https://github.com/BernardTeske/weblication-docker.git
cd weblication-docker
```

#### 2. Container starten
```bash
docker compose up -d --build
```

#### 3. Auf Weblication zugreifen
Öffnen Sie Ihren Browser und navigieren Sie zu:
```
http://localhost:8080/wSetup.php
```

## 🔧 Konfiguration

### Ports
- **8080** → Container Port 80 (Apache)

### Umgebungsvariablen
- `TZ`: Europe/Berlin (Zeitzone)
- `WSETUP_URL`: URL für wSetup.zip (optional, Standard wird verwendet)

### Volumes
- `./webroot` → `/var/www/html` (Webroot-Verzeichnis)

## 📁 Projektstruktur

```
weblication-docker/
├── install-weblication.sh  # Interaktives Install-Skript
├── LICENSE                 # MIT-Lizenz (nur dieses Docker-Setup)
├── docker-compose.yml      # Docker Compose Konfiguration
├── Dockerfile             # Container Build-Definition
├── entrypoint.sh          # Container-Startup-Skript
├── apache/
│   └── vhost.conf        # Apache Virtual Host Konfiguration
├── php/
│   └── custom.ini        # PHP-Konfiguration
└── webroot/              # Weblication-Installation (wird gemountet)
```

## ⚙️ PHP-Extensions

Folgende PHP-Extensions sind installiert:
- **Core**: PDO, PDO_MySQL, ZIP, GD, OPcache, Intl
- **XML**: XSL, XML
- **Text**: MBString
- **Image**: GD (mit Freetype und JPEG), Imagick
- **Database**: MySQL Support
- **Security**: OpenSSL

## 🔒 Sicherheit

- X-Content-Type-Options Header gesetzt
- Apache mod_headers aktiviert
- Sichere Dateiberechtigungen
- HTTP-Only Session Cookies

## 📊 Monitoring

Der Container verfügt über integrierte Health Checks:
- Überprüfung alle 10 Sekunden
- Timeout nach 3 Sekunden
- 10 Wiederholungsversuche

## 🚨 Troubleshooting

### Container startet nicht
```bash
# Logs anzeigen
docker compose logs weblication

# Container neu starten
docker compose restart weblication
```

### Weblication lädt nicht
```bash
# Container-Status prüfen
docker compose ps

# Health Check Status (Container-Name = gewählter Projektname)
docker inspect <projektname> | grep Health -A 10
```

### Berechtigungsprobleme
```bash
# Berechtigungen korrigieren
docker compose exec weblication chown -R www-data:www-data /var/www/html
```

## 🔄 Wartung

### Container aktualisieren
```bash
# Neues Image bauen
docker compose build --no-cache

# Container neu starten
docker compose up -d
```

### Logs bereinigen
```bash
# Container-Logs anzeigen
docker compose logs --tail=100 weblication
```

## 📝 Anpassungen

### PHP-Konfiguration ändern
Bearbeiten Sie `php/custom.ini` und starten Sie den Container neu.

### Apache-Konfiguration anpassen
Bearbeiten Sie `apache/vhost.conf` und starten Sie den Container neu.

### Andere wSetup.zip-Quelle
Setzen Sie die Umgebungsvariable `WSETUP_URL` in der `docker-compose.yml`:

```yaml
environment:
  TZ: Europe/Berlin
  WSETUP_URL: https://ihre-quelle.de/wSetup.zip
```

## 🌐 Netzwerk

- **Host**: localhost:8080
- **Container**: 80 (intern)
- **Externe Verbindungen**: Port 8080 muss freigegeben sein

## 📚 Weitere Informationen

- [Weblication CMS Dokumentation](https://help.weblication.de)
- [Docker Dokumentation](https://docs.docker.com)
- [Docker Compose Dokumentation](https://docs.docker.com/compose/)

## 📄 Lizenz

Dieses Docker-Setup steht unter der [MIT-Lizenz](LICENSE).

**Weblication CMS** selbst ist ein kostenpflichtiges Produkt — siehe [Lizenzierung](#-lizenzierung) und [Weblication Dokumentation](https://help.weblication.de).

**Weblication-Partner:** [Bernard Teske](https://www.bernardteske.de) — für Lizenzen und den Erwerb von Weblication CMS wenden Sie sich direkt an ihn.

## 🤝 Support & Autor

Bei Problemen mit diesem Docker-Setup:

1. Container-Logs prüfen (`docker compose logs weblication`)
2. Health-Check-Status prüfen
3. Sicherstellen, dass Port 8080 frei ist

**Autor:** [Bernard Teske](https://www.bernardteske.de) — Weblication-Partner

## 💰 Lizenzierung (Weblication CMS)

**Wichtiger Hinweis:** Weblication ist ein **kostenpflichtiges CMS**.

- **Probeversion**: Kann für Testzwecke verwendet werden (wird beim Docker-Start automatisch eingerichtet)
- **Vollversion**: Erfordert eine gültige Lizenz
- **Lizenz erwerben**: Als Weblication-Partner berate ich Sie gerne — [Bernard Teske](https://www.bernardteske.de)
- **Layouts programmieren lassen**: Professionelle Entwicklung verfügbar
- **Weblics und Erweiterungen**: Individuelle Anpassungen möglich

### Professionelle Unterstützung

Für **Lizenzierung**, **Layout-Entwicklung**, **Weblics** und **Erweiterungen**:

**[Bernard Teske — Weblication-Partner — www.bernardteske.de](https://www.bernardteske.de)**
