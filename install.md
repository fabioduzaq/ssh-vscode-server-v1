# 📦 Guia de Instalação - Servidor SSH Linux Container

## Requisitos

Antes de começar, certifique-se de ter instalado:

- **Docker** (versão 20.10 ou superior)
- **Docker Compose** (versão 2.0 ou superior)

### Verificar instalação

```bash
docker --version
docker-compose --version
```

## Instalação

### Passo 1: Navegar até o diretório

```bash
cd ssh-cliente
```

### Passo 2: Dar permissão de execução aos scripts

```bash
chmod +x start.sh stop.sh restart.sh logs.sh
```

### Passo 3: Iniciar o servidor

```bash
./start.sh
```

O script irá:
- Criar os diretórios necessários (`data/`, `www/`, `logs/`)
- Construir a imagem Docker
- Iniciar o container
- Exibir informações de acesso

### Passo 4: Verificar se está funcionando

```bash
# Verificar se o container está rodando
docker ps | grep ssh-vscode-server

# Ver logs
./logs.sh
```

## Acesso Inicial

### Via SSH

```bash
# Conectar como root
ssh -p 2222 root@localhost

# Conectar como admin
ssh -p 2222 admin@localhost
```

**Senhas padrão:**
- Usuário `root`: senha `root`
- Usuário `admin`: senha `admin`

⚠️ **IMPORTANTE**: Altere as senhas após o primeiro acesso!

### Via Docker Exec

```bash
docker exec -it ssh-vscode-server /bin/bash
```

## Primeiros Passos após Acesso

### 1. Alterar senhas

```bash
passwd root
passwd admin
```

### 2. Atualizar sistema

```bash
apt update && apt upgrade -y
```

### 3. Instalar ferramentas úteis

```bash
apt install -y \
    nginx \
    apache2 \
    nodejs \
    npm \
    python3 \
    python3-pip
```

## Configuração Opcional

### Personalizar portas

Edite o arquivo `docker-compose.yml` para alterar as portas mapeadas:

```yaml
ports:
  - "2222:22"      # SSH
  - "8080:80"      # HTTP (exemplo: usar 8080 ao invés de 80)
  # ... outras portas
```

### Adicionar volumes

Para adicionar mais volumes, edite `docker-compose.yml`:

```yaml
volumes:
  - ./data:/home/admin/data
  - ./www:/var/www/html
  - ./seu-novo-dir:/caminho/no/container
```

## Desinstalação

Para remover completamente:

```bash
# Parar e remover container
./stop.sh
docker-compose down -v

# Remover imagem (opcional)
docker rmi ssh-cliente-ssh-server
```

## Verificação Pós-Instalação

Após a instalação, teste:

1. ✅ Container está rodando: `docker ps`
2. ✅ SSH acessível: `ssh -p 2222 root@localhost`
3. ✅ Portas abertas: `netstat -an | grep -E '2222|80|443|3000|8080'`
4. ✅ Volumes criados: `ls -la data/ www/ logs/`

## Suporte

Se encontrar problemas:

1. Verifique os logs: `./logs.sh`
2. Verifique o status do Docker: `docker ps -a`
3. Reconstrua a imagem: `docker-compose build --no-cache`
4. Consulte o README.md para mais detalhes

