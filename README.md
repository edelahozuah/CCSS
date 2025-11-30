# Escenarios de Comunicaciones Seguras (CCSS)

Este repositorio contiene una colección de escenarios prácticos relacionados con Infraestructura de Clave Pública (PKI) y seguridad de redes para la asignatura **Comunicaciones Seguras** del **Máster Universitario en Ciberseguridad** de la **Universidad de Alcalá**.

Cada subdirectorio representa un escenario o laboratorio específico diseñado para que los estudiantes experimenten con distintos aspectos de la seguridad.

## Estructura del Repositorio

A continuación se describen brevemente los escenarios incluidos:

| Escenario | Descripción |
| :--- | :--- |
| [**ca_compromise**](./ca_compromise) | Escenario que simula el compromiso de una Autoridad de Certificación. |
| [**certstream_phishing**](./certstream_phishing) | Herramientas y laboratorios para la detección de dominios sospechosos usando Certificate Transparency. |
| [**mitmproxy**](./mitmproxy) | Escenarios de interceptación de tráfico y ataques Man-in-the-Middle utilizando mitmproxy. |
| [**pki-lab**](./pki-lab) | Laboratorio completo de despliegue y gestión de una PKI. |
| [**pki-lab-simple**](./pki-lab-simple) | Versión simplificada del laboratorio de PKI para conceptos introductorios. |
| [**superfish**](./superfish) | Recreación de la vulnerabilidad Superfish (intercepción SSL/TLS mediante CA raíz comprometida). |
| [**certificate-transparency**](./certificate-transparency) | Recursos relacionados con la transparencia de certificados. |
| [**test_pki**](./test_pki) | Directorio de pruebas para configuraciones de PKI. |

## Requisitos

La mayoría de los escenarios están basados en **Docker** y **Docker Compose**. Asegúrese de tener instaladas estas herramientas para ejecutar los laboratorios.

## Uso

Navegue al directorio de cada escenario y consulte el `README.md` específico (si existe) para instrucciones detalladas de despliegue y ejecución.

```bash
cd nombre_del_escenario
# Ejemplo de ejecución común
docker-compose up -d
```
