FROM ubuntu:22.04

# Evitar prompts interativos durante instalação
ENV DEBIAN_FRONTEND=noninteractive

# Variáveis de ambiente para OpenVSCode Server
ENV OPENVSCODE_SERVER_ROOT="/home/admin/.openvscode-server"
ENV OPENVSCODE_VERSION="1.105.1"

# Instalar dependências básicas e SSH
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    vim \
    nano \
    net-tools \
    iputils-ping \
    git \
    tar \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Configurar SSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN echo "Port 22" >> /etc/ssh/sshd_config

# Criar usuário padrão
RUN useradd -m -s /bin/bash admin && \
    echo 'admin:admin' | chpasswd && \
    usermod -aG sudo admin && \
    echo 'admin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Criar diretórios para serviços web
RUN mkdir -p /var/www/html /etc/nginx /etc/apache2 /home/admin/projects

# Instalar OpenVSCode Server
RUN mkdir -p ${OPENVSCODE_SERVER_ROOT} && \
    cd /tmp && \
    wget -q https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${OPENVSCODE_VERSION}/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz && \
    mv openvscode-server-v${OPENVSCODE_VERSION}-linux-x64/* ${OPENVSCODE_SERVER_ROOT}/ && \
    rm -rf /tmp/openvscode-server-* && \
    chown -R admin:admin ${OPENVSCODE_SERVER_ROOT} && \
    chown -R admin:admin /home/admin

# Script de inicialização melhorado
RUN cat > /start.sh << EOFSCRIPT
#!/bin/bash
# Iniciar SSH
service ssh start

# Iniciar OpenVSCode Server na porta 3000
su - admin -c "cd ${OPENVSCODE_SERVER_ROOT} && ./bin/openvscode-server --host 0.0.0.0 --port 3000 --without-connection-token --server-data-dir /home/admin/.openvscode-server/data --default-user-data-dir /home/admin/.openvscode-server/user-data --extensions-dir /home/admin/.openvscode-server/extensions /home/admin" > /tmp/openvscode.log 2>&1 &

# Aguardar um pouco para o OpenVSCode iniciar
sleep 2

# Exibir informações
echo "=========================================="
echo "🚀 Servidor SSH Linux + OpenVSCode Server"
echo "=========================================="
echo ""
echo "✅ SSH rodando na porta 22"
echo "✅ OpenVSCode Server rodando na porta 3000"
echo ""
echo "📋 Acesso:"
echo "   SSH: ssh -p 2222 admin@localhost"
echo "   IDE: http://localhost:3000"
echo ""
echo "🔐 Credenciais:"
echo "   Usuário: admin"
echo "   Senha: admin"
echo "=========================================="

# Manter container rodando
tail -f /dev/null
EOFSCRIPT
RUN chmod +x /start.sh

# Expor portas
EXPOSE 22 80 443 3000 8080 3001 8081

CMD ["/start.sh"]

