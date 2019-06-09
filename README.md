# Teaching-HEIGVD-RES-2018-Labo-HTTPInfra

**Autheurs:** Pierre Kohler, Jonathan Zaehringer

## Step 1: Static HTTP server with apache httpd

Dans le dossier `php` se trouve l'ensemble des documents nécessaires pour cette étape.
Dans le dossier `src` se trouve le template `bootstrap` que nous avons utilisé pour cette étape, il a déjà été modifié pour communiquer avec le serveur dynamique.
Il n'y a aucune configuration spécifique pour qu’apache puisse retourné le template qui est déposé dans `/var/www/html`.
Les différents scripts permettent de travailler avec le docker et le site est accessible par un `forward` de port en `8080`.

## Step 2: Dynamic HTTP server with express.js

## Step 3: Reverse proxy with apache (static configuration)

Dans le dossier `reverse-proxy` se trouve l'ensemble des documents nécessaires pour cette étape.
Dans le fichier `001-reverse-proxy.conf` contient la configuration de `apache` pour fournir un `reverse proxy`, cette configuration est statique et les adresses ont été choisi pour une séquence de démarrage des services précises.
Le script `run.sh` s'occupe de fournir cette séquence de démarrage.

La configuration `apache` utilise les modules `proxy` et `http_proxy`, ces modules servent à définir les deux règles permettant d'envoyer le paquet au bon destinataire :

```apache-conf
    ProxyPass "/api/students/" "http://172.17.0.3:3000/"
    ProxyPassReverse "/api/students/" "http://172.17.0.3:3000/"

    ProxyPass "/" "http://172.17.0.2:80/"
    ProxyPassReverse "/" "http://172.17.0.2:80/"
```

Le script `add_hosts.sh` permet d'ajouter la règle pour accéder avec une URL plus classique, ce script doit être exécuter en `root`.
Le serveur statique est atteignable à l'adresse `dashboard.res.ch:8080/` et le serveur dynamique est atteignable à l'adresse `dashboard.res.ch:8080/api/students`.

## Step 4: AJAX requests with JQuery

## Step 5: Dynamic reverse proxy configuration

Dans le dossier `dyn-reverse-proxy` se trouve l'ensemble des documents nécessaires pour cette étape.
Dans le fichier `001-reverse-proxy.conf` contient la configuration de `apache` pour fournir le `reverse proxy`, cette configuration contient des flags permettant la substituions des adresses des containers de manière dynamique.
La configuration est identique à l'étape 3, la seule différence est que le script `docker-php-entrypoint` a été modifié pour configurer le fichier avec les deux variables envoyées au docker.

Le script `run.sh` s'occupe de lancer les containers, de récupérer les IP nécessaires et de fournir ces IP en variable d'environnement au container du `reverse proxy`.
La configuration des URL est identique à l'étape 3 et le script `add_hosts.sh` aussi, il n’est donc pas nécessaire de le reéxcuter.

## Additional steps to get extra points on top of the "base" grade

### Load balancing: multiple server nodes (0.5pt)

Dans le dossier `reverse-proxy-load-balancing` se trouve l'ensemble des documents nécessaires pour cette étape.
La configuration présente dans le fichier `001-reverse-proxy.conf` utilise les modules supplémentaires `proxy_balancer` et `lbmethod_byrequests` pour configurer les load balancings des serveurs `dynamiques` et `statiques`.
La configuration est statique donc l'ordre de démarrage des containers est important, le système de `load balancing` est effectué par un `round robin`.

```apache-conf
<VirtualHost *:80>

    ServerName dashboard.res.ch

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Proxy "balancer://dynamic">
        BalancerMember "http://172.17.0.4:3000"
        BalancerMember "http://172.17.0.5:3000"
    </Proxy>
    
    ProxyPass "/api/students/" "balancer://dynamic/"
    ProxyPassReverse "/api/students/" "balancer://dynamic/"

    <Proxy "balancer://static">
        BalancerMember "http://172.17.0.2:80"
        BalancerMember "http://172.17.0.3:80"
    </Proxy>

    ProxyPass "/" "balancer://static/"
    ProxyPassReverse "/" "balancer://static/"

</VirtualHost>
```

Cette configuration définie deux zones de `load balancing`, l'une pour les deux adresses des services dynamiques et l'autre pour les deux services statiques.
Le script `run.sh` lance l'infrastructure et le script `scan.sh` permet d'afficher les logs de l'ensemble des containers.

Pour tester le bon fonctionnement, nous pouvons commencer par ouvrir le site statique qui effectuera des requêtes dynamiques de manières récurrentes.
Après un certain temps, on peut vérifier le bon fonctionnement du `load balancing` avec le script `scan.sh`, on doit voir que le nombre de requêtes entre les deux serveurs dynamiques n'avoir de différent que de `1`au maximum.
Puis on peut effectuer un `reload` du site et vérifier avec `scan.sh` que c'est bien le second serveur statique qui traite la requête.

### Load balancing: round-robin vs sticky sessions (0.5 pt)

Dans le dossier `reverse-proxy-load-balancing-sticky` se trouve l'ensemble des documents nécessaires pour cette étape.
La configuration présente dans le fichier `001-reverse-proxy.conf` est quasi identique à l'étape précédente, mais utilise les modules supplémentaires `headers` pour configurer la partie statique avec un système de `sticky session` pour forcé l'utilisation d'un serveur en particulier choisi lorsque le client se connecte la première fois.

```apache-conf
    Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
    <Proxy "balancer://static">
        BalancerMember "http://172.17.0.2:80" route=1
        BalancerMember "http://172.17.0.3:80" route=2
        ProxySet stickysession=ROUTEID        
    </Proxy>
```

Cette configuration définit un cookie pour le client définissant à quel serveur il doit être redirigé à chaque connexion choisi à sa première connexion.
Pour vérifié que le système fonctionne bien la procédure est identique à la dernière étape, le seul changement doit être visible après le `reload` de la page web, ce doit être le même serveur `statique` qui doit répondre à la demande.

### Dynamic cluster management (0.5 pt)

Dans le dossier `traefik` se trouve l'ensemble des documents nécessaires pour cette étape.
Pour cette étape, nous avons utilisé `treafik` pour permettre une augmentation à la demande du nombre d'entités lancées.
La configuration `traefik.toml` de `traefik` est par défaut.
Nous avons utilisé `docker-compose` pour automatiser le lancement des containers et pouvoir `scale-up` et `scale-down` de manière simple.

```yaml
version: '3'

services:
  traefik:
    image: traefik # The official Traefik docker image
    command: --api --docker # Enables the web UI and tells Traefik to listen to docker
    ports:
      - "80:80"     # The HTTP port
      - "8080:8080" # The Web UI (enabled by --api)
    volumes:
      - ./traefik.toml:/traefik.toml
      - /var/run/docker.sock:/var/run/docker.sock # So that Traefik can listen to the Docker events
  static:
    build:
      context: ../php
      dockerfile: Dockerfile
    labels:
      - "traefik.enable=true"
      - "traefik.backend=static"
      - "traefik.frontend.rule=Host:dashboard.res.ch"
      - "traefik.port=80"
  dyn:
    build:
      context: ../node
      dockerfile: Dockerfile
    labels:
      - "traefik.enable=true"
      - "traefik.backend=dynamic"
      - "traefik.frontend.rule=Host:dashboard.res.ch;PathStrip:/api/students"
      - "traefik.port=3000"
```

L'interface de `traefik` est présente sur le port `8080` et maintenant les services sont accessible sur le port `80` avec la même adresse qu'au paravent.
Les services sont configurés avec un ensemble de labels permettant de dire à `traefik` comment configurer et rediriger les informations au bon container.
`Traefik` Fonctionne avec une partie `backend` qui contient les containers et une partie `frontend` qui défini quelle requête doit être redirigé vers quel `backend`.

Les différents scripts permettent de voir le fonctionnement de `traefik` en augmentant/diminuant le nombre de containers et voir les modifications en temps réel sur l'interface de `traefik`.
