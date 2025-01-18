![Logo-Nmap](https://github.com/user-attachments/assets/7d2183e6-2968-456b-9df0-a2d2542ac3c4)

# **BlackBoxer Script Documentation**

## **Overview**
**BlackBoxer** is a Bash script designed to automate port enumeration and scanning tasks for domains associated with a **bug bounty program**. It resolves domains to IP addresses, performs TCP and UDP scans, and organizes results in a structured, user-friendly format.

---

## **Usage**

### **Command Syntax**
```bash
./BlackBoxer.sh [BUG_BOUNTY_PROGRAM_NAME]
```

### **Input Parameters**
- **BUG_BOUNTY_PROGRAM_NAME**: The name of the bug bounty program, used to create a results directory.

### **Prerequisites**
1. **Install nmap**:  
   Ensure `nmap` is installed. If not, run:
   ```bash
   sudo apt update && sudo apt install -y nmap
   ```
2. **Create valid_domains.txt**:  
   A file containing the domains to scan, one per line:
   ```plaintext
   example.com
   subdomain.example.com
   anotherdomain.com
   ```

---

## **Execution Flow**

### **1. Input Validation**
- Verifies that the program name is provided.
- Ensures `valid_domains.txt` exists in the current directory.

### **2. Results Directory Creation**
- A directory named `[BUG_BOUNTY_PROGRAM_NAME]_results` is created to store outputs.

### **3. Domain-to-IP Resolution**
- Resolves each domain from `valid_domains.txt` to its public IP address using the `dig` command.
- Skips:
  - Domains that cannot be resolved.
  - Duplicate IPs already processed.

### **4. TCP and UDP Port Scanning**
- For each unique IP:
  - **TCP Scan**:
    - Scans all ports (`-p-`) using `nmap` with SYN scan (`-sS`).
    - Optimizes the scan with a minimum packet rate (`--min-rate 500`).
    - Saves results in `tcp_scan.txt`.
  - **UDP Scan**:
    - Scans the 150 most common UDP ports.
    - Saves results in `udp_scan.txt`.
- Results are formatted and saved in subdirectories for each IP.

### **5. User-Friendly Output**
- Uses color-coded messages for better readability:
  - **Cyan**: General process updates.
  - **Yellow**: Warnings (e.g., unresolved domains or duplicate IPs).
  - **Green**: Success messages and results.

### **6. Final Results**
- Results are saved in `[BUG_BOUNTY_PROGRAM_NAME]_results` directory:
  - `tcp_scan.txt`: Open TCP ports.
  - `udp_scan.txt`: Open UDP ports.

---

## **Example Usage**
1. **Prepare the Domains File**:  
   Create a file `valid_domains.txt` with the following content:
   ```plaintext
   example.com
   subdomain.example.com
   anotherdomain.com
   ```
![imagen](https://github.com/user-attachments/assets/695b89b3-a90f-4bbd-8644-f1813b0fac8a)

2. **Run the Script**:  
   Execute the script with the desired program name:
   ```bash
   ./BlackBoxer.sh TestProgram
   ```

3. **Example Output**:  
   Console output will look like this:
   ```plaintext
   [+] Processing domains from 'valid_domains.txt'...
   [+] Resolving domain: example.com
   [+] Scanning TCP on 93.184.216.34...
       Open TCP ports found on 93.184.216.34:
       80/tcp  open  http
       443/tcp open  https
   [+] Scanning UDP on 93.184.216.34...
       No open UDP ports found on 93.184.216.34.
   ```
---

## **Benefits**
- **Automation**: Significantly reduces manual effort for port enumeration.
- **Efficiency**: Avoids duplicate processing of IPs.
- **Organization**: Results are structured in directories and files for easy analysis.
- **Scalability**: Easily extendable to include additional tools or functionality.

---

## **Next Steps**
- To enhance the script, consider integrating additional tools like `httpx` or `subfinder` for more comprehensive scanning.
- Feel free to modify the color schemes or extend functionality based on your workflow.
