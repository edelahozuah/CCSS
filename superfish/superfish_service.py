import os
import subprocess
import time
import shutil

# The "Vulnerability": Hardcoded password in the binary/script
PASSWORD = "komodia"

def decrypt_key():
    print("Decrypting private key...")
    # Decrypt the key using the hardcoded password
    cmd = [
        "openssl", "rsa",
        "-in", "/app/superfish.enc.key",
        "-out", "/tmp/superfish.key",
        "-passin", f"pass:{PASSWORD}"
    ]
    subprocess.check_call(cmd)
    
    # Create the PEM file for mitmproxy (Key + Cert)
    with open("/tmp/superfish.key", "r") as k, open("/usr/local/share/ca-certificates/superfish.crt", "r") as c, open("/tmp/superfish.pem", "w") as p:
        p.write(k.read())
        p.write(c.read())
    
    # Clean up the raw key file (optional, but good practice, though memory dump will still work)
    os.remove("/tmp/superfish.key")

def run_proxy():
    print("Starting mitmproxy...")
    # Update CA certificates first
    subprocess.check_call(["update-ca-certificates"])
    
    # Start mitmdump with the decrypted PEM
    # We use subprocess.Popen to keep it running
    cmd = [
        "mitmdump",
        "--ssl-insecure",
        "--listen-port", "8080"
    ]
    
    # Set the confdir to /tmp where we might store config if needed, 
    # but here we just need to ensure it uses our PEM.
    # mitmproxy usually looks for mitmproxy-ca.pem in ~/.mitmproxy
    # Let's copy our PEM there.
    mitm_dir = os.path.expanduser("~/.mitmproxy")
    os.makedirs(mitm_dir, exist_ok=True)
    shutil.copy("/tmp/superfish.pem", os.path.join(mitm_dir, "mitmproxy-ca.pem"))
    
    process = subprocess.Popen(cmd)
    return process

if __name__ == "__main__":
    try:
        decrypt_key()
        proxy_process = run_proxy()
        
        # Keep the script running so we can dump its memory
        while True:
            time.sleep(1)
            if proxy_process.poll() is not None:
                print("Proxy exited!")
                break
    except Exception as e:
        print(f"Error: {e}")
        time.sleep(10) # Wait a bit before exiting on error
