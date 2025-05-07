# Configuration File Documentation

This document explains how to create and configure the `config.json` file for the project.

## Overview

The `config.json` file is used to define the settings and options required for the application to function properly. Below is a guide to the available options and their usage.

## Configuration Options

### 1. `Folder_to_monitor`
- **Description**: Specifies the directory containing the PDF files to be processed.
- **Type**: String
- **Example**: `"Folder_to_monitor": "./pdfs"`

### 2. `Output_Folder`
- **Description**: Specifies the directory where the converted text files will be saved. If empty the txt file will be located at tehe same place as the pdf file.
- **Type**: String
- **Example**: `"Output_Folder": "./texts"`

### 3. `Log_File`
- **Description**: Specifies the log file name and location..
- **Type**: String
- **Example**: `"Log_File": "./program.log"`

### 4. `Recursive`
- **Description**: If the monitoring should be recursive or not.
- **Type**: Boolean
- **Example**: `"Recursive": true`

## Example `config.json`

```json
{
    "Folder_to_monitor": "./pdfs",
    "Output_Folder": "./texts",
    "Log_File": "./program.log",
    "Recursive": true
}
```

## Notes
- Ensure the paths provided in `Folder_to_monitor` and `Output_Folder` are valid and accessible.

