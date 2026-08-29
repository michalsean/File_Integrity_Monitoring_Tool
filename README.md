# File Integrity Monitoring & Threat Intelligence Pipeline

A security automation pipeline designed to scan local directories, extract binary metadata, calculate SHA-256 hashes, and enrich forensic data using the VirusTotal API v3.

Developed as part of the Scripting for Cybersecurity (COMP-H2702) module at Technological University Dublin (TU Dublin).

---

## Project Overview

Maintaining system integrity and identifying potentially malicious executables is critical in modern Security Operations Centers (SOC). This project automates the workflow of a SOC analyst by combining Windows PowerShell for local endpoint data collection and Python for threat intelligence enrichment.

### Key Capabilities
- **Automated Directory Hashing:** Recursively scans target directories for executable binaries (`.exe`, `.dll`, `.bat`), captures system metadata (timestamps, full file paths), and calculates cryptographic SHA-256 hashes.
- **Inter-Script Data Pipeline:** Exports structured telemetry into an intermediary `hashes.json` file for seamless integration with external analysis tools.
- **Threat Intelligence Enrichment:** Automatically queries the VirusTotal REST API v3 using each SHA-256 hash.
- **Automated Threat Assessment:** Evaluates multi-engine analysis statistics, tags files as **Clean** or **MALICIOUS**, and compiles an analyst-ready intelligence report (`final_report.json`).

---

## Project Structure

```text
Scripting For Cyber Project/
│
├── README.md             # Project documentation, requirements, and execution guide
├── FileCollector.ps1     # PowerShell script for endpoint file monitoring & SHA-256 hashing
├── VT_Enricher.py        # Python script for VirusTotal API threat enrichment
│
└── Dummy Files/          # Test directory containing target binaries
    ├── example_files
```

---

## Architecture & Data Workflow

```text
 +------------------------+
 |    Target Directory    |
 |  (.exe, .dll, .bat)    |
 +-----------+------------+
             |
             v
 +------------------------+
 |   FileCollector.ps1    |  --> Calculates SHA-256 & captures metadata
 +-----------+------------+
             |
             v
     [ hashes.json ]      --> Intermediary telemetry file
             |
             v
 +------------------------+
 |    VT_Enricher.py      |  --> Queries VirusTotal API v3
 +-----------+------------+
             |
             v
  [ final_report.json ]   --> Final analyst-ready report
```

---

## Requirements & Prerequisites

### Prerequisites
- **Operating System:** Windows 10 / 11 or Windows Server (PowerShell 5.1+)
- **Python:** Python 3.8 or higher

### Dependencies
- **PowerShell:** Native cmdlets (`Get-ChildItem`, `Get-FileHash`, `ConvertTo-Json`, `Out-File`).
- **Python Libraries:**
  - `requests` (External HTTP library for VirusTotal API integration)
  - `json`, `os`, `sys` (Python Built-in Standard Libraries)

---

## Installation & Setup

### 1. Install Required Python Packages
Run the following command in your terminal or command prompt:

```bash
pip install requests
```

### 2. Configure VirusTotal API Key
The enrichment script requires a VirusTotal API key. You can pass it via an environment variable or set it directly in the script.

**Option A: Environment Variable (Recommended)**
```powershell
# Windows PowerShell
$env:VT_API_KEY="your_virustotal_api_key_here"
```
```cmd
# Windows Command Prompt
set VT_API_KEY=your_virustotal_api_key_here
```

**Option B: Script Configuration**
Open `VT_Enricher.py` and assign your API key:
```python
API_KEY = os.environ.get('VT_API_KEY', 'YOUR_VIRUSTOTAL_API_KEY_HERE')
```

---

## Execution Guide

Follow these steps to run the cybersecurity automation pipeline:

### Step 1: Run File Collector (`FileCollector.ps1`)
Execute the PowerShell script to scan the target directory, compute SHA-256 hashes, and export telemetry data:

```powershell
.\FileCollector.ps1
```

> **Note:** Verify or update the `-TargetPath` argument inside `FileCollector.ps1` to match your target file path if needed:
> ```powershell
> $data = Get-FileHashes -TargetPath ".\Dummy Files"
> ```

**Result:** Generates `hashes.json` in the root script directory.

### Step 2: Run VirusTotal Enricher (`VT_Enricher.py`)
Run the Python enrichment script to evaluate the generated hash telemetry against VirusTotal intelligence:

```bash
python VT_Enricher.py
```

**Result:** Queries VirusTotal for each hash and outputs `final_report.json`.

### Step 3: Review Results
Inspect `final_report.json` to review the security status, hash values, and file metadata.

---

## Data Schemas & Sample Outputs

### Intermediary Output (`hashes.json`)
```json
[
    {
        "FileName": "DLL.dll",
        "FilePath": "C:\PATH\TO\DLL.dll",
        "Hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
        "LastModified": "2025-12-01T14:20:00Z"
    }
]
```

### Final Enriched Report (`final_report.json`)
```json
[
    {
        "FileName": "game.exe",
        "FilePath": "C:\PATH\TO\GAME.exe",
        "Hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
        "LastModified": "2025-12-01T14:20:00Z",
        "Reputation": "Clean"
    }
]
```

---

## Technical Considerations & Lessons Learned

1. **Character Encoding Management:**
   - *Problem:* PowerShell's default JSON output format can insert Byte Order Marks (BOM) or UTF-16 encoding, leading to parsing errors in standard Python JSON readers.
   - *Solution:* The Python script reads `hashes.json` using `encoding="utf-8-sig"`, ensuring smooth cross-language file I/O operations.

2. **API Error Handling & Unknown Hashes:**
   - *Problem:* Files such as custom batch scripts (`.bat`) or novel binaries might not exist in VirusTotal's hash database, returning HTTP `404 Not Found`.
   - *Solution:* `VT_Enricher.py` handles HTTP 404 responses cleanly, categorizing them without interrupting execution or causing pipeline failure.
