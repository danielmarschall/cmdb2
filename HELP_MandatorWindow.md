
[General info](README.md) | [Database window](HELP_DatabaseWindow.md) | Mandator window | [Artist/Client window](HELP_ArtistClientWindow.md) | [Commission window](HELP_CommissionWindow.md)

# Mandator window

## Mandator window tabs "Artists" and "Clients"

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

## Mandator window tab "Commissions"

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

## Mandator window tab "Payments"

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

## Mandator window tab "Statistics"

There are various statistics that can be easily extended in the database without changing the program code.

Currently, there are the following statistics:
- Running commissions
- Local sum over years (commissions outgoing)
- Local sum over months (commissions outgoing)
- Top artists/clients
- Full Text Export
