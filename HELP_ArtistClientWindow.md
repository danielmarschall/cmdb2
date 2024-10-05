
[General info](README.md) | [Database window](HELP_DatabaseWindow.md) | [Mandator window](HELP_MandatorWindow.md) | Artist/Client window | [Commission window](HELP_CommissionWindow.md) | [Statistics](HELP_Statistics.md)

# Artist/Client window

## Artist/Client window tab "Commissions"

The database grid has the following columns:
- Column `NAME` contains a name you give the commission. This is the only field you can edit.
- Column `START_DATE` contains the start date of the commission (earliest "event" of a commission such as "aw sk"; excluded events are "quote", "annot", "upload a", "upload c", "upload x", "idea", and "c td initcm"
- Column `END_DATE` contains the end date of a commission (the "fin" event of a commission)
- Column `ART_STATUS` contains the latest commission event such as "aw sk" or "fin"; excluded are the events "quote", "upload a", "upload c", "upload x", and "annot"
- Column `PAY_STATUS` contains the payment status of the commission, which is `Paid`, `PART. PAID` (partially paid), or `NOT PAID`, including the amount and currency. (Can have multiple statements, if multiple currencies were used)
- Column `UPLOAD_A` contains the information if the artwork was uploaded by the artist (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload a" event in the commission).
- Column `UPLOAD_C` contains the information if the artwork was uploaded by the client (values `Yes`, `No`, or `Prohibit`, which are taken from the "upload c" event in the commission).
- Column `AMOUNT_LOCAL` contains the amount in the local currency. This value is only correct if `AMOUNT_LOCAL` in the commission events is entered (or automatically converted) correctly.

## Artist/Client window tab "Payments"

When you add payments, please take care that the currency is the same as the currency in the commission, otherwise the program cannot calculate the debt/credit by subtracting the sum of commission quotes from the sum of payments.

The database grid has the following columns:
- Column `DATE`: Date of the payment
- Column `AMOUNT`: The amount in the target currency sent from the client to the artist. The value is always positive (except for refunds, then it is negative).
- Column `CURRENCY`: The currency
- Column `AMOUNT_LOCAL`: The amount in the local currency.
- Column `AMOUNT_VERIFIED`: Set this to "True" when you have verified that the local amount is correct (i.e. after checking your bank statement). The correctness includes the actualy applied conversion rate and various fees.
- Column `PAYPROV`: The pay provider such as PayPal. You can use the picklist `PICKLIST_PAYPROVIDER`.
- Column `ANNOTATION`: It is recommended to enter the name of the commission(s) here. Maybe also the bank statement number that you have compared with.

When is the currency converted? When all these criteria have been fulfilled:
- `AMOUNT_VERIFIED` must be "False".
- You change the field "Amount" or "Currency" and save the row (leave the line).
- "Currency" must be a valid 3-letter code currency, e.g. `USD`
- In the configuration you need to have `LOCAL_CURRENCY` filled with a valid 3-letter code currency, e.g. EUR
- In the configuration you need to have `CURRENCY_LAYER_API_KEY` filled with a valid API key from [CurrencyLayer.com](https://CurrencyLayer.com/)

## Artist/Client window tab "Events"

The database grid has the following columns:
- Column `DATE`: The date of the event.
- Column `STATE` can have the following values:
	- `annot`: Annotation
	- `offer`: An offer (maybe even a special) one
	- `start coop`: Start of cooperation (will change the Status field in the artist/client overview)
	- `end coop`: End of cooperation (will change the Status field in the artist/client overview)
	- `stopped`: Stopped service for everyone (will change the Status field in the artist/client overview)
	- `hiatus`: Announced hiatus (will change the Status field in the artist/client overview)
	- `inactive`: Noticed as inactive without announcement (will change the Status field in the artist/client overview)
	- `recover`: Reverts a previously set `hiatus` or `inactive` status (will change the Status field in the artist/client overview)
	- `born`: Birthday of the artist/client
	- `deceased`: Death of the artist/client (will change the Status field in the artist/client overview)
- Column `ANNOTATION`: Here you can enter any useful information.

## Artist/Client window tab "Communication"

The database grid has the following columns:
- Column `CHANNEL`: You can enter anything here, and additionally select from the picklist `PICKLIST_COMMUNICATION`. Typical things are "E-Mail-Adress", "Postal address", "Discord", "Telegram", but you can also use it to enter any other personal things.
- Column `ADDRESS`: Set the "address" or "thing" referenced by the channel.
- Column `ANNOTATION`: Here you can enter any useful information.

