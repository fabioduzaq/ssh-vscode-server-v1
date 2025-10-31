# 📝 Changelog - Integração OpenVSCode Server

## Versão 2.0 - Adição do OpenVSCode Server

### ✅ Mudanças Aplicadas

#### 1. Dockerfile
- ✅ Adicionada variável de ambiente `OPENVSCODE_VERSION="1.105.1"`
- ✅ Adicionada variável `OPENVSCODE_SERVER_ROOT="/home/admin/.openvscode-server"`
- ✅ Instaladas dependências `tar` e `gzip` necessárias
- ✅ Adicionado download e instalação automática do OpenVSCode Server
- ✅ Configurado script de inicialização para iniciar SSH + OpenVSCode Server
- ✅ OpenVSCode Server configurado para rodar na porta 3000
- ✅ Permissões corretas configuradas para usuário `admin`

#### 2. docker-compose.yml
- ✅ Adicionado volume `./projects:/home/admin/projects` para projetos
- ✅ Adicionado volume Docker `openvscode-data` para persistência de dados do OpenVSCode
- ✅ Adicionada variável de ambiente `OPENVSCODE_SERVER_ROOT`
- ✅ Comentário atualizado na porta 3000 (agora é OpenVSCode Server)

#### 3. start.sh
- ✅ Criado diretório `projects/` automaticamente
- ✅ Atualizada mensagem de informações para incluir OpenVSCode Server
- ✅ Adicionadas instruções de acesso à IDE web

#### 4. README.md
- ✅ Título atualizado: "Servidor SSH Linux + OpenVSCode Server"
- ✅ Adicionada seção completa sobre OpenVSCode Server
- ✅ Documentação de acesso à IDE web
- ✅ Características do OpenVSCode listadas
- ✅ Workspace padrão documentado
- ✅ Exemplos de uso atualizados
- ✅ Seção de troubleshooting para OpenVSCode
- ✅ Links para documentação do OpenVSCode Server

#### 5. deploy.sh
- ✅ Atualizado para criar diretório `projects/` no servidor remoto

#### 6. Estrutura de Diretórios
- ✅ Criado diretório `projects/` para projetos de desenvolvimento

### 🔧 Configurações do OpenVSCode Server

**Porta:** 3000  
**Host:** 0.0.0.0 (acessível externamente)  
**Autenticação:** Sem token (sem conexão token)  
**Workspace:** `/home/admin`  
**Dados:** `/home/admin/.openvscode-server` (volume persistente)  
**Usuário:** admin  

### 📦 Versão do OpenVSCode Server

**Versão instalada:** 1.105.1 (latest stable)  
**Fonte:** GitHub Releases - gitpod-io/openvscode-server

### 🚀 Como Usar

1. **Rebuild do container:**
```bash
cd ssh-cliente
docker compose build --no-cache
./start.sh
```

2. **Acessar OpenVSCode Server:**
   - Local: http://localhost:3000
   - Remoto: http://20.199.128.167:3000

3. **Acessar via SSH (como antes):**
```bash
ssh -p 2222 admin@localhost
# senha: admin
```

### 📁 Arquivos Modificados

- `Dockerfile`
- `docker-compose.yml`
- `start.sh`
- `README.md`
- `deploy.sh`

### 📁 Arquivos Criados

- `projects/` (diretório)
- `CHANGELOG-OPENVSCODE.md` (este arquivo)

### ⚠️ Observações Importantes

1. **Porta 3000**: Agora está reservada para o OpenVSCode Server. Use outras portas (8080, 3001, 8081, 8000) para suas aplicações.

2. **Primeira inicialização**: A primeira vez que o container iniciar, o download e instalação do OpenVSCode Server pode levar alguns minutos.

3. **Dados persistentes**: As configurações, extensões e dados do OpenVSCode são salvos no volume Docker `openvscode-data`, garantindo persistência mesmo após recriar o container.

4. **Acesso aos arquivos**: O OpenVSCode Server tem acesso completo aos arquivos do usuário `admin`, incluindo:
   - `/home/admin/projects` → `./projects/` (local)
   - `/home/admin/data` → `./data/` (local)
   - Todos os arquivos do sistema (com permissões sudo do admin)

### 🔄 Próximos Passos

Para usar no servidor remoto:
```bash
cd ssh-cliente
./deploy.sh
# Aguardar deploy e rebuild
ssh -i VPS_key.pem duzaq@20.199.128.167 'cd ~/ssh-cliente && docker compose build --no-cache && ./start.sh'
```

---

**Data:** $(date +%Y-%m-%d)  
**Versão OpenVSCode:** 1.105.1

