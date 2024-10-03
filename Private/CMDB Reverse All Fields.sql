update ARTIST set NAME = reverse(NAME);
update ARTIST_EVENT set ANNOTATION = reverse(ANNOTATION);
update COMMISSION set NAME = reverse(NAME);
update COMMISSION_EVENT set ANNOTATION = reverse(ANNOTATION);
update COMMUNICATION set ADDRESS = reverse(ADDRESS);
update PAYMENT set ANNOTATION = reverse(ANNOTATION);
update QUOTE set DESCRIPTION = reverse(DESCRIPTION);