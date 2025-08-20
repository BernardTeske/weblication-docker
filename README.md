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
- Mindestens 2GB freier RAM
- Mindestens 5GB freier Speicherplatz

## 🛠️ Installation

### 1. Repository klonen
```bash
git clone <repository-url>
cd weblication-docker
```

### 2. Container starten
```bash
docker-compose up -d
```

### 3. Auf Weblication zugreifen
Öffnen Sie Ihren Browser und navigieren Sie zu:
```
http://localhost:8080
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
docker-compose logs weblication

# Container neu starten
docker-compose restart weblication
```

### Weblication lädt nicht
```bash
# Container-Status prüfen
docker-compose ps

# Health Check Status
docker inspect weblication20 | grep Health -A 10
```

### Berechtigungsprobleme
```bash
# Berechtigungen korrigieren
docker-compose exec weblication chown -R www-data:www-data /var/www/html
```

## 🔄 Wartung

### Container aktualisieren
```bash
# Neues Image bauen
docker-compose build --no-cache

# Container neu starten
docker-compose up -d
```

### Logs bereinigen
```bash
# Container-Logs löschen
docker-compose logs --tail=100 weblication
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

## 🤝 Support

Bei Problemen oder Fragen:
1. Überprüfen Sie die Container-Logs
2. Prüfen Sie die Health Check-Status
3. Stellen Sie sicher, dass alle Ports verfügbar sind

## 💰 Lizenzierung

**Wichtiger Hinweis:** Weblication ist ein **kostenpflichtiges CMS**. 

- **Probeversion**: Kann für Testzwecke verwendet werden
- **Vollversion**: Erfordert eine gültige Lizenz
- **Layouts programmieren lassen**: Professionelle Entwicklung verfügbar
- **Weblics und Erweiterungen**: Individuelle Anpassungen möglich

### 🛠️ Professionelle Unterstützung

Für **Lizenzierung**, **Layout-Entwicklung**, **Weblics** und **Erweiterungen** wenden Sie sich an:

**Bernard Teske**  
🌐 [www.bernardteske.de](https://www.bernardteske.de)

## 📄 Projekt-Lizenz

Dieses Docker-Setup ist für die lokale Entwicklung und den produktiven Einsatz von Weblication CMS gedacht.
