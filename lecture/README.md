# Dossier pour les exercices


## Démonstration Linux
L'objectif est d'obtenir la structure de fichiers et les permissions suivantes.
Les permissions sont indiquées sous la forme symbolique affichée par `ls -la` (exemple : `-rw-------`).

```text
lecture/                                        drwxr-xr-x
├── README.md                                   -rw-r--r--
├── docker-compose.yml                          -rw-r--r--
├── backend/                                     drwxr-xr-x
│   ├── Dockerfile                              -rw-r--r--
│   ├── main.py                                 -rw-r--r--
|   ├── .env                                    -rw-------  ← chmod 600 (propriétaire uniquement, car données confidentielles)
|   ├── .env.example                            -rw-r--r--  ← Modèle à partager
│   ├── requirements.txt                        -rw-r--r--
└── frontend/                                    drwxr-xr-x
    ├── Dockerfile                              -rw-r--r--
    ├── index.html                              -rw-r--r--
    ├── package-lock.json                       -rw-r--r--
    ├── package.json                            -rw-r--r--
    ├── tsconfig.json                           -rw-r--r--
    ├── vite.config.ts                          -rw-r--r--
    └── src/                                     drwxr-xr-x
        ├── App.tsx                             -rw-r--r--
        └── main.tsx                            -rw-r--r--
```


## Démonstration Docker
Vous pouvez lancer le serveur de développement avec Docker compose.
```
cp backend/.env.example backend/.env && chmod 600 backend/.env   # Uniquement la première fois
docker compose up -d --build
```

### Si l'envoi affiche l'erreur 504 : « La communication a échoué ».
Dans un Codespace, l'ancien pare-feu (iptables-legacy) peut bloquer les communications entre conteneurs.
Pour autoriser les communications entre les réseaux de Compose (dont le nom commence par `br-`), exécutez la commande suivante une seule fois après le démarrage du Codespace.
```
sudo iptables-legacy -I FORWARD 1 -i br-+ -o br-+ -j ACCEPT
```
- Ce réglage disparaît au redémarrage du Codespace (exécutez de nouveau la commande après le redémarrage).
- Pour annuler le réglage : `sudo iptables-legacy -D FORWARD -i br-+ -o br-+ -j ACCEPT`

Le serveur de développement est accessible à l'adresse suivante.
http://localhost:8080/