#!/bin/bash
# ============================================================================
# student-setup.sh — Per-reto state simulation for automated testing
# ============================================================================
# ARCHITECTURE: Unit-namespaced setup functions.
# Each unit defines: _setup_<unit>_reto<N>()
# The dispatcher: setup_for_unit_reto <unit> <reto> calls the right one.
# ============================================================================

# Shared: ensure base directories exist
_setup_base_dirs() {
    mkdir -p ~/laboratorio/shell 2>/dev/null
    mkdir -p /root/laboratorio/backup/datos 2>/dev/null
    if [ ! -f /root/laboratorio/backup/datos/usuarios.txt ]; then
        echo "root:x:0:0:root:/root:/bin/bash" > /root/laboratorio/backup/datos/usuarios.txt
        echo "estudiante:x:1001:1001::/home/estudiante:/bin/bash" >> /root/laboratorio/backup/datos/usuarios.txt
    fi
    if [ ! -f /root/laboratorio/backup/datos/configuracion.txt ]; then
        echo "hostname=lab-server" > /root/laboratorio/backup/datos/configuracion.txt
    fi
}

# ============================================================================
# UNIT I — File System Navigation (no special setup needed)
# ============================================================================
# All retos pass without state — define no-ops
for i in $(seq 1 10); do
    eval "_setup_i_reto$i() { :; }"
done

# ============================================================================
# UNIT II — Package Management
# ============================================================================
_ensure_curl_installed() {
    dpkg -l curl 2>/dev/null | grep -q "^ii" || sudo -n apt-get install -y curl >/dev/null 2>&1
}

_ensure_vim_installed() {
    dpkg -l vim 2>/dev/null | grep -q "^ii" || sudo -n apt-get install -y vim >/dev/null 2>&1
}

_setup_ii_reto1() { :; }
_setup_ii_reto2() { _ensure_vim_installed; }
_setup_ii_reto3() {
    dpkg -l curl 2>/dev/null | grep -q "^ii" || sudo -n apt-get install -y curl >/dev/null 2>&1
    dpkg -l tree 2>/dev/null | grep -q "^ii" || sudo -n apt-get install -y tree >/dev/null 2>&1
}
_setup_ii_reto4() { _ensure_vim_installed; }
_setup_ii_reto5() { _ensure_vim_installed; }
_setup_ii_reto6() { _ensure_vim_installed; }
_setup_ii_reto7() { _ensure_vim_installed; }
_setup_ii_reto8() { _ensure_vim_installed; }
_setup_ii_reto9() {
    # Student removes vim; validator checks it's gone
    if dpkg -l vim 2>/dev/null | grep -q "^ii"; then
        sudo -n apt-get remove -y vim >/dev/null 2>&1 || true
    fi
}
_setup_ii_reto10() {
    rm -rf /etc/curl 2>/dev/null
    if dpkg -l curl 2>/dev/null | grep -q "^ii"; then
        sudo -n apt-get purge -y curl >/dev/null 2>&1
    fi
}

# ============================================================================
# UNIT III — Shell Scripting
# ============================================================================
_create_all_shell_scripts() {
    local dir=~/laboratorio/shell
    mkdir -p "$dir"

    if [ ! -f "$dir/saludar.sh" ] || ! head -20 "$dir/saludar.sh" 2>/dev/null | grep -q "hola"; then
        cat > "$dir/saludar.sh" << 'EOF'
#!/bin/bash
echo "Hola, Mundo!"
echo "Bienvenido al curso de Linux"
EOF
        chmod +x "$dir/saludar.sh"
    fi

    if [ ! -f "$dir/pedir_nombre.sh" ] || ! head -30 "$dir/pedir_nombre.sh" 2>/dev/null | grep -q "read"; then
        cat > "$dir/pedir_nombre.sh" << 'EOF'
#!/bin/bash
echo "¿Cuál es tu nombre?"
read nombre
echo "Hola, $nombre!"
EOF
        chmod +x "$dir/pedir_nombre.sh"
    fi

    if [ ! -f "$dir/par_o_impar.sh" ] || ! head -30 "$dir/par_o_impar.sh" 2>/dev/null | grep -q "if"; then
        cat > "$dir/par_o_impar.sh" << 'EOF'
#!/bin/bash
numero=$1
if [ $((numero % 2)) -eq 0 ]; then
    echo "Par"
else
    echo "Impar"
fi
EOF
        chmod +x "$dir/par_o_impar.sh"
    fi

    if [ ! -f "$dir/contar.sh" ] || ! head -30 "$dir/contar.sh" 2>/dev/null | grep -q "for"; then
        cat > "$dir/contar.sh" << 'EOF'
#!/bin/bash
for i in 1 2 3 4 5; do
    echo "Número: $i"
done
EOF
        chmod +x "$dir/contar.sh"
    fi

    if [ ! -f "$dir/contar_while.sh" ] || ! head -30 "$dir/contar_while.sh" 2>/dev/null | grep -q "while"; then
        cat > "$dir/contar_while.sh" << 'EOF'
#!/bin/bash
contador=1
while [ $contador -le 5 ]; do
    echo "Contador: $contador"
    contador=$((contador + 1))
done
EOF
        chmod +x "$dir/contar_while.sh"
    fi

    if [ ! -f "$dir/sumar.sh" ] || ! head -20 "$dir/sumar.sh" 2>/dev/null | grep -q "function"; then
        cat > "$dir/sumar.sh" << 'EOF'
#!/bin/bash
function sumar {
    echo $(( $1 + $2 ))
}
echo "Suma: $(sumar 3 5)"
EOF
        chmod +x "$dir/sumar.sh"
    fi

    if [ ! -f "$dir/frutas.sh" ] || ! head -20 "$dir/frutas.sh" 2>/dev/null | grep -q "arr"; then
        cat > "$dir/frutas.sh" << 'EOF'
#!/bin/bash
arr=("manzana" "plátano" "naranja" "uva")
for fruta in "${arr[@]}"; do
    echo "Fruta: $fruta"
done
EOF
        chmod +x "$dir/frutas.sh"
    fi

    if [ ! -f "$dir/procesar.sh" ] || ! head -20 "$dir/procesar.sh" 2>/dev/null | grep -qE '\$\{?1\}?'; then
        cat > "$dir/procesar.sh" << 'EOF'
#!/bin/bash
archivo=$1
if [ -f "$archivo" ]; then
    echo "Procesando: $archivo"
    wc -l "$archivo"
else
    echo "Archivo no encontrado: $archivo"
fi
EOF
        chmod +x "$dir/procesar.sh"
    fi

    if [ ! -f "$dir/backup_simple.sh" ] || ! head -20 "$dir/backup_simple.sh" 2>/dev/null | grep -q ">"; then
        cat > "$dir/backup_simple.sh" << 'EOF'
#!/bin/bash
destino="/tmp/backup_$(date +%Y%m%d).txt"
echo "Backup creado: $destino" > "$destino"
ls -la ~/laboratorio/ >> "$destino"
echo "Backup completado"
EOF
        chmod +x "$dir/backup_simple.sh"
    fi

    if [ ! -f "$dir/color_favorito.sh" ] || ! head -20 "$dir/color_favorito.sh" 2>/dev/null | grep -q "trap"; then
        cat > "$dir/color_favorito.sh" << 'EOF'
#!/bin/bash
trap 'echo "Error detectado en línea $LINENO"' ERR
color="azul"
if [ "$color" = "azul" ]; then
    echo "Mi color favorito es azul"
fi
echo "Script completado"
EOF
        chmod +x "$dir/color_favorito.sh"
    fi
}

for i in $(seq 1 10); do
    eval "_setup_iii_reto$i() { _create_all_shell_scripts; }"
done

# ============================================================================
# UNIT IV — User Management
# ============================================================================
_create_practicante_user() {
    sudo -n getent group desarrolladores >/dev/null 2>&1 || sudo -n groupadd desarrolladores 2>/dev/null
    if ! id practicante >/dev/null 2>&1; then
        sudo -n useradd -m -d /home/practicante -s /bin/bash practicante 2>/dev/null
    fi
    echo "practicante:password123" | sudo -n chpasswd 2>/dev/null
    sudo -n mkdir -p /home/practicante 2>/dev/null
    sudo -n chown practicante:practicante /home/practicante 2>/dev/null
    sudo -n chmod 755 /home/practicante 2>/dev/null
    sudo -n usermod -aG desarrolladores practicante 2>/dev/null
    sudo -n usermod -s /bin/sh practicante 2>/dev/null
    echo "Archivo de practicante" | sudo -n tee /tmp/archivo_practicante.txt > /dev/null 2>&1
    sudo -n chown practicante:practicante /tmp/archivo_practicante.txt 2>/dev/null
    mkdir -p /tmp/proyecto 2>/dev/null
    sudo -n chmod 755 /tmp/proyecto 2>/dev/null
}

# Unit IV reto1-8: user must exist with all properties
for i in 1 2 3 4 5 6 7 8; do
    eval "_setup_iv_reto$i() { _create_practicante_user; }"
done

# Unit IV reto9: user must NOT exist
_setup_iv_reto9() {
    if id practicante >/dev/null 2>&1; then
        sudo -n userdel -r practicante 2>/dev/null
    fi
    rm -f /tmp/archivo_practicante.txt 2>/dev/null
    rm -rf /tmp/proyecto 2>/dev/null
}



# Unit IV reto10: user AND group must NOT exist
_setup_iv_reto10() {
    if id practicante >/dev/null 2>&1; then
        sudo -n userdel -r practicante 2>/dev/null
    fi
    if getent group desarrolladores >/dev/null 2>&1; then
        sudo -n groupdel desarrolladores 2>/dev/null
    fi
    rm -f /tmp/archivo_practicante.txt 2>/dev/null
    rm -rf /tmp/proyecto 2>/dev/null
}

# ============================================================================
# UNIT V — Permissions & Ownership (no special setup needed)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_v_reto$i() { :; }"
done

# ============================================================================
# UNIT VI — Text Processing (no special setup needed)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_vi_reto$i() { :; }"
done

# ============================================================================
# UNIT VII — Process Management (no special setup needed)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_vii_reto$i() { :; }"
done

# ============================================================================
# UNIT VIII — Docker (no special setup needed; reto10 skipped by runner)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_viii_reto$i() { :; }"
done

# ============================================================================
# UNIT IX — Web Server (needs curl for validator checks)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_ix_reto$i() { _ensure_curl_installed; }"
done

# ============================================================================
# UNIT X — Networking (no special setup needed)
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_x_reto$i() { :; }"
done

# ============================================================================
# UNIT XI — Backup & Recovery
# ============================================================================
for i in $(seq 1 10); do
    eval "_setup_xi_reto$i() { _setup_base_dirs; }"
done

# XI reto3-4 need /root/laboratorio/backup/datos/ accessible to estudiante
_setup_xi_reto2() {
    _setup_base_dirs
    sudo -n mkdir -p /root/laboratorio/backup/datos
    sudo -n chmod 755 /root
    sudo -n chmod -R 777 /root/laboratorio
}
_setup_xi_reto3() {
    _setup_base_dirs
    sudo -n mkdir -p /root/laboratorio/backup/datos
    sudo -n chmod 755 /root
    sudo -n chmod -R 777 /root/laboratorio
}
_setup_xi_reto4() {
    _setup_base_dirs
    sudo -n mkdir -p /root/laboratorio/backup/datos
    sudo -n chmod 755 /root
    sudo -n chmod -R 777 /root/laboratorio
}

# ============================================================================
# DISPATCHER — called by run-all-retos.sh
# ============================================================================
setup_for_unit_reto() {
    local unit="$1"
    local reto="$2"
    local func="_setup_${unit}_reto${reto}"
    if type "$func" >/dev/null 2>&1; then
        "$func"
    fi
}
