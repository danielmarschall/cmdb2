
# Commission Database 2.0

## What is Commission Database 2.0?

Commission Database 2.0 (CMDB2) is a management software for artists and their patrons (clients/commissioners).

It manages:
- Overview of your artists (or clients) and the open art projects
- Upload status to art pages
- Which artworks are paid for, or if you have credits or debts
- Overview of all incoming/outgoing payments, which can be useful to verify bank statements
- Various statistics such as the month/year sums of incoming/outgoing payments
- Built-in currency converter to convert foreign currencies into your local currency (as a base for the statistics)
- Shortcut to folders that contain the artworks
- Collecting various information about commissions and artists, e.g. the contact details

Developers can extend the program using the programming language Embarcadero Delphi; the source files are on GitHub.

## License

The software is free; also for commercial usage. It is licensed under the terms of the Apache 2.0 license.

## Installation

CMDB2 software is only available for Microsoft Windows.

The latest version can be downloaded here: github.com/danielmarschall/cmdb2

If CMDB2 doesn't start right away when running `CmDb2.exe`, then you might need to install the SQL Server dependencies first:
- SQL Server Client driver: https://learn.microsoft.com/en-us/sql/connect/oledb/download-oledb-driver-for-sql-server?view=sql-server-ver16
- SQL Server LocalDB: https://dba.stackexchange.com/a/258182/77847

## General information

### Handling database grids

It is important to understand how to handle a database grid. Here are some notes:
- Nearly every window in CMDB2 is a database grid.
- Clicking the column header will let you sort the dataset. Clicking it again will reverse the sort.
- Navigate using arrow keys, "PgUp", "PgDown", "Home", and "End" or with the arrows in the navigator bar at the left.
- When you change something in a different window, then you might reload the dataset by clicking "Refresh" at the bottom. For example, if you entered a payment for an artist, the "payment status" in the artist overview will be refreshed only after clicking the "Refresh" button.
- A small icon left on the selected row in a grid will show the current operation. An arrow means you are in "browsing" mode. A star means you are in the "insert" mode. A bar means you are in "edit" mode.
- When you edit or insert a row, leaving the row (arrow up or arrow down key) or clicking the "green check" icon in the navigator will trigger the save command to the database. Closing the program might not always trigger the save command.
- Remove a row with "Ctrl + Del" or by clicking the "red minus" in the navigator.
- Insert a row by going past the last line using the arrow keys, or click the "blue plus" in the navigator, or press the "Insert" key.
- Cancel an edit/insert operation by pressing "Esc". Note that if you are not in the edit/insert mode, then "Esc" will close the window.
- Some fields are "boolean" which means that they only accept a yes or a no. In this case, you have to type "True" (for yes) or "False" (for no). Depending on your system locale, the names might be different, such as "Wahr" and "Falsch" for German systems.

### Common error messages

Although CMDB2 is translated into English, the development environment was German, so, unfortunately, some common error messages are written in German. They are explained here:
- "Die zum Aktualisieren angegebene Zeile wurde nicht gefunden. Einige Werte wurden seit dem letzten Lesen ggf. geändert.": This means that you are trying to change something that was already changed somewhere else. The solution is to cancel the edit/insert operation, and refresh the dataset (or close the window and reopen it) to get a fresh dataset that can be edited.
- "In diese Spalte kann kein NULL Wert eingefügt werden": This means that you are trying to save a dataset but there are some mandatory fields missing. Check if you have entered everything that is required.

### Data storage

Where is my data stored? By default, data is stored in your Windows profile at `C:\Users\YourName\`

The files are named:
- `cmdb2.mdf`
- `cmdb2.ldf`
- `cmdb2_backup_*.bak` are backups, which can be regularly purged.

Please create backups regularly by clicking "File" and then "Backup and Exit".

Restore a backup using the restore command in the main menu. Alternatively, experts can restore a backup using Microsoft SQL Server Management Studio (connect to `(localdb)\MSSQLLocalDB` and restore the BAK file as database `cmdb2`.)

### Integrated currency conversion

When is the currency converted?

In the Commission Form, when all these criteria have been fulfilled:
- In the commission quote, `IS_FREE` must be False, otherwise Local Amount will be automatically set to 0.
- You change the field "Amount" and save the row (leave the line).
- "Currency" must be a valid 3-letter code currency, e.g. `USD`
- In the configuration you need to have `LOCAL_CURRENCY` filled with a valid 3-letter code currency, e.g. EUR
- In the configuration you need to have `CURRENCY_LAYER_API_KEY` filled with a valid API key from [CurrencyLayer.com](https://CurrencyLayer.com/)

### How payment work

CMDB2 works with the "down payment" system. This allows partial payments or payments for multiple commissions at once.
- In the commission window you create a "quote" event and enter the price of the commission
- In the artist/client window you enter a payment. It is recommended to add the co

The program automatically calculates how much debt or credit an artist/client has:
- Sum of all payments - Sum of all commission quotes > 0 means there is a credit
- Sum of all payments - Sum of all commission quotes < 0 means there is a debt
- Sum of all payments - Sum of all commission quotes = 0 means everything has been paid for.

### How refunding works

- In the commission window, create or enter a "quote" event and add a negative price, so that the original price is balanced to zero. (Or to a value that was agreed with the artist/client). DO NOT create a new commission with a negative price.
- If the client has already paid, then the program will recognize a Credit (Payments - Quotes > 0).
- After the client has been paid back, the negative payment will be added in the artist/client window.
- Alternatively, if the artist is paid back with another artwork, then simply add new commissions with quotes. The program will automatically keep track of the credit by subtracting the sum of quotes for the commissions from the sum of payments from.

## Explanation of all windows and tabs

### Overview

- Database
	- Mandator
		- Artists / Clients
			- Commission
				- Events
					- Quote
					- Upload
				- Files
			- Payment
			- Events
			- Communication
		- Commissions (overview)
		- Payments (overview)
		- Statistics
	- Text Dumps (Backup Protocols)
	- Settings

### Database window

When starting `CmDb2.exe`, you will be greeted with a window called "Database". If you have closed it, you can always re-open it by clicking "Open Database" at the main menu at the top.

#### Database window tab "Mandators"

Artists, Commissions, Payments, ... are stored in a mandator. You can have multiple mandators, e.g. a test mandator and a productive mandator, or you can have multiple mandators if you want a strict separation between some artists or artworks.

Start by creating a new mandator simply by typing a name (e.g. your name) into the grid and then save the row by leaving it (press the arrow down key). Then, double-click the newly created row to open the mandator.

#### Database window tab "Text Dumps"

When you exit the program with the option "Backup and Exit", the program will check if you have made changes somewhere in the database, and if you did so, then create a fresh backup. A "Text Dump" is a backup protocol that shows all the data in text format. Double-clicking a row will let you save the text file. Note that a text file is just for your information, or for comparison with diff-tools. The actual backup that can be restored lies in the user profile directory, named `cmdb2_backup_*.bak`.

#### Database window tab "Settings"

Here you can find system-global settings. Currently, there are the following settings:

- `BACKUP_PATH`:  If you want to store the `cmdb2_backup_*.bak` files somewhere else, then enter the path here.
- `CURRENCY_LAYER_API_KEY`: Automatic currency conversion is only possible by creating an account at [CurrencyLayer.com](https://CurrencyLayer.com/). There is a free plan which gives you a limit number of requests per month. Enter the API key here if you want to use this feature.
- `LOCAL_CURRENCY`: Enter a 3-letter currency code here, such as `USD` or `EUR`
- `PICKLIST_ARTPAGES`: Contains a semicolon-separated list of art pages to be selected in the "Uploads" tab at a commission
- `PICKLIST_COMMUNICATION` Contains a semicolon-separated list of things you can enter in the "Communication" tab at an artist or client
- `PICKLIST_PAYPROVIDER`: Contains a semicolon-separated list of things you can enter in the "Payment" tab at an artist/client

Note that there are no configurable picklists for commission events and artist events because they have a special meaning which is hardcoded into the program.

### Mandator window

#### Mandator window tabs "Artists" and "Clients"

To create a new artist (or client) simply create a new row with the name of that artist (or client).

Double-clicking an artist (or client) brings you to the Artist/Client window.

The other columns are automatically filled by the program:
- Column `NAME` is the only column that you can edit. Enter any name or nickname of the artist/client here.
- Column `STATUS` contains the status that is automatically calculated by the "Events" you entered in the Artist/Client window. The following states are possible:
	- "Active"
	- "Inactive" (unexpected hiatus)
	- "Hiatus" (announced)
	- "Stopped service" (indefinitely)
	- "Cooperation ended" (stopped service just for you)
	- "Deceased"
- Column `PAY_STATUS` contains:
	- `OKAY` if there are no debts or credits
	- `CREDIT` including amount and currency.
	- `DEBT` including amount and currency.
	- If there are credits/debts of multiple currencies, it will be displayed accordingly. (Calculation: Sum of all payments in the artist/client window minus the sum of all quotes in the commissions).
- Column `RUNNING`: Shows the amount of open art projects and the total amount of art projects.
- Column `UPLOAD_C`: Shows how many artworks have been uploaded by the commissioner. (Commission window event "upload c") The total amount of art projects is reduced by the amount of artwork where uploading by the client is prohibited. ("upload c" event contains the information Prohibited=True).
- Column `UPLOAD_A` is the same as `UPLOAD_C`, just for uploads by the artist.
- Column `AMOUNT_TOTAL_LOCAL`: Shows the sum of all commission quotes in your local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.

#### Mandator window tab "Commissions"

This is an overview of all commissions entered in all artists/clients. All fields are read-only. To create a new commission, go into the artists/clients window.

Double-clicking brings you to the Commission window.

The database grid has the following columns:
- Column `PROJECT_NAME` contains the commission name and the artist/client name.
- Column `START_DATE` contains the start date of the commission (earliest "event" of a commission such as "aw sk"; excluded events are "quote", "annot", "upload a", "upload c", "upload x", "idea", and "c td initcm"
- Column `END_DATE` contains the end date of a commission (the "fin" event of a commission)
- Column `ART_STATUS` contains the latest commission event such as "aw sk" or "fin"; excluded are the events "quote", "upload a", "upload c", "upload x", and "annot"
- Column `PAY_STATUS` contains the payment status of the commission, which is `Paid`, `Partiall Paid`, or `Not Paid`, including the amount and currency.
- Column `UPLOAD_A` contains the information if the artwork was uploaded by the artist (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload a" event in the commission).
- Column `UPLOAD_C` contains the information if the artwork was uploaded by the client (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload c" event in the commission).
- Column `AMOUNT_LOCAL` contains the amount in the local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.

#### Mandator window tab "Payments"

This is an overview of all commissions entered in all artists/clients. You can make changes here, but new payments must be added in the artists/clients window.

The database grid has the following columns:
- Column `DATE`: Date of the payment
- Column `ARTIST_OR_CLIENT_NAME`: The artist or client name
- Column `AMOUNT`: The amount in the target currency
- Column `CURRENCY`: The currency
- Column `AMOUNT_LOCAL`: The amount in the local currency.
- Column `AMOUNT_VERIFIED`: Set this to "True" when you have verified that the local amount is correct (i.e. after checking your bank statement). The correctness includes the actualy applied conversion rate and various fees.
- Column `PAYPROV`: The pay provider such as PayPal. You can use the picklist `PICKLIST_PAYPROVIDER`.
- Column `ANNOTATION`: It is recommended to enter the name of the commission(s) here. Maybe also the bank statement number that you have compared with.

#### Mandator window tab "Statistics"

There are various statistics that can be easily extended in the database without changing the program code.

Currently, there are the following statistics:
- Running commissions
- Local sum over years (commissions outgoing)
- Local sum over months (commissions outgoing)
- Top artists/clients
- Full Text Export

### Artist/Client window

#### Artist/Client window tab "Commissions"

The database grid has the following columns:
- Column `NAME` contains a name you give the commission. This is the only field you can edit.
- Column `START_DATE` contains the start date of the commission (earliest "event" of a commission such as "aw sk"; excluded events are "quote", "annot", "upload a", "upload c", "upload x", "idea", and "c td initcm"
- Column `END_DATE` contains the end date of a commission (the "fin" event of a commission)
- Column `ART_STATUS` contains the latest commission event such as "aw sk" or "fin"; excluded are the events "quote", "upload a", "upload c", "upload x", and "annot"
- Column `PAY_STATUS` contains the payment status of the commission, which is `Paid`, `Partiall Paid`, or `Not Paid`, including the amount and currency.
- Column `UPLOAD_A` contains the information if the artwork was uploaded by the artist (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload a" event in the commission).
- Column `UPLOAD_C` contains the information if the artwork was uploaded by the client (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload c" event in the commission).
- Column `AMOUNT_LOCAL` contains the amount in the local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.

#### Artist/Client window tab "Payments"

When you add payments, please take care that the currency is the same as the currency in the commission, otherwise the program cannot calculate the debt/credit by subtracting the sum of commission quotes from the sum of payments.

The database grid has the following columns:
- Column `DATE`: Date of the payment
- Column `AMOUNT`: The amount in the target currency
- Column `CURRENCY`: The currency
- Column `AMOUNT_LOCAL`: The amount in the local currency.
- Column `AMOUNT_VERIFIED`: Set this to "True" when you have verified that the local amount is correct (i.e. after checking your bank statement). The correctness includes the actualy applied conversion rate and various fees.
- Column `PAYPROV`: The pay provider such as PayPal. You can use the picklist `PICKLIST_PAYPROVIDER`.
- Column `ANNOTATION`: It is recommended to enter the name of the commission(s) here. Maybe also the bank statement number that you have compared with.

#### Artist/Client window tab "Events"

The database grid has the following columns:
- Column `DATE`: The date of the event.
- Column `STATE` can have the following values:
	- `annot`: Annotation
	- `offer`: An offer (maybe even a special) one
	- `start coop`: Start of cooperation (will change the Status field in the artist/client overview)
	- `end coop`: End of cooperation (will change the Status field in the artist/client overview)
	- `stoppped`: Stopped service for everyone (will change the Status field in the artist/client overview)
	- `hiatus`: Announced hiatus (will change the Status field in the artist/client overview)
	- `inactive`: Noticed as inactive without announcement (will change the Status field in the artist/client overview)
	- `recover`: Reverts a previously set `hiatus` or `inactive` status (will change the Status field in the artist/client overview)
	- `born`: Birthday of the artist/client
	- `deceased`: Death of the artist/client (will change the Status field in the artist/client overview)
- Column `ANNOTATION`: Here you can enter any useful information.

#### Artist/Client window tab "Communication"

The database grid has the following columns:
- Column `CHANNEL`: You can enter anything here, and additionally select from the picklist `PICKLIST_COMMUNICATION`. Typical things are "E-Mail-Adress", "Postal address", "Discord", "Telegram", but you can also use it to enter any other personal things.
- Column `ADDRESS`: Set the "address" or "thing" referenced by the channel.
- Column `ANNOTATION`: Here you can enter any useful information.

### Commission window

#### Commission window events

The database grid has the following columns:
- Column `DATE`: The date of the event.
- Column `STATE` can have the following values:
	- `idea`: This marks the commission as idea. Nothing has yet been decided.
	- `c td initcm`: The client ("c") needs to do ("td") the initial commission ("initcm") description, which means they must contact the artist and tell what he wants to commish.
	- `c aw ack`: The client ("c") awaits ("aw") that the commission is accepted/acknowledged ("ack").
	- `ack`: The artist has accepted/acknowledged ("ack") the commission.
	- `quote`: A quote has been entered. **If this event is selected, a new tab "Quote" will be shown!**
	- `c aw sk`: The client ("c") waits ("aw") a sketch ("sk").
	- `c td feedback`: The client ("c") needs to do ("td") a feedback report for a sketch/WIP he has received.
	- `c aw cont`: The client ("c") waits ("aw") that the artwork is continue ("cont") after the first sketch has been approved.
	- `c aw hires`: The client ("c") waits ("aw") the final, high-resolution file (for digital art), or the painting shipped (for physical art).
	- `fin`: The artwork is finished ("fin"). This sets the `END_DATE` status in the commission overview.
	- `annot`: Annotation
	- `cancel a`: The artist ("a") has canceled the commission.
	- `cancel c`: The client ("c") has canceled the commission.
	- `rejected`: The commission was rejected.
	- `postponed`: The commission has been postponed.
	- `upload a`: The commission has been uploaded by the artist ("a"). This will change the `UPLOAD_A` column in the artist/client/commission overview. **If this event is selected, a new tab "Upload" will be shown!**
	- `upload c`: The commission has been uploaded by the client ("c"). This will change the `UPLOAD_C` column in the artist/client/commission overview. **If this event is selected, a new tab "Upload" will be shown!**
	- `upload x`: The commission has been uploaded by any other party ("x"). **If this event is selected, a new tab "Upload" will be shown!**
- Column `ANNOTATION`: Here you can enter any useful information. For the events "upload a", "upload c", "upload x", and "quote", the field will be automatically filled.

#### Commission window quotes

You can create a quote by creating an event with STATE "quote". Then, leave the row (arrow down) and enter it again (arrow up). At the bottom you will now see a "Quote" tab.

The database grid of the Quote tab has the following columns:
- Column `NO` contains a number you assign to keep a specific order.
- Column `AMOUNT` contains the monetary amount.
- Column `CURRENCY` contains the currency.
- Column `AMOUNT_LOCAL` contains the amount in the local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.
- Column `IS_FREE`: A value of "True" marks the line as free, i.e. the client doesn't have to pay for this item.
- Column `DESCRIPTION` contains a description, e.g. if you want to break down the quote into components such as background, extra character, style, extra shading, free, etc.

#### Commission window uploads

You can create a quote by creating an event with STATE "upload a" (upload by artist), "upload c" (upload by client), or "upload x" (upload by foreign person). Then, leave the row (arrow down) and enter it again (arrow up). At the bottom you will now see an "Upload" tab.

The database grid of the Upload tab has the following columns:
- Column `NO` contains a number you assign to keep a specific order.
- Column `PAGE` contains the art page. You can choose from the picklist `PICKLIST_ARTPAGES`.
- Column `URL` contains the URL to the submission.
- Column `PROHIBIT`: Enter "True" if you want to mark that this artwork must not be uploaded.
- Column `ANNOTATION`: Here you can enter any useful information, e.g. the revision and variant that was uploaded (in case there are multiple).

#### Commission window "Files" tab

Here you can add a path where the files of this artwork is stored. If the path is valid you can see the files in a list and open them too.

There are three button:
- Select: Opens a folder selection dialog as alternative to entering the path by hand.
- Save: Saves the selected folder to the commission, and refreshes the file list.
- Open: Opens the folder in Windows Explorer.
