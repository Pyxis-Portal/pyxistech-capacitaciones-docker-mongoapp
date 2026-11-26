# Aplicación de ejemplo del curso de Docker de HolaMundo, lista para usar

Adaptación, para las capacitaciones de Pyxis Tech, de la
[aplicación de ejemplo](https://github.com/nschurmann/mongoapp-curso-docker) que Nicolás
Schurmann usa en el video
[Aprende Docker ahora! curso completo gratis desde cero!](https://www.youtube.com/watch?v=4Dko5W96WHg)
del canal HolaMundo. El código y el curso son suyos; este fork solo arregla los archivos de Docker
para que la aplicación levante sin instalar Node.js y sin escribir código. Se usa en el plan
Introducción a contenedores y Kubernetes (OW-K8S-INTRO), módulo M1.

## Qué es

Un servidor web de Node.js (`index.js`, hecho con Express) que guarda animales en una base
MongoDB. Responde en el puerto 3000 a dos direcciones:

| Dirección | Qué hace |
| --- | --- |
| `/crear` | Agrega un registro («Chanchito», «Feliz») y contesta `ok` |
| `/` | Lista los registros guardados |

En los archivos de Compose, el servicio `chanchito` es la aplicación y `monguito` es la base, con un
usuario y una contraseña de ejemplo fijados en el mismo archivo. Son de práctica: no se usan en
ningún otro lado.

## Qué hace falta

Una máquina Linux (una VM o WSL2) con:

- Docker Engine con el plugin Compose (`docker compose version` responde);
- git;
- curl, o un navegador.

Node.js **no** hace falta: corre dentro del contenedor. Solo se necesita para repetir el tramo del
video en que la aplicación corre fuera del contenedor (ver más abajo).

## Levantarla

```bash
git clone https://github.com/Pyxis-Portal/pyxistech-capacitaciones-docker-mongoapp.git
cd pyxistech-capacitaciones-docker-mongoapp
docker compose up -d --build
curl localhost:3000/crear
curl localhost:3000/
```

`/crear` contesta `ok` y `/` devuelve el registro creado, algo como
`[{"_id":"…","tipo":"Chanchito","estado":"Feliz","__v":0}]`. Si `curl` no responde, esperar unos
segundos (MongoDB tarda en arrancar la primera vez) y mirar `docker compose logs chanchito`.

| Para… | Comando |
| --- | --- |
| Ver el estado | `docker compose ps` |
| Ver los logs de la aplicación | `docker compose logs -f chanchito` |
| Bajar todo, conservando los datos | `docker compose down` |
| Bajar todo y borrar los datos | `docker compose down -v` |

### Variante de desarrollo

Es la del final del video: monta la carpeta en el contenedor y `nodemon` reinicia la aplicación cada
vez que se guarda un cambio en `index.js`.

```bash
docker compose -f docker-compose-dev.yml up -d --build
docker compose -f docker-compose-dev.yml logs -f chanchito
```

Al montar la carpeta, Docker deja en ella una carpeta `node_modules` vacía a nombre de root. Es
inofensiva y git la ignora; se borra con `rmdir node_modules` después de
`docker compose -f docker-compose-dev.yml down`.

## Cómo seguir el video con este repositorio

- **Imágenes, contenedores, puertos, variables de entorno y logs:** con los comandos del video, sobre
  la imagen de MongoDB. No hace falta la aplicación.
- **El tramo en que la aplicación corre fuera del contenedor (`node index.js`):** se puede mirar sin
  reproducir. Para repetirlo hace falta Node.js 18 o posterior en la máquina, correr `npm install` y
  cambiar `monguito` por `localhost` en la línea de `mongoose.connect` de `index.js`, como en el
  video. Antes de volver a los contenedores, se deshace el cambio.
- **Dockerfile, redes, Docker Compose, volúmenes y la variante de desarrollo:** el video escribe los
  archivos paso a paso; acá están terminados y funcionando, para comparar con lo que se escribe.

## En qué se diferencia del original

El código de la aplicación (`index.js`, `package.json`, `package-lock.json`) es el mismo, para que
se pueda seguir el video línea por línea. Cambian los archivos de Docker:

| Archivo | Cambio | Por qué |
| --- | --- | --- |
| `Dockerfile` | Instala las dependencias con `npm ci` dentro de la imagen | El original copia la carpeta tal como está y no las instala: sin un `npm install` previo en la máquina, el contenedor termina con `Cannot find package 'express'` |
| `Dockerfile`, `Dockerfile.dev` | `node:22-slim` en lugar de `node:18` | Node.js 18 dejó de recibir actualizaciones de seguridad en abril de 2025; la variante `slim` deja la imagen en unos 370 MB, contra 1,6 GB |
| `Dockerfile.dev`, `docker-compose-dev.yml` | Las dependencias se instalan en la imagen y un volumen anónimo las protege del montaje de la carpeta | Sin eso, el montaje tapa las dependencias de la imagen |
| `docker-compose.yml`, `docker-compose-dev.yml` | Sin la línea `version` | Docker Compose actual la ignora y avisa que es obsoleta |
| `docker-compose.yml`, `docker-compose-dev.yml` | `depends_on` en lugar de `links` | `links` es una opción heredada; en Compose, los servicios ya se encuentran por nombre |
| `docker-compose.yml`, `docker-compose-dev.yml` | `mongo:8.0` en lugar de `mongo` sin versión | Sin versión, cada `docker compose up` puede bajar una versión mayor distinta |
| `.dockerignore` | Nuevo | Deja afuera de la imagen `node_modules`, `.git` y la documentación |

Probado el 2026-11-26 con Docker Engine 29 y Docker Compose 5, en Linux.

## Avisos esperables, que no son errores

- `npm warn` y el resumen de `npm audit` con vulnerabilidades al construir: las dependencias son de
  2022 y no se actualizaron, para no apartarse del video. Es una aplicación de práctica: no se
  publica.
- Los avisos de MongoDB al arrancar (sistema de archivos, `rlimits`, `transparent_hugepage`) son
  recomendaciones para producción.

## Más

- [Resume.md](Resume.md): resumen del curso, del repositorio original.
- Dudas sobre la capacitación: capacitaciones@pyxis.tech.
