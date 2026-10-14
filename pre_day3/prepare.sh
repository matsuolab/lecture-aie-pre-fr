#!/bin/sh

# Ce fichier est le programme de préparation de pre-Day3 (travaux pratiques Docker).
# Exécutez-le une fois avant le cours pour éviter d'attendre pendant la séance.
# Il se trouve dans le dépôt, à l'emplacement pre_day3/prepare.sh ; pour le lancer, utilisez
#   chmod +x pre_day3/prepare.sh
#   ./pre_day3/prepare.sh
# uniquement les deux commandes ci-dessus (les mêmes manipulations que celles apprises à pre-Day2).

# Arrêter immédiatement le script si une erreur survient (-e).
# Arrêter aussi le script si une valeur non définie est utilisée (-u).
set -eu

# [1] Regrouper dans des variables les versions de l'image Docker et du modèle à télécharger.
#     Les participants ne doivent pas modifier cette section.
IMAGE='ghcr.io/ggml-org/llama.cpp:server-v0.5.0'
MODEL_DIR='/workspaces/models'
MODEL_FILE='gemma-4-E2B-it-UD-Q4_K_XL.gguf'
MODEL_URL='https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/0314792d7f1f7e229411f620751375812bb9faf2/gemma-4-E2B-it-UD-Q4_K_XL.gguf'
MODEL_SHA256='b52f438017efaec5debf1c0d8be690571e212a07c312f1102bbce927258cfc32'
LLM_CHAT_DIR='/workspaces/llm-chat'
# Espace libre requis : environ 3.5GB à télécharger. Prévoir une marge et retenir 4GB (4 × 1024 × 1024 KB).
REQUIRED_FREE_KB=4194304

# [2] Vérifier la connexion au serveur Docker.
#     Si la connexion échoue, arrêter ici et indiquer la marche à suivre.
check_docker() {
  if ! docker version >/dev/null 2>&1; then
    printf '%s\n' 'Erreur : Docker est indisponible.' >&2
    printf '%s\n' 'Dans ce Codespace, Docker ne semble pas avoir terminé son démarrage, ou cet environnement ne permet pas de faire fonctionner Docker.' >&2
    printf '%s\n' 'Patientez quelques dizaines de secondes, puis relancez ./pre_day3/prepare.sh.' >&2
    exit 1
  fi
}

# [3] Vérifier l'espace libre dans /workspaces.
#     Si cet espace est insuffisant, arrêter ici et indiquer la marche à suivre.
check_disk_space() {
  free_kb=$(df -Pk "$MODEL_DIR_PARENT" | awk 'NR==2 {print $4}')
  if [ "$free_kb" -lt "$REQUIRED_FREE_KB" ]; then
    printf '%s\n' 'Erreur : espace libre insuffisant dans /workspaces.' >&2
    printf '%s\n' 'Il faut environ 4GB ou plus de libre (image Docker : environ 308MB, modèle : environ 3.2GB).' >&2
    printf '%s\n' 'Supprimez les Codespaces inutilisés ou les fichiers superflus, puis' >&2
    printf '%s\n' 'relancez ./pre_day3/prepare.sh.' >&2
    exit 1
  fi
}

# [4] Télécharger l'image Docker de llama.cpp. Ne pas la télécharger de nouveau si elle est déjà présente.
pull_image() {
  if docker image inspect "$IMAGE" >/dev/null 2>&1; then
    printf '%s\n' "Image Docker déjà téléchargée ($IMAGE). Téléchargement ignoré."
    return 0
  fi
  printf '%s\n' "Téléchargement de l'image Docker ($IMAGE). Cela peut prendre quelques minutes."
  if ! docker pull "$IMAGE"; then
    printf '%s\n' 'Erreur : échec du téléchargement de l’image Docker.' >&2
    printf '%s\n' 'Vérifiez la connexion réseau, puis relancez ./pre_day3/prepare.sh.' >&2
    exit 1
  fi
}

# [5] Vérifier que le SHA-256 du fichier correspond à la valeur attendue. Renvoyer 0 en cas de correspondance, sinon 1.
matches_sha256() {
  target_file="$1"
  [ -f "$target_file" ] || return 1
  actual=$(sha256sum "$target_file" | awk '{print $1}')
  [ "$actual" = "$MODEL_SHA256" ]
}

# [6] Télécharger le fichier du modèle.
#     Si son contenu a déjà été vérifié, ne pas le télécharger de nouveau ; supprimer et retélécharger tout fichier dont le téléchargement a été interrompu.
fetch_model() {
  mkdir -p "$MODEL_DIR"
  model_path="$MODEL_DIR/$MODEL_FILE"
  tmp_path="$model_path.download"

  if matches_sha256 "$model_path"; then
    printf '%s\n' "Modèle déjà téléchargé et contenu vérifié ($model_path). Téléchargement ignoré."
    return 0
  fi

  # Supprimer tout fichier laissé par un téléchargement précédemment interrompu.
  rm -f "$tmp_path"

  printf '%s\n' 'Téléchargement du modèle. Cela peut prendre environ une minute.'
  if ! curl --fail --silent --show-error --location --output "$tmp_path" "$MODEL_URL"; then
    rm -f "$tmp_path"
    printf '%s\n' 'Erreur : échec du téléchargement du modèle.' >&2
    printf '%s\n' 'Vérifiez la connexion réseau, puis relancez ./pre_day3/prepare.sh.' >&2
    exit 1
  fi

  if ! matches_sha256 "$tmp_path"; then
    rm -f "$tmp_path"
    printf '%s\n' 'Erreur : le contenu du modèle téléchargé est incorrect (le SHA-256 ne correspond pas).' >&2
    printf '%s\n' 'La connexion a peut-être été interrompue. Relancez ./pre_day3/prepare.sh.' >&2
    exit 1
  fi

  mv "$tmp_path" "$model_path"
  printf '%s\n' 'Téléchargement du modèle et vérification de son contenu terminés.'
}

# [7] Placer le Dockerfile destiné à l'IA dans /workspaces/llm-chat/Dockerfile.
#     Son contenu est inclus dans ce programme (identique au Dockerfile de la page de distribution).
place_llm_chat_dockerfile() {
  mkdir -p "$LLM_CHAT_DIR"
  cat > "$LLM_CHAT_DIR/Dockerfile" <<'DOCKERFILE'
# [1] Base (base image) : une image contenant le serveur de llama.cpp.
#     Fixer la version (server-v0.5.0). Avec latest, le contenu peut changer à chaque reconstruction.
FROM ghcr.io/ggml-org/llama.cpp:server-v0.5.0

# [2] Configuration (environment variable) : emplacement du modèle à charger.
#     Le fichier du modèle n'est pas inclus dans l'image ; le fournir depuis l'extérieur dans /models avec -v (bind mount) de docker run.
ENV LLAMA_ARG_MODEL=/models/gemma-4-E2B-it-UD-Q4_K_XL.gguf

# [3] Configuration : point d'accès (port). Écouter sur 0.0.0.0, port 8080, pour permettre les connexions depuis l'extérieur du conteneur.
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080

# [4] Configuration : désactiver le raisonnement (reasoning). Définir la longueur de conversation mémorisable (ctx-size).
#     Définir la longueur maximale d'une réponse (n-predict).
ENV LLAMA_ARG_REASONING=off
ENV LLAMA_ARG_CTX_SIZE=4096
ENV LLAMA_ARG_N_PREDICT=256

# [5] Configuration : première instruction donnée à l'IA (system prompt). Modifier ce texte, puis relancer docker build
#     change la manière de répondre de l'IA. Il suffit de modifier le texte entre les "" de cette ligne.
#     Conserver les guillemets imbriqués (' à l'extérieur, " à l'intérieur).
ENV LLAMA_ARG_UI_CONFIG='{"systemMessage":"Vous êtes un assistant serviable. Répondez brièvement."}'
DOCKERFILE
  printf '%s\n' "Le fichier $LLM_CHAT_DIR/Dockerfile a été mis en place."
}

# Exécution du programme à partir d'ici (appeler les fonctions [2] à [7] dans cet ordre).
MODEL_DIR_PARENT=$(dirname "$MODEL_DIR")
check_docker
check_disk_space
pull_image
fetch_model
place_llm_chat_dockerfile

printf '%s\n' 'La préparation est terminée'
