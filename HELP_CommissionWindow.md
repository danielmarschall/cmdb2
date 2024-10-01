
[General info](README.md) | [Database window](HELP_DatabaseWindow.md) | [Mandator window](HELP_MandatorWindow.md) | [Artist/Client window](HELP_ArtistClientWindow.md) | Commission window | [Statistics](HELP_Statistics.md)

# Commission window

## Commission window events

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

## Commission window quotes

You can create a quote by creating an event with STATE "quote". Then, leave the row (arrow down) and enter it again (arrow up). At the bottom you will now see a "Quote" tab.

The database grid of the Quote tab has the following columns:
- Column `NO` contains a number you assign to keep a specific order.
- Column `AMOUNT` contains the monetary amount.
- Column `CURRENCY` contains the currency.
- Column `AMOUNT_LOCAL` contains the amount in the local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.
- Column `IS_FREE`: A value of "True" marks the line as free, i.e. the client doesn't have to pay for this item.
- Column `DESCRIPTION` contains a description, e.g. if you want to break down the quote into components such as background, extra character, style, extra shading, free, etc.

When is the currency converted? When all these criteria have been fulfilled:
- In the commission quote, `IS_FREE` must be False, otherwise Local Amount will be automatically set to 0.
- You change the field "Amount" or "Currency" and save the row (leave the line).
- "Currency" must be a valid 3-letter code currency, e.g. `USD`
- In the configuration you need to have `LOCAL_CURRENCY` filled with a valid 3-letter code currency, e.g. EUR
- In the configuration you need to have `CURRENCY_LAYER_API_KEY` filled with a valid API key from [CurrencyLayer.com](https://CurrencyLayer.com/)

## Commission window uploads

You can create a quote by creating an event with STATE "upload a" (upload by artist), "upload c" (upload by client), or "upload x" (upload by foreign person). Then, leave the row (arrow down) and enter it again (arrow up). At the bottom you will now see an "Upload" tab.

The database grid of the Upload tab has the following columns:
- Column `NO` contains a number you assign to keep a specific order.
- Column `PAGE` contains the art page. You can choose from the picklist `PICKLIST_ARTPAGES`.
- Column `URL` contains the URL to the submission.
- Column `PROHIBIT`: Enter "True" if you want to mark that this artwork must not be uploaded.
- Column `ANNOTATION`: Here you can enter any useful information, e.g. the revision and variant that was uploaded (in case there are multiple).

## Commission window "Files" tab

Here you can add a path where the files of this artwork is stored. If the path is valid you can see the files in a list and open them too.

There are three button:
- Select: Opens a folder selection dialog as alternative to entering the path by hand.
- Save: Saves the selected folder to the commission, and refreshes the file list.
- Open: Opens the folder in Windows Explorer.
