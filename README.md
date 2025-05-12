
# Convert_PDF2TXT

Monitor a folder for new PDF files and try to convert them into a TXT file.


## Installation

The project will be provided into a exe file that needs to be copied onto the workstation, once in the right folder you just open a command line with admin rights to execute

```bash
convert_PDF2TXT.exe /i
```
This will install the service, it will automatically start after next reboot, or you can start it immediatly with the services.exe console.

To uninstall the service you open a command prompt with admin rights and execute
```bash
convert_PDF2TXT.exe /u
```

Check out the [Installation Document](./Documentations/Installation.md) for additionnal information.

## Usage/Examples

The service will use a standard configuration if no config.json is provided in the application folder.

```json
{
    "Log_File":  "<app dir>\\convert_PDF2TXT.log",
    "Folder_to_monitor":  "<app dir>",
    "Output_Folder":  "",
    "Recursive":  true
}
```
By default it will be,
- Log_File : at the same location as the application with convert_PDF2TXT.log as name.
- Folder to monitor : the folder where the application is located.
- Output_Folder : empty, this means that the TXT file will be located in the same location as the PDF file.
- Recursive ; true, it will also monitor the child folders.

Check out the [Config Document](./Documentations/Config.md) for additionnal information.

## Documentations

[Documentations](./Documentations)

The documentation can be found under the Documentations folder.
## Support

For support, email [Support](31592338+marth1974@users.noreply.github.com).


## Feedback

If you have any feedback, please reach out to me at [Feedback](31592338+marth1974@users.noreply.github.com).
