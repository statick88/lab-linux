# Contribuir al Laboratorio Linux

## Estrategia de Ramas

```
main          ← Solo código verificado y probado (releases)
  ↑
  ├── develop ← Mejoras nuevas, features en progreso
  │
  └── fix/*  ← Corrección de errores específicos (se crean bajo demanda)
```

| Rama | Regla | Ejemplo |
|------|-------|---------|
| `main` | Solo merge desde `develop` o `fix/*`. Nunca push directo. | — |
| `develop` | Features y mejoras en progreso. PR contra `main` cuando está listo. | `feat: agregar reto de awk` |
| `fix/<nombre>` | Se crea desde `main`, se corrifica, se mergea, se elimina. | `fix/permisos-reto-5` |

---

## Flujo de Trabajo

### Feature nueva

```bash
git checkout develop
git pull
# ... trabajar ...
git add . && git commit -m "feat: descripción"
git push origin develop
# Abrir PR develop → main
```

### Corrección de bug

```bash
git checkout main
git pull
git checkout -b fix/nombre-del-bug
# ... corregir ...
git add . && git commit -m "fix: descripción"
git push origin fix/nombre-del-bug
# Abrir PR fix/* → main
# Una vez mergeado, eliminar la rama
```

---

## Checklist antes de mergear a `main`

- [ ] CI pasa (GitHub Actions)
- [ ] Retos existentes siguen funcionando
- [ ] No se rompe la frase secreta ni el progreso
- [ ] Documentación actualizada si aplica

---

## Desarrollo Local

### Setup

```bash
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Comandos útiles

| Comando | Qué hace |
|---------|----------|
| `docker compose logs -f lab-linux` | Ver logs en tiempo real |
| `docker compose down && docker compose build --no-cache lab-linux && docker compose up -d` | Reconstruir tras cambios en Dockerfile/entrypoint |
| `docker compose exec lab-linux bash /shared/test_runner.sh` | Ejecutar tests |
