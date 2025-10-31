# 🐧 Servidor SSH Linux + OpenVSCode Server

Container Docker com distribuição Linux (Ubuntu 22.04) configurado com SSH habilitado e **OpenVSCode Server** integrado, permitindo acesso remoto via SSH e uma IDE web completa para gerenciar e desenvolver no servidor.

## 📋 Características

- **Distribuição**: Ubuntu 22.04 LTS
- **SSH**: Habilitado e configurado
- **OpenVSCode Server**: IDE web completa integrada (porta 3000)
- **Usuários**: 
  - `root` (senha: `root`)
  - `admin` (senha: `admin`) - com permissões sudo
- **Portas expostas**: 22 (SSH), 80, 443, 3000 (OpenVSCode), 8080, 3001, 8081, 8000
- **Persistência**: Volumes mapeados para dados, www, projects, logs e configurações do OpenVSCode

## 🚀 Início Rápido

### Pré-requisitos

- Docker instalado
- Docker Compose instalado

### Instalação e Uso

1. **Iniciar o servidor:**
```bash
chmod +x start.sh stop.sh restart.sh logs.sh
./start.sh
```

2. **Acessar via SSH:**
```bash
# Como root
ssh -p 2222 root@localhost

# Como admin
ssh -p 2222 admin@localhost
```

3. **Parar o servidor:**
```bash
./stop.sh
```

4. **Reiniciar:**
```bash
./restart.sh
```

5. **Ver logs:**
```bash
./logs.sh
```

## 🔌 Portas Disponíveis

| Porta | Serviço | Descrição |
|-------|---------|-----------|
| 2222  | SSH     | Acesso SSH (mapeado da porta 22) |
| 80    | HTTP    | Servidor web HTTP |
| 443   | HTTPS   | Servidor web HTTPS |
| 3000  | IDE     | **OpenVSCode Server** - IDE Web completa |
| 8080  | App     | Servidor web alternativo |
| 3001  | App     | Porta adicional para aplicações |
| 8081  | App     | Porta adicional para aplicações |
| 8000  | App     | Porta adicional para aplicações |

## 📁 Estrutura de Diretórios

```
ssh-cliente/
├── Dockerfile              # Configuração da imagem
├── docker-compose.yml      # Configuração do container
├── start.sh                # Script para iniciar
├── stop.sh                 # Script para parar
├── restart.sh              # Script para reiniciar
├── logs.sh                 # Script para ver logs
├── data/                   # Dados persistentes (criado automaticamente)
├── www/                    # Arquivos web (criado automaticamente)
├── projects/               # Projetos de desenvolvimento (criado automaticamente)
└── logs/                   # Logs do container (criado automaticamente)
```

## 💻 OpenVSCode Server - IDE Web

O container inclui o **OpenVSCode Server** pré-instalado e rodando na porta **3000**. É uma versão completa do VS Code acessível via navegador.

### Acessar a IDE Web

1. **Após iniciar o container**, acesse:
   - **Local:** http://localhost:3000
   - **Servidor remoto:** http://20.199.128.167:3000

2. **A IDE já está configurada** para:
   - Acessar arquivos do usuário `admin` (`/home/admin`)
   - Projetos em `/home/admin/projects` (mapeado para `./projects/` local)
   - Extensões e configurações persistentes

### Características do OpenVSCode Server

- ✅ Interface completa do VS Code no navegador
- ✅ Acesso a todos os arquivos do servidor
- ✅ Terminal integrado
- ✅ Extensões do VS Code suportadas
- ✅ Git integrado
- ✅ IntelliSense e autocomplete
- ✅ Debugger integrado

### Workspace Padrão

O OpenVSCode abre automaticamente em `/home/admin`, onde você pode:
- Criar novos projetos
- Acessar arquivos existentes
- Trabalhar com Git
- Instalar extensões via marketplace

**Diretórios mapeados:**
- `./projects/` → `/home/admin/projects` (projetos de desenvolvimento)
- `./data/` → `/home/admin/data` (dados persistentes)
- `./www/` → `/var/www/html` (arquivos web)

## 🛠️ Exemplos de Uso

### Acessar via OpenVSCode Server

1. Inicie o container: `./start.sh`
2. Abra no navegador: http://localhost:3000
3. Use o terminal integrado da IDE para trabalhar
4. Os arquivos em `./projects/` aparecem automaticamente na IDE

### Instalar Nginx dentro do container

Após acessar via SSH:

```bash
sudo apt update
sudo apt install -y nginx
sudo service nginx start
```

Nginx estará disponível em `http://localhost:80`

### Instalar Node.js e criar servidor (use outra porta, pois 3000 é do OpenVSCode)

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Criar servidor simples na porta 8080 (3000 está ocupado pelo OpenVSCode)
cat > /home/admin/server.js << 'EOF'
const http = require('http');
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Servidor Node.js funcionando!\n');
});
server.listen(8080, '0.0.0.0', () => {
  console.log('Servidor rodando na porta 8080');
});
EOF

node /home/admin/server.js
```

**Nota:** A porta 3000 está reservada para o OpenVSCode Server. Use outras portas (8080, 3001, 8081, 8000) para suas aplicações.

### Instalar Apache

```bash
sudo apt install -y apache2
sudo service apache2 start
```

### Acessar arquivos do host

Os diretórios `www/` e `data/` são mapeados para dentro do container:
- `./www` → `/var/www/html` (para arquivos web)
- `./data` → `/home/admin/data` (para dados)

## 🔐 Configuração SSH Avançada

### Usar chaves SSH (recomendado)

1. Gerar chave SSH no seu computador (se não tiver):
```bash
ssh-keygen -t rsa -b 4096
```

2. Copiar chave pública para o container:
```bash
ssh-copy-id -p 2222 admin@localhost
```

3. Depois disso, você pode acessar sem senha!

### Mudar senhas padrão

Acesse o container e execute:
```bash
passwd root
passwd admin
```

## 🐳 Comandos Docker Úteis

```bash
# Entrar no container
docker exec -it ssh-vscode-server /bin/bash

# Ver logs
docker logs ssh-vscode-server

# Ver status
docker ps | grep ssh-vscode-server

# Rebuild da imagem
docker-compose build --no-cache

# Ver processos rodando no container
docker top ssh-vscode-server
```

## 📝 Notas Importantes

- ⚠️ **Segurança**: As senhas padrão são para desenvolvimento. **NUNCA use em produção sem alterar!**
- 🔒 **Produção**: Para uso em produção, configure chaves SSH e desabilite login por senha
- 💾 **Persistência**: Arquivos salvos em `www/`, `data/` e `logs/` são mantidos mesmo após parar o container
- 🌐 **Rede**: O container está em uma rede Docker isolada chamada `ssh-network`

## 🆘 Troubleshooting

### Container não inicia
```bash
docker-compose logs
```

### Porta já em uso
Edite o `docker-compose.yml` e altere as portas mapeadas (ex: `"8080:8080"` para `"8081:8080"`)

### Não consigo acessar via SSH
1. Verifique se o container está rodando: `docker ps`
2. Verifique os logs: `./logs.sh`
3. Tente acessar via: `docker exec -it ssh-vscode-server /bin/bash`

### Reiniciar serviços SSH dentro do container
```bash
docker exec -it ssh-vscode-server service ssh restart
```

### OpenVSCode Server não está acessível
1. Verifique se o processo está rodando:
```bash
docker exec ssh-vscode-server ps aux | grep openvscode
```

2. Verifique os logs do OpenVSCode:
```bash
docker exec ssh-vscode-server cat /tmp/openvscode.log
```

3. Reinicie o container:
```bash
./restart.sh
```

4. Se necessário, inicie manualmente o OpenVSCode:
```bash
docker exec -it ssh-vscode-server su - admin -c "cd /home/admin/.openvscode-server && ./bin/openvscode-server --host 0.0.0.0 --port 3000 --without-connection-token /home/admin"
```

## 📚 Recursos Adicionais

- [Documentação Docker](https://docs.docker.com/)
- [Documentação Docker Compose](https://docs.docker.com/compose/)
- [SSH Ubuntu Guide](https://help.ubuntu.com/community/SSH)
- [OpenVSCode Server GitHub](https://github.com/gitpod-io/openvscode-server)
- [OpenVSCode Server Documentação](https://github.com/gitpod-io/openvscode-server/blob/main/README.md)

