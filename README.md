# KotSuppliesApp

**KotSuppliesApp** is de ultieme oplossing voor studenten om hun gezamenlijke of individuele voorraad op kot moeiteloos te beheren. Nooit meer onverwacht zonder pasta, melk of toiletpapier!

Deze applicatie combineert een krachtige NestJS backend met een intuïtieve Flutter frontend, volledig containerized met Docker voor eenvoudige installatie en deployment.

## Features

- **Voorraadbeheer:** Houd precies bij wat er nog in de kast ligt en wat bijna op is.
- **Gezamenlijke Lijstjes:** Maak boodschappenlijstjes aan die gedeeld kunnen worden met huisgenoten.
- **Categorisering:** Organiseer je items per categorie (bijv. Voeding, Poetsmiddelen, Drank).
- **Afbeeldingen:** Voeg foto's toe aan items voor visuele herkenning.
- **Notificaties:** Ontvang herinneringen wanneer producten de vervaldatum naderen of wanneer de voorraad laag is.

## Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Multi-platform: Web, Windows, Linux)
- **Backend:** [NestJS](https://nestjs.com/) (Node.js framework)
- **Database:** SQLite via [TypeORM](https://typeorm.io/)
- **Containerization:** [Docker](https://www.docker.com/) & Docker Compose

## Configuratie

De backend maakt gebruik van de volgende omgevingsvariabelen. Zorg dat je een `.env` bestand aanmaakt in de `backend` map.

| Variabele     | Beschrijving                                   | Standaardwaarde          |
| :------------ | :--------------------------------------------- | :----------------------- |
| `PORT`        | De poort waarop de NestJS server draait.       | `3000`                   |
| :------------ | :--------------------------------------------- | :----------------------- |
| `kApiBaseUrl` | De base-URL voor de API gebruikt door Flutter. | `'http://10.0.2.2:3000'` |

## Project Structuur

- `/backend`: De NestJS broncode, controllers, entiteiten en migraties.
- `/frontend`: De Flutter applicatie voor mobiel, desktop en web.
