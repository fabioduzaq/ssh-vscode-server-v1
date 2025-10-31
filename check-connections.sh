#!/bin/bash

# Configurações
SSH_KEY="../VPS_key.pem"
SSH_USER="duzaq"
SSH_HOST="20.199.128.167"
CONTAINER_PORT="2222"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Verificando conexões do container SSH Linux...${NC}\n"

# Verificar se a chave existe
if [ -f "$SSH_KEY" ]; then
    SSH_KEY_PATH="$SSH_KEY"
elif [ -f "../$SSH_KEY" ]; then
    SSH_KEY_PATH="../$SSH_KEY"
else
    echo -e "${RED}❌ Chave SSH não encontrada${NC}"
    exit 1
fi

# 1. Status do Container
echo -e "${YELLOW}1️⃣ Status do Container:${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker ps --filter "name=ssh-vscode-server" --format "table {{.ID}}\t{{.Status}}\t{{.Ports}}"'

echo ""

# 2. Portas expostas
echo -e "${YELLOW}2️⃣ Portas expostas no host:${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker port ssh-vscode-server'

echo ""

# 3. Status do SSH dentro do container
echo -e "${YELLOW}3️⃣ Status do serviço SSH no container:${NC}"
SSH_STATUS=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker exec ssh-vscode-server service ssh status 2>&1')
if echo "$SSH_STATUS" | grep -q "running"; then
    echo -e "${GREEN}✓ SSH está rodando${NC}"
else
    echo -e "${RED}✗ SSH não está rodando${NC}"
    echo "$SSH_STATUS"
fi

echo ""

# 4. Porta SSH escutando no container
echo -e "${YELLOW}4️⃣ Porta SSH (22) escutando no container:${NC}"
PORT_CHECK=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker exec ssh-vscode-server netstat -tlnp 2>/dev/null | grep :22 || docker exec ssh-vscode-server ss -tlnp 2>/dev/null | grep :22')
if [ -n "$PORT_CHECK" ]; then
    echo -e "${GREEN}✓ Porta 22 está escutando${NC}"
    echo "$PORT_CHECK"
else
    echo -e "${RED}✗ Porta 22 não está escutando${NC}"
fi

echo ""

# 5. Informações do container
echo -e "${YELLOW}5️⃣ Informações do sistema no container:${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" << 'EOF'
    echo "Hostname: $(docker exec ssh-vscode-server hostname)"
    echo "Usuário atual: $(docker exec ssh-vscode-server whoami)"
    echo "Sistema: $(docker exec ssh-vscode-server cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo ""
    echo "Usuários disponíveis:"
    docker exec ssh-vscode-server cat /etc/passwd | grep -E "root|admin" | awk -F: '{print "  - " $1 " (UID: " $3 ", Shell: " $7 ")"}'
EOF

echo ""

# 6. Teste de conexão SSH (via container)
echo -e "${YELLOW}6️⃣ Testando acesso SSH local (dentro do container):${NC}"
SSH_TEST=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker exec ssh-vscode-server ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 root@localhost "echo SUCCESS && whoami" 2>&1')
if echo "$SSH_TEST" | grep -q "SUCCESS"; then
    echo -e "${GREEN}✓ SSH local funcionando${NC}"
    echo "$SSH_TEST"
else
    echo -e "${YELLOW}⚠ SSH local pode precisar de senha${NC}"
fi

echo ""

# 7. Teste de conexão SSH externa
echo -e "${YELLOW}7️⃣ Testando conexão SSH externa (porta 2222):${NC}"
echo -e "${BLUE}Tentando conectar como root...${NC}"

# Tentar conexão não-interativa
ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$CONTAINER_PORT" root@"$SSH_HOST" 'echo "✓ Conexão SSH externa funcionando!" && echo "Usuário: $(whoami)" && echo "Hostname: $(hostname)" && echo "IP: $(hostname -I)"' 2>&1 | head -10

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✓ Conexão SSH externa OK${NC}"
else
    echo -e "${YELLOW}⚠ Teste manual necessário (pode precisar de senha)${NC}"
    echo -e "   Execute: ${BLUE}ssh -p $CONTAINER_PORT root@$SSH_HOST${NC}"
fi

echo ""

# 8. Resumo das portas
echo -e "${YELLOW}8️⃣ Resumo de Portas Disponíveis:${NC}"
echo -e "   ${GREEN}SSH:${NC}     $SSH_HOST:$CONTAINER_PORT (mapeado da porta 22 do container)"
echo -e "   ${GREEN}HTTP:${NC}    http://$SSH_HOST:80"
echo -e "   ${GREEN}HTTPS:${NC}   https://$SSH_HOST:443"
echo -e "   ${GREEN}App 1:${NC}   http://$SSH_HOST:3000"
echo -e "   ${GREEN}App 2:${NC}   http://$SSH_HOST:8080"
echo -e "   ${GREEN}App 3:${NC}   http://$SSH_HOST:3001"
echo -e "   ${GREEN}App 4:${NC}   http://$SSH_HOST:8081"
echo -e "   ${GREEN}App 5:${NC}   http://$SSH_HOST:8000"

echo ""
echo -e "${GREEN}✅ Verificação concluída!${NC}"
echo ""
echo -e "${BLUE}Para conectar via SSH:${NC}"
echo -e "   ${YELLOW}ssh -p $CONTAINER_PORT root@$SSH_HOST${NC}  (senha: root)"
echo -e "   ${YELLOW}ssh -p $CONTAINER_PORT admin@$SSH_HOST${NC}  (senha: admin)"

