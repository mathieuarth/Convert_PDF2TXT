---

# **Script Documentation: Folder Monitoring and PDF to TXT Conversion Service**

## **Overview**
This PowerShell script is designed to monitor a specified folder for new PDF files and automatically convert them into TXT files. It operates as a service with lifecycle management (start, stop, pause, continue) and includes robust logging for tracking operations and errors.

---

## **Features**
1. **Folder Monitoring:**
   - Monitors a specified folder for new PDF files using `FileSystemWatcher`.
   - Supports recursive monitoring of subdirectories.

2. **PDF to TXT Conversion:**
   - Converts detected PDF files into TXT format.
   - Logs errors if the file is invalid or the conversion fails.

3. **Service Lifecycle Management:**
   - Implements `Start`, `Stop`, `Pause`, and `Continue` functions to control the service.
   - Handles cleanup and resource management during service stop.

4. **Logging:**
   - Logs all operations, errors, and service state changes to a log file.
   - Includes timestamps and message types (Info, Warning, Error, Debug).

5. **Error Handling:**
   - Handles errors gracefully with detailed logging.
   - Validates folder paths and file types before processing.

---

## **Functions**

### **1. Start-MyService**
- **Purpose:** Initializes and starts the service.
- **Key Actions:**
  - Validates the folder to monitor.
  - Sets up the `FileSystemWatcher` to monitor for new PDF files.
  - Logs the service start event.

---

### **2. Invoke-MyService**
- **Purpose:** Main service loop that keeps the service running.
- **Key Actions:**
  - Continuously checks the service state (`bRunService`).
  - Handles paused state (`bServicePaused`) by reducing activity.
  - Logs any errors encountered during execution.

---

### **3. Stop-MyService**
- **Purpose:** Stops the service and performs cleanup.
- **Key Actions:**
  - Signals the service loop to exit.
  - Disables the `FileSystemWatcher`.
  - Unregisters event handlers and disposes of resources.
  - Logs the service stop event.

---

### **4. Pause-MyService**
- **Purpose:** Pauses the service without stopping it completely.
- **Key Actions:**
  - Sets the `bServicePaused` flag to `true`.
  - Disables the `FileSystemWatcher`.
  - Logs the service pause event.

---

### **5. Continue-MyService**
- **Purpose:** Resumes the service from a paused state.
- **Key Actions:**
  - Sets the `bServicePaused` flag to `false`.
  - Re-enables the `FileSystemWatcher`.
  - Logs the service restart event.

---

### **6. Convert-PDF2TXT**
- **Purpose:** Converts a PDF file to a TXT file.
- **Parameters:**
  - `PDFPath` (Mandatory): Full path to the PDF file.
- **Key Actions:**
  - Validates the file path and type.
  - Converts the PDF to TXT format.
  - Logs success or failure of the conversion.
- **Example Usage:**
  ```powershell
  Convert-PDF2TXT -PDFPath "C:\Files\example.pdf"
  ```

---

### **7. Write-Log**
- **Purpose:** Writes log entries to a specified log file.
- **Parameters:**
  - `Message` (Mandatory): The log message.
  - `MessageType` (Optional): Type of message (`Info`, `Warning`, `Error`, `Debug`). Default is `Info`.
  - `LogFile` (Optional): Path to the log file. Default is `$scriptDirectory\$scriptName.log`.
- **Key Actions:**
  - Ensures the log directory exists.
  - Formats the log entry with a timestamp and message type.
  - Appends the log entry to the log file.

---

### **8. Get-Config**
- **Purpose:** Get the actual configuration data.
- **Key Actions:**
  - Initialize actual configuration data with default values.
  - Check if there is a config.json file available.
  - Integrate the values from the file to the configuration object.

---

### **9. Save-Config**
- **Purpose:** Save the actual configuration data to the config.json file.
- **Parameters:**
  - `config` (Mandatory): Configuration data object.
- **Key Actions:**
  - Check if folder exist.
  - Save the configuration data
- **Example Usage:**
  ```powershell
  Save-Config -Config $Config_Data
  ```

---
## **Global Variables**
- `$global:Config`: Stores configuration settings such as the folder to monitor, log file path, and recursion flag.
- `$global:watcher`: Instance of `FileSystemWatcher` for monitoring the folder.
- `$global:onCreated`: Event handler for processing new files.
- `$global:bRunService`: Boolean flag to control the main service loop.
- `$global:bServiceRunning`: Boolean flag indicating whether the service is running.
- `$global:bServicePaused`: Boolean flag indicating whether the service is paused.

---

## **Configuration**
The script relies on a global configuration object (`$global:Config`) with the following properties:
- `Folder_to_monitor`: Path to the folder to monitor. (default:folder where the service file is located)
- `Log_File`: Path to the log file. (default:convert_pdf2txt.log)
- `Recursive`: Boolean flag to enable/disable recursive monitoring. (default:true)
- `Output_Folder`: Path to the folder where converted TXT files will be saved. (default:"")  
The content will be found in a `config.json` file located in the same folder as the service file, if not it will use the default values.
---

## **Error Handling**
- **Folder Validation:**
  - Checks if the folder to monitor exists. Throws an error if it doesn’t.
- **File Validation:**
  - Ensures the file exists and is a valid PDF before attempting conversion.
- **Logging Errors:**
  - Logs all errors with detailed messages and timestamps.

---

## **Usage Instructions**

### **1. Start the Service**
Run the following command to start the service:
```powershell
start-service "convert_pdf2txt"
```

### **2. Monitor Folder**
The service will automatically monitor the specified folder for new PDF files and convert them to TXT files.

### **3. Pause the Service**
To pause the service, run:
```powershell
suspend-service "convert_pdf2txt"
```

### **4. Resume the Service**
To resume the service, run:
```powershell
resume-service "convert_pdf2txt"
```

### **5. Stop the Service**
To stop the service, run:
```powershell
stop-service "convert_pdf2txt"
```

---

## **Example Workflow**
1. Install the service
2. Configure the `config.json` file with the folder to monitor and log file path.
3. Start the service.
4. Add a new PDF file to the monitored folder.
5. Check the output folder for the converted TXT file.
6. Pause, resume, or stop the service as needed.

---

## **Dependencies**
- **iTextSharp.dll:** Required for PDF to TXT conversion. The script extracts this DLL from a Base64-encoded string and loads it dynamically.

---

## **Logging Example**
Sample log entries:
```plaintext
[2025-05-08 10:00:00] [Info] Service       : Start
[2025-05-08 10:01:00] [Info] Convertion    : File example.pdf converted successfully.
[2025-05-08 10:02:00] [Error] Convertion   : Selected file C:\Files\missing.pdf does not exist, check the path and try again!
[2025-05-08 10:03:00] [Info] Service       : Stop
```

---

## **Known Limitations**
1. **PDF Conversion:**
   - Relies on `iTextSharp.dll`. Ensure the DLL is correctly extracted and loaded.
2. **Error Handling:**
   - Some error handling blocks (`catch`) are placeholders and need detailed implementation.
3. **Performance:**
   - The service loop (`Invoke-MyService`) may need optimization for high-frequency folder changes.

---

## **Future Enhancements**
1. Add support for additional file formats.
2. Implement retry logic for transient errors (e.g., locked files).

---
