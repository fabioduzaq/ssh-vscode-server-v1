# 📊 Relatório de Conexões - Container SSH Linux

## ✅ Status Geral

**Container:** ssh-vscode-server  
**Status:** ✅ Rodando  
**Tempo online:** Ativo desde a instalação

## 🔌 Portas Verificadas

### Portas expostas no host (VPS):
- ✅ **Porta 2222** → Container porta 22 (SSH)
- ✅ **Porta 80** → Container porta 80 (HTTP)
- ✅ **Porta 443** → Container porta 443 (HTTPS)
- ✅ **Porta 3000** → Container porta 3000
- ✅ **Porta 3001** → Container porta 3001
- ✅ **Porta 8000** → Container porta 8000
- ✅ **Porta 8080** → Container porta 8080
- ✅ **Porta 8081** → Container porta 8081

### Portas escutando no container:
- ✅ Porta 22 (SSH) está escutando em 0.0.0.0:22 (IPv4)
- ✅ Porta 22 (SSH) está escutando em [::]:22 (IPv6)

## 🔐 Serviço SSH

**Status:** ✅ Rodando  
**Processo:** sshd (/usr/sbin/sshd)  
**Configuração:**
- Port: 22
- PermitRootLogin: yes
- PasswordAuthentication: yes
- PubkeyAuthentication: yes

## 👥 Usuários Disponíveis

1. **root**
   - UID: 0
   - Shell: /bin/bash
   - Senha: `root`

2. **admin**
   - UID: 1000
   - Shell: /bin/bash
   - Senha: `admin`
   - Permissões: sudo (sem senha)

## 🌐 Informações do Sistema

- **Hostname:** ssh-server
- **Sistema Operacional:** Ubuntu 22.04.5 LTS
- **IP Interno:** 172.16.0.4 (rede Docker)

## 🔗 Como Conectar

### Via SSH (Porta 2222):
```bash
# Como root
ssh -p 2222 root@20.199.128.167
# Senha: root

# Como admin
ssh -p 2222 admin@20.199.128.167
# Senha: admin
```

### URLs de Acesso:
- HTTP: http://20.199.128.167:80
- HTTPS: https://20.199.128.167:443
- App 3000: http://20.199.128.167:3000
- App 8080: http://20.199.128.167:8080
- App 3001: http://20.199.128.167:3001
- App 8081: http://20.199.128.167:8081
- App 8000: http://20.199.128.167:8000

## ⚠️ Observações Importantes

1. **Firewall do Azure/AWS:** Se a conexão SSH externa falhar (timeout), verifique as regras de Security Group/Network Security Group no portal Azure/AWS para permitir tráfego na porta 2222.

2. **Segurança:** 
   - ⚠️ As senhas padrão são para desenvolvimento
   - ⚠️ Altere as senhas antes de usar em produção
   - ✅ Recomendado: Configure chaves SSH ao invés de senhas

3. **Rede:** O container está em uma rede Docker isolada (`ssh-cliente_ssh-network`)

## 🛠️ Comandos Úteis

### Verificar status do container:
```bash
ssh -i VPS_key.pem duzaq@20.199.128.167 'docker ps | grep ssh-vscode-server'
```

### Ver logs do container:
```bash
ssh -i VPS_key.pem duzaq@20.199.128.167 'cd ~/ssh-cliente && ./logs.sh'
```

### Entrar no container:
```bash
ssh -i VPS_key.pem duzaq@20.199.128.167 'docker exec -it ssh-vscode-server /bin/bash'
```

### Reiniciar container:
```bash
ssh -i VPS_key.pem duzaq@20.199.128.167 'cd ~/ssh-cliente && ./restart.sh'
```

### Parar container:
```bash
ssh -i VPS_key.pem duzaq@20.199.128.167 'cd ~/ssh-cliente && ./stop.sh'
```

## ✅ Checklist de Verificação

- [x] Container está rodando
- [x] Portas estão mapeadas corretamente
- [x] Serviço SSH está ativo
- [x] Porta 22 está escutando
- [x] Usuários root e admin criados
- [ ] Conexão SSH externa testada (pode precisar configurar firewall)
- [ ] Senhas alteradas (recomendado)
- [ ] Chaves SSH configuradas (opcional, recomendado)

---

**Última verificação:** $(date)  
**Script de verificação:** `./check-connections.sh`

