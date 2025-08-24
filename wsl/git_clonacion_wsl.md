# **Guía para Clonar Repositorios en WSL**

Este documento resume los pasos correctos para **clonar un repositorio
de Git** en **WSL** evitando errores de permisos.

------------------------------------------------------------------------

## **1. Problema Encontrado**

Cuando intentamos clonar desde la raíz del sistema:

``` bash
mily@SWOPF59M84S:/$ git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
fatal: could not create work tree dir 'creating-cicd-pipelines-with-tekton-2': Permission denied
```

El error ocurre porque estábamos en la raíz (`/`) y no tenemos permisos
para escribir allí.

------------------------------------------------------------------------

## **2. Solución Correcta**

### **Paso 1 --- Ir al directorio home**

``` bash
cd ~
```

### **Paso 2 --- Verificar ubicación actual**

``` bash
pwd
```

Debe mostrar:

    /home/mily

### **Paso 3 --- Clonar el repositorio**

``` bash
git clone https://github.com/milymoreno/creating-cicd-pipelines-with-tekton-2
```

------------------------------------------------------------------------

## **3. Resultado Esperado**

Si todo está correcto, verás algo como:

    Cloning into 'creating-cicd-pipelines-with-tekton-2'...
    remote: Enumerating objects...
    remote: Counting objects...
    Receiving objects...
    Resolving deltas...

El repositorio quedará disponible en:

    /home/mily/creating-cicd-pipelines-with-tekton-2

------------------------------------------------------------------------

## **4. Notas**

-   **Nunca clones repositorios directamente en `/`**, eso genera
    errores de permisos.
-   Siempre usa tu **home** o un directorio donde tengas privilegios de
    escritura.

------------------------------------------------------------------------

**Autor:** Mily 🚀\
**Tema:** Instalación y configuración de Git en WSL\
**Última actualización:** 2025-08-19
