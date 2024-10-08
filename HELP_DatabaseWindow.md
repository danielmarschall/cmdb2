
[General info](README.md) | Database window | [Mandator window](HELP_MandatorWindow.md) | [Artist/Client window](HELP_ArtistClientWindow.md) | [Commission window](HELP_CommissionWindow.md) | [Statistics](HELP_Statistics.md)

# Database window

![Screenshot](CmDb2_Screenshot_Database.png)

When starting `CmDb2.exe`, you will be greeted with a window called "Database". If you have closed it, you can always re-open it by clicking "Open Database" at the main menu at the top.

## Database window tab "Mandators"

Artists, Commissions, Payments, ... are stored in a mandator. You can have multiple mandators, e.g. a test mandator and a productive mandator, or you can have multiple mandators if you want a strict separation between some artists or artworks.

Start by creating a new mandator simply by typing a name (e.g. your name) into the data grid and then save the row by leaving it (e.g. press the arrow down key followed by the arrow up key). After the row has been saved, double-click the newly created row to open the mandator.

## Database window tab "Backups"

The grid at the "Backups" tab shows an overview of all backups that have been created. Note that the table also contains backups which have been already deleted.

Beside the BAK files (that can be used for restoring data), the program will create a CSV files that contain the data in text form which allows that backups can be compared with diff-tools.

## Database window tab "Settings"

Here you can find system-global settings. Currently, there are the following settings:

- `BACKUP_PATH`:  If you want to store the `cmdb2_backup_*.bak` files somewhere else, then enter the path here. Otherwise, the CMDB2 folder in your user directory will be chosen.
- `CURRENCY_LAYER_API_KEY`: Automatic currency conversion is only possible by creating an account at [CurrencyLayer.com](https://CurrencyLayer.com/). There is a free plan which gives you a limit number of requests per month. Enter the API key here if you want to use this feature.
- `LOCAL_CURRENCY`: Enter a 3-letter currency code here, such as `USD` or `EUR`
- `NEW_PASSWORD`: Enter a password to set or renew database protection. Press Ctrl+Del to remove a previously set password. This field will be empty after restart for confidentiality.
- `PICKLIST_ARTPAGES`: Contains a semicolon-separated list of art pages to be selected in the "Uploads" tab at a commission
- `PICKLIST_COMMUNICATION` Contains a semicolon-separated list of things you can enter in the "Communication" tab at an artist or client
- `PICKLIST_PAYPROVIDER`: Contains a semicolon-separated list of things you can enter in the "Payment" tab at an artist/client

Note that there are no configurable picklists for commission events and artist events because they have a special meaning which is hardcoded into the program.
