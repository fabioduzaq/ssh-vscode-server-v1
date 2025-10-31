#!/bin/bash

# Configurações do servidor
SSH_KEY="VPS_key.pem"
SSH_USER="duzaq"
SSH_HOST="20.199.128.167"
REMOTE_DIR="~/ssh-cliente"
LOCAL_DIR="."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Iniciando deploy do servidor SSH Linux para VPS...${NC}\n"

# Verificar se a chave SSH existe (verificar na raiz do projeto primeiro)
if [ -f "../$SSH_KEY" ]; then
    SSH_KEY_PATH="../$SSH_KEY"
elif [ -f "$SSH_KEY" ]; then
    SSH_KEY_PATH="$SSH_KEY"
elif [ -f "../../$SSH_KEY" ]; then
    SSH_KEY_PATH="../../$SSH_KEY"
else
    echo -e "${RED}❌ Chave SSH não encontrada: $SSH_KEY${NC}"
    echo -e "${YELLOW}💡 Dica: Coloque a chave na raiz do projeto ou na pasta ssh-cliente${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Chave SSH encontrada: $SSH_KEY_PATH${NC}"

# Definir permissões da chave
chmod 600 "$SSH_KEY_PATH"

# Testar conexão SSH
echo -e "\n${YELLOW}🔍 Testando conexão SSH...${NC}"
if ! ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$SSH_USER@$SSH_HOST" "echo 'Conexão OK'" 2>/dev/null; then
    echo -e "${RED}❌ Erro ao conectar ao servidor. Verifique:${NC}"
    echo "   - Chave SSH está correta?"
    echo "   - Servidor está acessível?"
    echo "   - Usuário '$SSH_USER' existe?"
    exit 1
fi

echo -e "${GREEN}✓ Conexão SSH estabelecida${NC}"

# Verificar se Docker está instalado
echo -e "\n${YELLOW}🔍 Verificando Docker no servidor...${NC}"
DOCKER_INSTALLED=$(ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "command -v docker" 2>/dev/null)

if [ -z "$DOCKER_INSTALLED" ]; then
    echo -e "${YELLOW}⚠️  Docker não encontrado. Instalando Docker...${NC}"
    ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" << 'EOF'
        # Instalar Docker
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        
        # Adicionar chave GPG oficial do Docker
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Adicionar repositório Docker
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Instalar Docker Engine e Docker Compose
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Adicionar usuário ao grupo docker
        sudo usermod -aG docker $USER
        
        echo "Docker instalado com sucesso!"
EOF
    echo -e "${GREEN}✓ Docker instalado${NC}"
else
    echo -e "${GREEN}✓ Docker já está instalado${NC}"
fi

# Criar diretório remoto
echo -e "\n${YELLOW}📁 Criando diretório no servidor...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "mkdir -p $REMOTE_DIR && mkdir -p $REMOTE_DIR/projects"
echo -e "${GREEN}✓ Diretório criado: $REMOTE_DIR${NC}"

# Fazer upload dos arquivos
echo -e "\n${YELLOW}📤 Enviando arquivos para o servidor...${NC}"

# Arquivos a enviar
FILES=(
    "Dockerfile"
    "docker-compose.yml"
    ".dockerignore"
    "start.sh"
    "stop.sh"
    "restart.sh"
    "logs.sh"
    "README.md"
    "install.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${YELLOW}→${NC} Enviando $file..."
        scp -i "$SSH_KEY_PATH" "$file" "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"
    fi
done

echo -e "${GREEN}✓ Arquivos enviados${NC}"

# Dar permissão de execução aos scripts
echo -e "\n${YELLOW}🔧 Configurando permissões...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && chmod +x *.sh"

# Atualizar scripts para usar 'docker compose' ao invés de 'docker-compose'
echo -e "\n${YELLOW}🔧 Atualizando scripts para usar docker compose...${NC}"
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && \
    sed -i 's/docker-compose/docker compose/g' start.sh stop.sh restart.sh logs.sh"

echo -e "${GREEN}✓ Permissões e scripts configurados${NC}"

# Verificar se precisa fazer logout/login para aplicar grupo docker (apenas aviso)
echo -e "\n${YELLOW}💡 Nota: Se o Docker foi instalado agora, você pode precisar fazer logout/login${NC}"
echo -e "${YELLOW}   ou executar: newgrp docker${NC}"

# Perguntar se quer iniciar agora
echo -e "\n${GREEN}✅ Deploy concluído!${NC}\n"
read -p "Deseja iniciar o container agora? (s/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[SsYy]$ ]]; then
    echo -e "\n${YELLOW}🚀 Iniciando container...${NC}"
    ssh -i "$SSH_KEY_PATH" "$SSH_USER@$SSH_HOST" "cd $REMOTE_DIR && ./start.sh"
    
    echo -e "\n${GREEN}✅ Container iniciado!${NC}"
    echo -e "\n${GREEN}📋 Informações de acesso:${NC}"
    echo -e "   ${YELLOW}SSH:${NC} ssh -p 2222 root@$SSH_HOST"
    echo -e "   ${YELLOW}SSH:${NC} ssh -p 2222 admin@$SSH_HOST"
    echo -e "   ${YELLOW}Senhas padrão:${NC} root/admin"
    echo -e "\n   ${YELLOW}HTTP:${NC} http://$SSH_HOST:80"
    echo -e "   ${YELLOW}Portas:${NC} 3000, 8080, 8081, 3001, 8000"
else
    echo -e "\n${GREEN}Para iniciar manualmente, execute:${NC}"
    echo -e "   ${YELLOW}ssh -i $SSH_KEY_PATH $SSH_USER@$SSH_HOST 'cd $REMOTE_DIR && ./start.sh'${NC}"
fi

echo -e "\n${GREEN}🎉 Deploy finalizado!${NC}"

