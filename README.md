# Proyecto Fut

## Requisitos
- Node.js 20+
- Docker + Docker Compose

## Ejecutar
```bash
docker compose up -d
cp apps/api/.env.example apps/api/.env
# opcional: ajustar CORS_ORIGINS en apps/api/.env (por defecto permite http://localhost:*)
npm install
npm run prisma:generate
npm run prisma:migrate
# o en entornos no interactivos:
# npm run prisma:deploy
npm run dev
```

API: `http://localhost:3000/api/v1`
Swagger: `http://localhost:3000/docs`

Si levantas el frontend web en otro puerto, define `CORS_ORIGINS` (separado por comas) en `apps/api/.env`, por ejemplo:
```env
CORS_ORIGINS=http://localhost:58826,http://localhost:3001
```


## Frontend Flutter (web + mobile)
```bash
cd apps/mobile
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```
Para móvil, reemplaza el dispositivo (`-d android` / `-d ios`).


> Nota: en `docker-compose.yml` Postgres se expone en `localhost:55432`.
