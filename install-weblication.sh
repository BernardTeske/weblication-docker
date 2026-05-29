#!/usr/bin/env bash
set -euo pipefail

REPO_URL_DEFAULT="https://github.com/BernardTeske/weblication-docker.git"
SETUP_URL="http://localhost:8080/wSetup.php"
PORT=8080

info()  { printf '\033[1;34m→\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }
error() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

prompt_input() {
  local var_name="$1"
  local prompt_text="$2"
  local value=""

  if [[ -t 0 ]]; then
    read -r -p "$prompt_text" value
  elif [[ -r /dev/tty ]]; then
    read -r -p "$prompt_text" value </dev/tty
  else
    error "Kein interaktives Terminal. Bitte Skript herunterladen und ausführen: ./install-weblication.sh"
  fi

  printf -v "$var_name" '%s' "$value"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "'$1' ist nicht installiert oder nicht im PATH."
}

normalize_repo_url() {
  local url="$1"
  case "$url" in
    git@github.com:*)
      url="${url#git@github.com:}"
      url="${url%.git}"
      printf 'https://github.com/%s.git\n' "$url"
      ;;
    *)
      printf '%s\n' "$url"
      ;;
  esac
}

detect_repo_url() {
  local script_dir="$1"
  if git -C "$script_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local origin
    origin="$(git -C "$script_dir" remote get-url origin 2>/dev/null || true)"
    if [[ -n "$origin" ]]; then
      normalize_repo_url "$origin"
      return
    fi
  fi
  printf '%s\n' "$REPO_URL_DEFAULT"
}

resolve_repo_url() {
  local script_name="${0##*/}"
  if [[ "$script_name" == "install-weblication.sh" && -f "$0" ]]; then
    detect_repo_url "$(cd "$(dirname "$0")" && pwd)"
  else
    printf '%s\n' "$REPO_URL_DEFAULT"
  fi
}

validate_project_name() {
  local name="$1"
  [[ "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || return 1
}

expand_path() {
  local path="$1"
  if [[ "$path" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "$path" == "~/"* ]]; then
    printf '%s/%s\n' "$HOME" "${path#~/}"
  else
    printf '%s\n' "$path"
  fi
}

open_browser() {
  local url="$1"
  if command -v open >/dev/null 2>&1; then
    open "$url"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 &
  else
    warn "Browser konnte nicht automatisch geöffnet werden."
    info "Bitte manuell öffnen: $url"
    return 1
  fi
}

wait_for_setup() {
  local url="$1"
  local max_attempts=60
  local attempt=1

  info "Warte auf Weblication-Setup (kann beim ersten Start etwas dauern) …"

  while (( attempt <= max_attempts )); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      ok "Setup erreichbar unter $url"
      return 0
    fi
    sleep 2
    (( attempt++ ))
  done

  warn "Setup-Seite antwortet noch nicht. Container-Logs prüfen:"
  warn "  docker compose -f \"$TARGET_DIR/docker-compose.yml\" logs -f weblication"
  return 1
}

set_container_name() {
  local compose_file="$1"
  local project_name="$2"
  local tmp_file

  tmp_file="$(mktemp)"
  sed "s/^[[:space:]]*container_name:[[:space:]]*.*/    container_name: ${project_name}/" "$compose_file" > "$tmp_file"
  mv "$tmp_file" "$compose_file"
}

prompt_project_name() {
  local name=""
  while true; do
    prompt_input name "Projektname (z. B. meinseseite): "
    name="${name// /}"

    if [[ -z "$name" ]]; then
      warn "Bitte einen Projektnamen eingeben."
      continue
    fi

    if validate_project_name "$name"; then
      PROJECT_NAME="$name"
      return
    fi

    warn "Ungültiger Name. Erlaubt: Buchstaben, Zahlen, _, . und - (nicht am Anfang)."
  done
}

prompt_install_location() {
  local cwd webprojects_path choice custom

  cwd="$(pwd)"
  webprojects_path="${HOME}/webprojects/${PROJECT_NAME}"

  prompt_input choice "In aktuelles Verzeichnis installieren ($cwd)? [J/n]: "
  if [[ -z "$choice" || "$choice" =~ ^[jJyY]$ ]]; then
    TARGET_DIR="$cwd"
    return
  fi

  prompt_input choice "~/webprojects/${PROJECT_NAME} verwenden? [J/n]: "
  if [[ -z "$choice" || "$choice" =~ ^[jJyY]$ ]]; then
    TARGET_DIR="$webprojects_path"
    return
  fi

  while true; do
    prompt_input custom "Anderes Zielverzeichnis: "
    custom="$(expand_path "$custom")"
    if [[ -n "$custom" ]]; then
      TARGET_DIR="$custom"
      return
    fi
    warn "Bitte einen Pfad eingeben."
  done
}

clone_repository() {
  local target="$1"

  if [[ -d "$target/.git" ]]; then
    warn "Verzeichnis existiert bereits und ist ein Git-Repository."
    prompt_input reuse "Trotzdem fortfahren und nur container_name aktualisieren? [j/N]: "
    if [[ ! "$reuse" =~ ^[jJyY]$ ]]; then
      error "Installation abgebrochen."
    fi
    return
  fi

  if [[ -e "$target" ]] && [[ -n "$(ls -A "$target" 2>/dev/null)" ]]; then
    error "Zielverzeichnis ist nicht leer: $target"
  fi

  if [[ "$target" == "$(pwd)" ]]; then
    info "Klone Repository in aktuelles Verzeichnis …"
    git clone --depth 1 "$repo_url" .
  else
    mkdir -p "$(dirname "$target")"
    info "Klone Repository …"
    git clone --depth 1 "$repo_url" "$target"
  fi

  ok "Repository geklont."
}

main() {
  local repo_url

  require_command git
  require_command docker
  require_command curl

  docker compose version >/dev/null 2>&1 || error "Docker Compose ist nicht verfügbar (docker compose)."

  repo_url="$(resolve_repo_url)"

  echo
  info "Weblication Docker Installation"
  echo

  prompt_project_name
  prompt_install_location

  info "Repository:  $repo_url"
  info "Ziel:        $TARGET_DIR"
  info "Container:   $PROJECT_NAME"
  echo

  clone_repository "$TARGET_DIR"

  if [[ ! -f "$TARGET_DIR/docker-compose.yml" ]]; then
    error "docker-compose.yml nicht gefunden in $TARGET_DIR"
  fi

  set_container_name "$TARGET_DIR/docker-compose.yml" "$PROJECT_NAME"
  ok "container_name auf '$PROJECT_NAME' gesetzt."

  info "Starte Docker-Container (Build beim ersten Mal kann dauern) …"
  (
    cd "$TARGET_DIR"
    docker compose up -d --build
  )
  ok "Container gestartet."

  if wait_for_setup "$SETUP_URL"; then
    open_browser "$SETUP_URL"
    ok "Browser geöffnet: $SETUP_URL"
  fi

  echo
  ok "Installation abgeschlossen."
  info "Projektverzeichnis: $TARGET_DIR"
  info "Container stoppen:  cd \"$TARGET_DIR\" && docker compose down"
  info "Logs anzeigen:      cd \"$TARGET_DIR\" && docker compose logs -f weblication"
  echo
}

main "$@"
