# Travail de préparation pour la prochaine séance

Cet exercice utilise les fichiers `pre_day2/template.md` et `pre_day2/generate.sh` préparés la dernière fois. Comptez environ 30 minutes au total pour l'exercice. Aucun travail n'est à rendre. Après l'exercice, une section « Préparation de la prochaine séance » vous propose aussi de télécharger à l'avance les fichiers volumineux qui seront utilisés à cette occasion. Il s'agit d'une tâche distincte, qui n'est pas comprise dans les 30 minutes.

## Exercice

Ajoutez au rapport un champ « Machine ayant exécuté le script ». Générez ensuite le rapport dans votre Codespace et dans GitHub Actions, puis comparez les deux valeurs enregistrées. La valeur générée dans le Codespace sera écrasée lorsque vous récupérerez le résultat depuis GitHub ; notez-la donc au préalable.

Les manipulations sont les mêmes que pendant les travaux pratiques d'aujourd'hui. Respectez les conditions suivantes.

- Travaillez sur une branche créée pour cet exercice à partir de `master`, comme aujourd'hui.
- Intégrez les modifications dans `master` au moyen d'une Pull Request.
- Incluez dans le commit uniquement les trois fichiers `template.md`, `generate.sh` et `report.md` de `pre_day2`.
- Après l'intégration, récupérez également le résultat de GitHub dans la branche `master` de votre Codespace.

## Lignes à ajouter

Les lignes à ajouter figurent dans les blocs ci-dessous. Recopiez leur contenu tel quel aux emplacements indiqués.

### template.md

Ajoutez cette ligne juste après celle qui porte le libellé « Date et heure de vérification (UTC) ».

```
Machine ayant exécuté le script : {{MACHINE_NAME}}
```

### generate.sh

Ajoutez ces lignes juste après la ligne `checked_at=`. Les lignes commençant par `#` expliquent ce que fait le code.

```
    # Placer dans machine_name le nom qui identifie la machine exécutant le script.
    # /proc/sys/kernel/hostname est le fichier où la machine indique son propre nom d'identification.
    machine_name=$(cat /proc/sys/kernel/hostname)
```

Ajoutez la ligne suivante avant la ligne `sed` qui remplace `{{HTTP_STATUS}}`. Elle demande de remplacer le repère `{{MACHINE_NAME}}`, ajouté à `template.md`, par le nom d'identification obtenu ci-dessus.

```
        -e "s|{{MACHINE_NAME}}|$machine_name|g" \
```

Avec les lignes `sed` qui l'entourent, cette ligne forme une seule commande. Le caractère `\` (barre oblique inverse) en fin de ligne indique que la commande continue à la ligne suivante : veillez à le conserver. N'ajoutez pas non plus de ligne de commentaire juste avant ou juste après cette ligne. Un commentaire placé au milieu de la commande l'interromprait à cet endroit.

## Points de vigilance

- Ne supprimez pas le `\` à la fin de la ligne `sed` ajoutée à `generate.sh`. Sans lui, `./generate.sh` reste bloqué sans rien afficher. Si cela se produit, interrompez le script en maintenant la touche `Ctrl` enfoncée et en appuyant sur `C`, remettez le `\`, enregistrez, puis relancez le script.
- Si une étape apparaît en rouge dans Actions, lisez l'erreur de la première étape devenue rouge. Les causes les plus fréquentes sont une erreur de copie dans une ligne ajoutée ou un mauvais emplacement. La Pull Request ayant déjà été intégrée, vous ne pouvez pas la réutiliser pour corriger l'erreur. Mettez à jour votre branche locale `master`, créez une nouvelle branche, corrigez-y le problème, puis intégrez la correction en suivant la même procédure.
- Il est normal que les valeurs du Codespace et de GitHub Actions soient différentes. Si elles sont identiques, vérifiez que vous les avez bien recopiées.

## Autoévaluation

L'exercice est terminé lorsque tous les critères suivants sont remplis. La manière de les vérifier est précisée : contrôlez-les un par un.

- [ ] Les modifications ont été intégrées au moyen d'une Pull Request depuis la branche de l'exercice, et seuls les trois fichiers de `pre_day2` ont été modifiés. (Vérifiez dans l'onglet `Files changed` de cette Pull Request.)
- [ ] La génération dans GitHub Actions a réussi. (Dans l'onglet `Actions` du dépôt, l'exécution de `Update report` démarrée après l'intégration apparaît en vert. Juste après l'intégration, elle est encore en cours : attendez qu'elle se termine.)
- [ ] Le résultat de GitHub a été récupéré dans la branche `master` du Codespace. (En exécutant `git status`, vous constatez que vous êtes sur `master` et qu'aucune modification n'est en attente de commit.)
- [ ] `report.md` contient une ligne « Machine ayant exécuté le script : » suivie d'une valeur. (Affichez-le avec `cat pre_day2/report.md` et vérifiez que la ligne existe et que `{{MACHINE_NAME}}` a bien été remplacé.)
- [ ] Cette valeur diffère de celle que vous avez notée lors de la génération dans le Codespace. (La valeur de `report.md` récupéré provient de la génération dans GitHub Actions.)

## Préparation de la prochaine séance

À partir d'ici, il s'agit de préparer la prochaine séance, et non plus de réaliser l'exercice. Téléchargez à l'avance les fichiers volumineux qui seront utilisés lors de cette séance.

Le programme de préparation `pre_day3/prepare.sh` est déjà présent dans le dépôt. Dans le terminal du Codespace, exécutez la commande suivante depuis la racine du dépôt.

```sh
./pre_day3/prepare.sh
```

Cela peut prendre quelques minutes. La préparation est terminée lorsque le message `La préparation est terminée` s'affiche. Si le programme s'arrête sur une erreur, suivez les instructions affichées (patienter, libérer de l'espace, relancer le programme, etc.).

Si vous n'avez pas eu le temps de le lancer, vous pourrez poursuivre en exécutant la même commande au début de la prochaine séance. Le téléchargement pouvant prendre jusqu'à 10 minutes, prévoyez toutefois ce temps supplémentaire pour la prochaine séance.

Lors de la prochaine séance, vous ferez fonctionner dans Docker le mécanisme utilisé ici pour renseigner « Machine ayant exécuté le script ».
