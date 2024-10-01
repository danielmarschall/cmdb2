
[General info](README.md) | Database window | [Mandator window](HELP_MandatorWindow.md) | [Artist/Client window](HELP_ArtistClientWindow.md) | [Commission window](HELP_CommissionWindow.md) | [Statistics](HELP_Statistics.md)

# Database window

When starting `CmDb2.exe`, you will be greeted with a window called "Database". If you have closed it, you can always re-open it by clicking "Open Database" at the main menu at the top.

## Database window tab "Mandators"

Artists, Commissions, Payments, ... are stored in a mandator. You can have multiple mandators, e.g. a test mandator and a productive mandator, or you can have multiple mandators if you want a strict separation between some artists or artworks.

Start by creating a new mandator simply by typing a name (e.g. your name) into the grid and then save the row by leaving it (press the arrow down key). Then, double-click the newly created row to open the mandator.

## Database window tab "Text Dumps"

When you exit the program with the option "Backup and Exit", the program will check if you have made changes somewhere in the database, and if you did so, then create a fresh backup. A "Text Dump" is a backup protocol that shows all the data in text format. Double-clicking a row will let you save the text file. Note that a text file is just for your information, or for comparison with diff-tools. The actual backup that can be restored lies in the user profile directory, named `cmdb2_backup_*.bak`.

## Database window tab "Settings"

Here you can find system-global settings. Currently, there are the following settings:

- `BACKUP_PATH`:  If you want to store the `cmdb2_backup_*.bak` files somewhere else, then enter the path here.
- `CURRENCY_LAYER_API_KEY`: Automatic currency conversion is only possible by creating an account at [CurrencyLayer.com](https://CurrencyLayer.com/). There is a free plan which gives you a limit number of requests per month. Enter the API key here if you want to use this feature.
- `LOCAL_CURRENCY`: Enter a 3-letter currency code here, such as `USD` or `EUR`
- `PICKLIST_ARTPAGES`: Contains a semicolon-separated list of art pages to be selected in the "Uploads" tab at a commission
- `PICKLIST_COMMUNICATION` Contains a semicolon-separated list of things you can enter in the "Communication" tab at an artist or client
- `PICKLIST_PAYPROVIDER`: Contains a semicolon-separated list of things you can enter in the "Payment" tab at an artist/client

Note that there are no configurable picklists for commission events and artist events because they have a special meaning which is hardcoded into the program.
