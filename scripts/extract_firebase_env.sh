#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_JSON="$ROOT_DIR/android/app/google-services.json"
IOS_PLIST="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
OUT_FILE="$ROOT_DIR/.env.generated"

echo "🔎 Extraindo configurações do Firebase para gerar .env.generated"

# Variáveis acumuladas
PROJECT_ID=""
API_KEY=""
STORAGE_BUCKET=""
MESSAGING_SENDER_ID=""
ANDROID_APP_ID=""
IOS_APP_ID=""
DATABASE_URL=""

if [ -f "$ANDROID_JSON" ]; then
  echo "✅ Encontrado: $ANDROID_JSON"
  PY_SCRIPT=$(cat <<'PY'
import json,sys
with open(sys.argv[1]) as f:
    j=json.load(f)
pi=j.get('project_info',{})
clients=j.get('client',[])
first=clients[0] if clients else {}
api_keys=first.get('api_key',[])
current_key=api_keys[0]['current_key'] if api_keys else ''
app_id=first.get('client_info',{}).get('mobilesdk_app_id','')
project_id=pi.get('project_id','')
storage_bucket=pi.get('storage_bucket','')
project_number=pi.get('project_number','')
database_url=j.get('project_info',{}).get('firebase_url','')
print('\n'.join([
    f'API_KEY={current_key}',
    f'ANDROID_APP_ID={app_id}',
    f'PROJECT_ID={project_id}',
    f'STORAGE_BUCKET={storage_bucket}',
    f'MESSAGING_SENDER_ID={project_number}',
    f'DATABASE_URL={database_url}'
]))
PY
  )
  eval $(python3 -c "$PY_SCRIPT" "$ANDROID_JSON")
  # Atribuições preferindo valores vazios apenas se não houver outro fonte
  PROJECT_ID="${PROJECT_ID:-$PROJECT_ID}"
  STORAGE_BUCKET="${STORAGE_BUCKET:-$STORAGE_BUCKET}"
  ANDROID_APP_ID="${ANDROID_APP_ID:-$ANDROID_APP_ID}"
  API_KEY="${API_KEY:-$API_KEY}"
  MESSAGING_SENDER_ID="${MESSAGING_SENDER_ID:-$MESSAGING_SENDER_ID}"
  DATABASE_URL="${DATABASE_URL:-$DATABASE_URL}"
else
  echo "⚠️ Não encontrado: $ANDROID_JSON"
fi

if [ -f "$IOS_PLIST" ]; then
  echo "✅ Encontrado: $IOS_PLIST"
  # plutil está presente no macOS por padrão
  get_plist() { plutil -extract "$1" raw "$IOS_PLIST" 2>/dev/null || echo ""; }
  IOS_APP_ID_VAL=$(get_plist GOOGLE_APP_ID)
  API_KEY_IOS=$(get_plist API_KEY)
  PROJECT_ID_IOS=$(get_plist PROJECT_ID)
  STORAGE_BUCKET_IOS=$(get_plist STORAGE_BUCKET)
  MESSAGING_SENDER_ID_IOS=$(get_plist GCM_SENDER_ID)
  DATABASE_URL_IOS=$(get_plist DATABASE_URL)

  # Preferir valores do iOS se existirem
  [ -n "$PROJECT_ID_IOS" ] && PROJECT_ID="$PROJECT_ID_IOS"
  [ -n "$STORAGE_BUCKET_IOS" ] && STORAGE_BUCKET="$STORAGE_BUCKET_IOS"
  [ -n "$API_KEY_IOS" ] && API_KEY="$API_KEY_IOS"
  [ -n "$MESSAGING_SENDER_ID_IOS" ] && MESSAGING_SENDER_ID="$MESSAGING_SENDER_ID_IOS"
  [ -n "$IOS_APP_ID_VAL" ] && IOS_APP_ID="$IOS_APP_ID_VAL"
  [ -n "$DATABASE_URL_IOS" ] && DATABASE_URL="$DATABASE_URL_IOS"
else
  echo "⚠️ Não encontrado: $IOS_PLIST"
fi

# Deriva auth domain e database url se necessário
AUTH_DOMAIN=""
if [ -n "$PROJECT_ID" ]; then
  AUTH_DOMAIN="$PROJECT_ID.firebaseapp.com"
  if [ -z "$DATABASE_URL" ]; then
    DATABASE_URL="https://$PROJECT_ID.firebaseio.com"
  fi
fi

echo "🧾 Gerando $OUT_FILE"
cat > "$OUT_FILE" <<ENV
# Gerado por scripts/extract_firebase_env.sh
FIREBASE_PROJECT_ID=${PROJECT_ID}
FIREBASE_API_KEY=${API_KEY}
FIREBASE_AUTH_DOMAIN=${AUTH_DOMAIN}
FIREBASE_DATABASE_URL=${DATABASE_URL}
FIREBASE_STORAGE_BUCKET=${STORAGE_BUCKET}
FIREBASE_MESSAGING_SENDER_ID=${MESSAGING_SENDER_ID}
FIREBASE_MEASUREMENT_ID=your_measurement_id

FIREBASE_ANDROID_APP_ID=${ANDROID_APP_ID}
FIREBASE_IOS_APP_ID=${IOS_APP_ID}
FIREBASE_WEB_APP_ID=your_web_app_id

# Platform Configuration
ANDROID_PACKAGE_NAME=${ANDROID_PACKAGE_NAME:-com.example.traineasy}
IOS_BUNDLE_ID=${IOS_BUNDLE_ID:-com.example.traineasy}
ENV

echo "✅ Arquivo gerado: $OUT_FILE"
echo "👉 Revise e copie para .env se estiver correto: cp .env.generated .env"
echo "ℹ️ Preencha manualmente FIREBASE_WEB_APP_ID e FIREBASE_MEASUREMENT_ID se usar Web/Analytics"