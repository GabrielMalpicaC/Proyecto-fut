# Proyecto Fut

## Requisitos
- Node.js 20+
- Docker + Docker Compose

## Ejecutar
```bash
docker compose up -d
cp apps/api/.env.example apps/api/.env
npm install
npm run prisma:generate
npm run prisma:migrate
npm run dev
```

API: `http://localhost:3000/api/v1`
Swagger: `http://localhost:3000/docs`
