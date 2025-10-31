#!/bin/bash

echo "🚀 Iniciando servidor SSH Linux..."

# Criar diretórios necessários
mkdir -p data www logs projects

# Construir e iniciar o container
docker compose up -d --build

# Aguardar o container iniciar
sleep 3

# Verificar status
if docker ps | grep -q ssh-vscode-server; then
    echo "✅ Container iniciado com sucesso!"
    echo ""
    echo "📋 Informações de Acesso SSH:"
    echo "   Host: localhost"
    echo "   Porta: 2222"
    echo "   Usuário root: root / Senha: root"
    echo "   Usuário admin: admin / Senha: admin"
    echo ""
    echo "🔌 Portas expostas:"
    echo "   SSH:    localhost:2222"
    echo "   HTTP:   localhost:80"
    echo "   HTTPS:  localhost:443"
    echo "   IDE:    http://localhost:3000 (OpenVSCode Server)"
    echo "   App 2:  localhost:8080"
    echo "   App 3:  localhost:3001"
    echo "   App 4:  localhost:8081"
    echo ""
    echo "📝 Para acessar via SSH:"
    echo "   ssh -p 2222 root@localhost"
    echo "   ou"
    echo "   ssh -p 2222 admin@localhost"
    echo ""
    echo "💻 Para acessar o OpenVSCode Server (IDE Web):"
    echo "   http://localhost:3000"
    echo "   ou"
    echo "   http://20.199.128.167:3000 (servidor remoto)"
    echo ""
    echo "🛠️  Para entrar no container:"
    echo "   docker exec -it ssh-vscode-server /bin/bash"
else
    echo "❌ Erro ao iniciar o container"
    docker compose logs
fi

