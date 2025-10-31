#!/bin/bash

# Script para migrar de ssh-linux-server para ssh-vscode-server

# Configurações
SSH_KEY="../VPS_key.pem"
SSH_USER="duzaq"
SSH_HOST="20.199.128.167"
REMOTE_DIR="~/ssh-cliente"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Migrando container ssh-linux-server para ssh-vscode-server...${NC}\n"

# Verificar se a chave SSH existe
if [ -f "$SSH_KEY" ]; then
    SSH_KEY_PATH="$SSH_KEY"
elif [ -f "../$SSH_KEY" ]; then
    SSH_KEY_PATH="../$SSH_KEY"
else
    echo -e "${RED}❌ Chave SSH não encontrada${NC}"
    exit 1
fi

# 1. Parar o container antigo
echo -e "${YELLOW}1️⃣ Parando container antigo (ssh-linux-server)...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'cd ~/ssh-cliente && docker compose down 2>/dev/null || docker stop ssh-linux-server 2>/dev/null || echo "Container não estava rodando"'

# 2. Remover container antigo
echo -e "\n${YELLOW}2️⃣ Removendo container antigo...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker rm -f ssh-linux-server 2>/dev/null || echo "Container já foi removido"'

# 3. Verificar se há volumes antigos para limpar (opcional)
echo -e "\n${YELLOW}3️⃣ Verificando volumes...${NC}"
VOLUMES=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker volume ls | grep ssh-cliente || echo "Nenhum volume antigo encontrado"')
echo "$VOLUMES"

# 4. Atualizar arquivos no servidor
echo -e "\n${YELLOW}4️⃣ Atualizando arquivos no servidor...${NC}"
./deploy.sh

# 5. Construir nova imagem
echo -e "\n${YELLOW}5️⃣ Construindo nova imagem com OpenVSCode Server...${NC}"
echo -e "${BLUE}⏳ Isso pode levar alguns minutos (download do OpenVSCode Server)...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && docker compose build --no-cache"

# 6. Iniciar novo container
echo -e "\n${YELLOW}6️⃣ Iniciando novo container (ssh-vscode-server)...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && docker compose up -d"

# 7. Aguardar inicialização
echo -e "\n${YELLOW}7️⃣ Aguardando inicialização...${NC}"
sleep 5

# 8. Verificar status
echo -e "\n${YELLOW}8️⃣ Verificando status do novo container...${NC}"
CONTAINER_STATUS=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" 'docker ps | grep ssh-vscode-server')

if [ -n "$CONTAINER_STATUS" ]; then
    echo -e "${GREEN}✅ Novo container ssh-vscode-server está rodando!${NC}"
    echo ""
    echo "$CONTAINER_STATUS"
    echo ""
    echo -e "${GREEN}📋 Acesso:${NC}"
    echo -e "   ${YELLOW}SSH:${NC} ssh -p 2222 admin@$SSH_HOST"
    echo -e "   ${YELLOW}IDE:${NC} http://$SSH_HOST:3000"
else
    echo -e "${RED}❌ Erro ao iniciar o novo container${NC}"
    echo -e "${YELLOW}Verificando logs...${NC}"
    ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && docker compose logs --tail 50"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Migração concluída com sucesso!${NC}"

