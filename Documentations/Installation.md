# Installation Guide for PowerShell Service Created with Sapien Tools

This document provides step-by-step instructions to install a PowerShell service created using Sapien Tools.

## Prerequisites

1. Ensure you have administrative privileges on the system.
2. Verify that PowerShell is installed on your machine (minimum version 5.1).
3. Download the service package created with Sapien Tools, which includes the following:
    - Service executable file (`YourService.exe`)
    - Configuration files (if applicable)
    - Supporting scripts or dependencies

## Installation Steps

1. **Extract the Service Package**
    - Locate the downloaded service package (e.g., `YourService.zip`).
    - Extract the contents to a directory of your choice (e.g., `C:\Services\YourService`).

2. **Open PowerShell as Administrator**
    - Press `Win + X` and select **Windows PowerShell (Admin)** or **Terminal (Admin)**.

3. **Navigate to the Service Directory**
    - Use the `cd` command to navigate to the directory where the service files are located. For example:
      ```powershell
      cd C:\Services\YourService
      ```

4. **Install the Service**
    - Run the following command to install the service:
      ```powershell
      .\YourService.exe -i
      ```
    - This command registers the service with the Windows Service Manager.

5. **Verify the Installation**
    - Check if the service is installed by running:
      ```powershell
      Get-Service -Name "YourServiceName"
      ```
    - Replace `YourServiceName` with the actual name of your service.

6. **Start the Service**
    - Start the service using the following command:
      ```powershell
      Start-Service -Name "YourServiceName"
      ```

7. **Set the Service to Start Automatically**
    - Configure the service to start automatically on system boot:
      ```powershell
      Set-Service -Name "YourServiceName" -StartupType Automatic
      ```

## Troubleshooting

- If the service fails to install, ensure that:
  - You are running PowerShell as an administrator.
  - All required dependencies are present in the service directory.
- Check the Windows Event Viewer for error logs related to the service.

## Uninstallation

To uninstall the service, follow these steps:

1. Stop the service:
    ```powershell
    Stop-Service -Name "YourServiceName"
    ```

2. Uninstall the service:
    ```powershell
    .\YourService.exe -u
    ```

3. Remove the service files from the directory.

## Additional Notes

- Refer to the Sapien Tools documentation for advanced configuration options.
- Contact your system administrator if you encounter issues during installation.