# Roxs Voting App

Esta es una aplicación de votación distribuida que demuestra una arquitectura de microservicios simple. La aplicación consta de varios componentes que trabajan juntos para permitir a los usuarios votar y ver los resultados en tiempo real. Para la automatización del despliegue y la configuración del entorno, se utilizan tecnologías como **Vagrant** para la virtualización, **Ansible** para el aprovisionamiento y **Shell Bash** para la ejecución de scripts.

## Arquitectura

La aplicación se compone de los siguientes servicios:

- **Vote App**: Una aplicación web en **Python (Flask)** que presenta las opciones de votación y envía cada voto a una cola de Redis.
- **Result App**: Una aplicación web en **Node.js (Express + Socket.io)** que consulta los resultados de la votación desde la base de datos y los muestra en tiempo real.
- **Worker**: Un proceso en segundo plano de **Node.js** que escucha la cola de Redis, toma los votos y los persiste en una base de datos PostgreSQL.
- **Redis**: Un almacén en memoria que actúa como una cola de mensajería para los votos entrantes.
- **PostgreSQL**: La base de datos relacional donde se almacenan y cuentan los votos de forma persistente.

---

## Guía de Inicio Rápido

Sigue estos pasos para tener la aplicación funcionando en minutos. **Todos los comandos se ejecutan desde tu máquina local.**

### Prerrequisitos

- [Git](https://git-scm.com/)
- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

### 1. Preparar el Entorno

Primero, clona el repositorio y entra en el directorio del proyecto.

```bash
git clone <URL_DEL_REPOSITORIO>
cd roxs-voting-app
```

### 2. Crear y Aprovisionar la Máquina Virtual

Este es el paso más importante. El siguiente comando creará una máquina virtual con Ubuntu, instalará todo el software necesario (Python, Node, Redis, PostgreSQL) y lo configurará automáticamente. **Este proceso puede tardar varios minutos la primera vez.**

```bash
vagrant up
```

Si en algún momento necesitas empezar de cero, puedes destruir la máquina y volverla a crear con `vagrant destroy -f && vagrant up`.

### 3. Iniciar la Aplicación

Una vez que la máquina virtual esté lista, ejecuta el siguiente script desde tu máquina local. Este script actuará como un "control remoto" para iniciar los tres servicios dentro de la VM usando `tmux`.

```bash
bash ./iniciar_app.sh
```

> **Nota:** La primera vez que ejecutes este script, es normal que veas un error como `error connecting to /tmp/tmux-1000/default`. Puedes ignorarlo. El script procederá a crear la sesión de `tmux` correctamente.

### 4. Acceder a la Aplicación

¡Listo! La aplicación ya está corriendo. Abre tu navegador y accede a:

- **🗳️ Formulario de Votación**: [http://localhost:8080](http://localhost:8080)
- **📊 Página de Resultados**: [http://localhost:5001](http://localhost:5001)

---

## Gestión de la Aplicación

Aquí tienes los comandos para gestionar los servicios una vez que están en marcha. **Ejecútalos siempre desde tu máquina local.**

### Ver los Logs en Tiempo Real

Para ver los logs de los tres servicios (Vote, Worker y Result) en tiempo real, conéctate a la sesión de `tmux` que está corriendo dentro de la VM.

```bash
vagrant ssh -c "tmux attach -t voting-app"
```

> Para salir de la vista de `tmux` sin detener la aplicación, presiona **`Ctrl+B`** y luego **`D`** (de "detach").

### Detener la Aplicación

Para detener los tres servicios a la vez, simplemente "mata" la sesión de `tmux`.

```bash
vagrant ssh -c "tmux kill-session -t voting-app"
```

---

## Detalles de la Automatización

### `Vagrantfile`

Este archivo define la máquina virtual, sus recursos (RAM, CPU), las redes (reenvío de puertos para acceder a las apps) y, lo más importante, lanza el aprovisionamiento con Ansible.

### `provision.yml`

Este playbook de Ansible es el cerebro de la configuración. Instala y configura todo el software necesario de forma idempotente, garantizando un entorno consistente. Sus tareas clave son:

- **Instalación de Paquetes Optimizada**: Agrupa la instalación de todos los paquetes del sistema (`redis`, `postgresql`, `python`, `node`, etc.) en una única tarea para mayor eficiencia.
- **Bloque Condicional**: Utiliza un bloque `when: ansible_os_family == "Debian"` para ejecutar todas las tareas solo en sistemas Debian, mejorando la legibilidad y reduciendo la redundancia.
- **Gestión Segura de Contraseñas**: Utiliza **Ansible Vault** para encriptar la contraseña de la base de datos, evitando que se almacene en texto plano en el código fuente.
- **Creación de Base de Datos y Usuario**: Crea la base de datos `votes` y establece la contraseña para el usuario `postgres` utilizando la variable almacenada en el vault.
- **Configuración de Autenticación de PostgreSQL**: Añade una regla al archivo `pg_hba.conf` para permitir explícitamente la autenticación con contraseña desde `localhost` (`127.0.0.1`), que es el paso crucial que permite que las aplicaciones se conecten a la base de datos.

### `Gestión de Secretos con Ansible Vault`

Para evitar exponer información sensible (como contraseñas) en el código fuente, el proyecto utiliza **Ansible Vault**.

-   **¿Qué es?** Es una funcionalidad de Ansible que permite encriptar archivos o variables.
-   **¿Cómo se usa aquí?** La contraseña de la base de datos PostgreSQL se almacena en el archivo `secrets.yml`, que está cifrado.
-   **El Proceso Automático:**
    1.  El archivo `Vagrantfile` está configurado para pasar de forma segura la contraseña del "vault" a Ansible durante el aprovisionamiento (`vagrant up`).
    2.  Ansible utiliza esa contraseña para desencriptar `secrets.yml` en memoria.
    3.  Lee la variable `postgres_password` y la usa para configurar la base de datos.

Este mecanismo garantiza que la contraseña nunca esté visible en texto plano en los archivos del proyecto, adhiriéndose a las mejores prácticas de seguridad.

### `iniciar_app.sh`

Este script Bash está diseñado para ser el único punto de entrada para iniciar la aplicación. Utiliza `vagrant ssh -c "..."` para enviar comandos `tmux` a la máquina virtual, creando una sesión con tres paneles donde se ejecuta cada uno de los servicios.
