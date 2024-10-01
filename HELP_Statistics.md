
[General info](README.md) | [Database window](HELP_DatabaseWindow.md) | [Mandator window](HELP_MandatorWindow.md) | [Artist/Client window](HELP_ArtistClientWindow.md) | [Commission window](HELP_CommissionWindow.md) | Statistics

# Statistics

There are various statistics that are made available with plugins which are located in the directory
**C:\Program Files...\Commission Database 2.0\Plugins** and have the file name extension "SPL" (Statistics Plugin).

Note that "statistics" can be "anything" - the plugin author can freely design which information to show
and what happens when you double click an entry.
So, for example, a plugin can also be used to perform actions such as comparing the UPLOAD table
with a website/gallery and listing the difference.

## Plugins\BasicStatsPlugin.spl

Currently, there are the following statistics in the shipped statistics plugin:
- Running commissions
- Local sum over years (commissions outgoing)
- Local sum over months (commissions outgoing)
- Top artists/clients

In the statistic grids you can double click to list more information and/or to jump to the referenced artists, commissions, etc.

Note that deleting from a statistic grid deletes the data in the base table, so be extra careful.
