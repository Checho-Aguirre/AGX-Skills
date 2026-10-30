#!/usr/bin/env bash
#
# Hook PreToolUse de Claude Code (matcher Write|Edit): bloquea que se escriban
# archivos .env o contenido que parece una clave real. exit 2 = deny.
# Adaptado de vibe-check-security (Juan David Sierra, MIT).

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')
NAME=$(basename "$FILE_PATH")

deny() {
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"$1\"}}"
  exit 2
}

# Archivos de secretos; las plantillas sin valores reales sí se permiten
case "$NAME" in
  .env.example|.env.sample|.env.template) ;;
  .env|.env.*) deny "No se permite escribir archivos .env desde el agente." ;;
esac

# Contenido que parece una clave real
if echo "$CONTENT" | grep -qE '(sk_live_[0-9A-Za-z]+|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|sb_secret_[0-9A-Za-z_-]+)'; then
  deny "El contenido parece una clave real. Cárgala desde las variables de entorno o un gestor de secretos."
fi

exit 0
