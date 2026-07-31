# Contribuir al Laboratorio Linux

## Estrategia de Ramas

```
main          ← Solo código verificado y probado (releases)
  ↑
  ├── develop ← Mejoras nuevas, features en progreso
  │
  └── fix/*  ← Corrección de errores específicos (se crean bajo demanda)
```

### Reglas

1. **`main`** — Solo se actualiza mediante merge desde `develop` o `fix/*` cuando el código está verificado y pasa CI. Nunca se hace push directo.

2. **`develop`** — Se crea cuando hay una mejora o feature nueva. Se hace push y se abre PR contra `main` cuando está listo. CI debe pasar antes de mergear.

3. **`fix/<descripción>`** — Se crea desde `main` cuando surge un bug. Se corrige, se prueba, se abre PR contra `main`. Una vez mergear, la rama se elimina.

### Flujo de Trabajo

#### Mejora o feature nueva
```bash
git checkout develop
git pull
# ... trabajar ...
git add . && git commit -m "feat: descripción"
git push origin develop
# Abrir PR develop → main
```

#### Corrección de bug
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

### Requisitos antes de mergear a `main`

- [ ] CI pasa (GitHub Actions)
- [ ] Retos existentes siguen funcionando
- [ ] No se rompe la frase secreta ni el progreso
- [ ] Documentación actualizada si aplica

---

## Desarrollo Local

### Prerrequisitos
- Docker Engine 24+ o Docker Desktop
- 4 GB RAM libres

### Setup
```bash
git clone https://github.com/statick88/lab-linux.git
cd lab-linux
docker compose build
docker compose up -d
docker compose exec lab-linux bash
```

### Comandos útiles
```bash
# Ver logs
docker compose logs -f lab-linux

# Reconstruir tras cambios en Dockerfile/entrypoint
docker compose down && docker compose build --no-cache lab-linux && docker compose up -d

# Ejecutar tests
docker compose exec lab-linux bash /shared/test_runner.sh
```
