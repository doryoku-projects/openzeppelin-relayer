# Shared OpenZeppelin Relayer Infrastructure

This repository is a production-grade, zero-vendor-code infrastructure deployment setup for our shared **OpenZeppelin Relayer**. 

By running the official unmodified Docker image (`openzeppelin/openzeppelin-relayer:latest`), we maintain clear boundaries between vendor code and our core logic, enabling simple upgrades and zero copyleft licensing risk.

---

## 1. Setup Architecture

```
Internet (Proxy Port 80)
      │
      ▼
[copypools-relayer-proxy] (Nginx Reverse Proxy)
      │
      ▼ Proxy to port 8080
[copypools-relayer] (Actix-web Rust Relayer)
      │
      ├── Read/write transaction queue (port 6379) ──► [copypools-relayer-redis] (Persistent Redis)
      │
      └── Decrypt/Sign ──► [local-signer.json] (keystore signer file)
```

---

## 2. Setup & Initialization

### Step 1: Create Keystore Signer
To run the relayer using local encrypted keystore files, you must generate a signer key. You can do this by running a temporary one-off Docker container using the official image:

```bash
docker run --rm -v $(pwd)/config/keys:/app/config/keys -it openzeppelin/openzeppelin-relayer:latest \
  /bin/sh -c "cargo run --example create_key -- --password 'YourSecurePassword' --output-dir /app/config/keys --filename local-signer.json"
```

This generates `config/keys/local-signer.json` inside your working directory. 

> **Important**: Never commit `local-signer.json` or `.env` files to git! They are automatically ignored.

---

### Step 2: Configure Environment Variables
Create an `.env` file inside this directory:

```env
# Relayer Secrets
API_KEY=your_generated_bearer_api_key_uuid
KEYSTORE_PASSPHRASE=YourSecurePassword

# RPC URLs (used by the pre-startup substitution script)
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your_alchemy_key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your_alchemy_key
```

---

### Step 3: Run the Stack
Start the containers using docker-compose:

```bash
docker compose up -d
```

Verify that the services are healthy:

```bash
docker compose ps
```

---

## 3. Operations & API Calls

### Get Relayer Status
```bash
curl -X GET http://localhost/api/v1/relayers \
  -H "Authorization: Bearer your_generated_bearer_api_key_uuid"
```

### Submit a Transaction Write
```bash
curl -X POST http://localhost/api/v1/relayers/copypools-relayer-sepolia/transactions \
  -H "Authorization: Bearer your_generated_bearer_api_key_uuid" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "0xContractAddress",
    "value": 0,
    "data": "0xHexCalldata",
    "speed": "fast"
  }'
```
