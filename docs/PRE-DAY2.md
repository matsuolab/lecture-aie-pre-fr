# Travail de préparation pour la prochaine séance

Lors de la prochaine séance, vous vérifierez la réponse d'une page Web et rassemblerez le résultat ainsi que la date et l'heure dans un rapport. Vous exécuterez ce traitement dans votre propre dépôt. Préparez dans votre Codespace les deux fichiers nécessaires. Comptez environ 10 minutes. Aucun travail n'est à rendre.

## Éléments à préparer

Créez les deux fichiers suivants dans un dossier nommé `pre_day2`.

- `pre_day2/template.md` — Le modèle du texte du rapport
- `pre_day2/generate.sh` — Le script qui génère le rapport à partir du modèle

Leur contenu se trouve plus bas sur cette page. Vous les lirez et les exécuterez lors de la prochaine séance. Pour le moment, il suffit de les préparer.

## Étapes à suivre

1. Ouvrez le Codespace utilisé aujourd'hui. Si son onglet est encore ouvert, revenez-y. Si vous l'avez fermé, ouvrez sur GitHub la page de votre dépôt, puis choisissez `Codespaces` depuis `Code`, comme aujourd'hui. Le Codespace créé aujourd'hui apparaît dans la liste : cliquez dessus. N'en créez pas de nouveau.
2. Dans l'explorateur de fichiers, créez un nouveau fichier `pre_day2/template.md`. La procédure est expliquée dans la section suivante.
3. Copiez le contenu du bloc « template.md » ci-dessous, collez-le dans le fichier et enregistrez-le comme aujourd'hui.
4. Créez et enregistrez `pre_day2/generate.sh` de la même manière.
5. Ouvrez les deux fichiers et comparez leur contenu avec les blocs de cette page pour vérifier qu'ils sont identiques.

Pour cette préparation, vous pouvez rester sur master sans créer de branche. Vous effectuerez le commit lors de la prochaine séance.

## Créer un nouveau fichier (manipulation non abordée dans les travaux pratiques d'aujourd'hui)

1. Tout en haut de l'explorateur de fichiers, faites un clic droit sur la ligne portant le nom de votre dépôt (affiché en majuscules).
2. Dans le menu qui apparaît, choisissez `New File...` (Nouveau fichier). Un champ de saisie du nom apparaît.
3. Saisissez `pre_day2/template.md`, puis appuyez sur Entrée. Le dossier `pre_day2` et le fichier qu'il contient sont créés en même temps, et un éditeur vide s'ouvre.

Si l'affichage est différent, cherchez dans l'explorateur de fichiers l'option correspondant à « Nouveau fichier ». Vous pouvez aussi faire un clic droit dans l'espace vide sous la liste des fichiers pour ouvrir le même menu. L'éditeur du Codespace est VS Code. Guide officiel de l'interface : [User Interface — Explorer (VS Code Docs)](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_explorer-view)

## Contenu à coller

Collez uniquement le contenu des blocs. N'incluez ni le nom du fichier ni les délimiteurs du bloc. Ne collez rien dans le terminal. Vous n'exécuterez pas les fichiers cette fois-ci.

### template.md

```markdown
# Rapport de vérification d'une page Web

Cible : https://example.com/
Date et heure de vérification (UTC) : {{CHECKED_AT}}
Code de statut HTTP : {{HTTP_STATUS}}

Ce rapport est généré à partir du modèle et des résultats de la vérification.
```

### generate.sh

```sh
#!/bin/sh

# Ce fichier est un script qui génère un rapport à partir des résultats de la vérification d'une page Web.
# Le #! de la première ligne indique que ce contenu doit être exécuté par le programme sh.
# Du caractère # jusqu'à la fin de la ligne, le texte est un commentaire qui n'est pas exécuté.

# Arrêter immédiatement le script si une erreur survient (-e).
# Arrêter aussi le script si une valeur non définie est utilisée (-u).
set -eu

# Se placer dans le dossier contenant ce script.
# $0 est le chemin de ce fichier ; dirname est la commande qui en extrait le nom du dossier.
# Cela permet de lire le fichier template.md voisin de la même manière, quel que soit le dossier de lancement.
cd "$(dirname "$0")"

# Avec case, choisir le traitement selon le nombre d'arguments ajoutés à la commande lors de son exécution.
# $# est le nombre d'arguments ajoutés à la commande.
case "$#" in
  # 0 correspond à une exécution sans argument.
  0)
    # [1] Accéder à la page Web et placer le code de statut HTTP dans http_status.
    #     Traiter un échec comme une erreur, arrêter au bout de 30 secondes et ne pas enregistrer le corps de la réponse.
    http_status=$(curl --fail --silent --show-error --location --max-time 30 \
      --output /dev/null --write-out '%{http_code}' https://example.com/)

    # [2] Placer la date et l'heure de vérification en temps universel coordonné dans checked_at.
    checked_at=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

    # [3] Remplacer les deux repères de template.md par les valeurs ci-dessus et écrire le résultat dans report.md.
    #     Le séparateur | permet de ne pas casser la commande si une valeur contient /.
    sed -e "s|{{CHECKED_AT}}|$checked_at|g" \
        -e "s|{{HTTP_STATUS}}|$http_status|g" template.md > report.md

    printf '%s\n' 'Le fichier report.md a été généré.'
    # ;; termine le traitement de ce cas.
    ;;

  # 1 correspond à une exécution avec un argument.
  1)
    # $1 est le premier argument ajouté à la commande lors de son exécution.
    if [ "$1" != "setup-actions" ]; then
      printf '%s\n' 'Utilisation : ./generate.sh ou ./generate.sh setup-actions' >&2
      exit 2
    fi
    # Créer le dossier de configuration de l'exécution automatique. S'il existe déjà, le réutiliser.
    mkdir -p ../.github/workflows
    # Écrire tel quel dans un fichier le contenu situé entre la ligne suivante et celle portant WORKFLOW.
    cat > ../.github/workflows/update-report.yml <<'WORKFLOW'
name: Update report

on:
  push:
    branches: [master]
    paths:
      - pre_day2/template.md
      - pre_day2/generate.sh
      - .github/workflows/update-report.yml
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update-report:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repository
        uses: actions/checkout@v7

      - name: Check required tools
        run: |
          command -v sh
          command -v sed
          command -v date
          command -v curl

      - name: Generate the report
        run: |
          chmod +x pre_day2/generate.sh
          ./pre_day2/generate.sh

      - name: Commit the changed report
        run: |
          if [ -z "$(git status --porcelain -- pre_day2/report.md)" ]; then
            echo "Aucune modification dans report.md."
            exit 0
          fi
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add pre_day2/report.md
          git commit -m "chore: update report"
          git push
WORKFLOW
    # Afficher un message pour confirmer la création du fichier.
    printf '%s\n' 'Le fichier .github/workflows/update-report.yml a été créé.'
    ;;

  # * correspond à tous les autres cas.
  *)
    printf '%s\n' 'Utilisation : ./generate.sh ou ./generate.sh setup-actions' >&2
    exit 2
    ;;
# esac termine le bloc case.
esac
```

## Résultat attendu

- L'explorateur de fichiers contient deux fichiers dans `pre_day2` ; quand vous les ouvrez, leur contenu est identique à celui des blocs de cette page.
- En répétant la manipulation utilisée aujourd'hui pour vérifier les noms des fichiers modifiés, vous voyez `pre_day2/`. Comme il s'agit de nouveaux fichiers, ils apparaissent sous un autre intitulé qu'aujourd'hui ; il suffit que `pre_day2/` soit visible. Les fichiers sont enregistrés, mais n'ont pas encore fait l'objet d'un commit. Vous effectuerez ce commit lors de la prochaine séance ; la préparation s'arrête donc ici.
- La prochaine séance commencera dans ce Codespace. Conservez-le sans le supprimer. S'il a disparu, recréez-en un en suivant la même procédure qu'aujourd'hui, puis recréez les deux fichiers en suivant de nouveau les étapes de cette page.
