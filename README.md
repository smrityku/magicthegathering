This command line tool uses only this URL "https://api.magicthegathering.io/v1/cards". This API returns maximum 100 records at a time, also there is a Rate Limiting mechanism and the task is not to use any query parameters.

** Here are the possible command line options for my solution:

Usage: mtg_api [options]
-    -l, --load-data     :    Call magicthegathering and load data into **`data.json`** file
-    -f, --first-query   :    Returns a list of **Cards** grouped by **`set`**
-    -s, --second-query  :    Returns a list of **Cards** grouped by **`set`** and within each **`set`** grouped by **`rarity`**
-    -t, --third-query   :    Returns a list of cards from the  **Khans of Tarkir (KTK)** set that ONLY have the colours `red` **AND** `blue`
-    -h, --help          :    Prints this help

** Output is saved into **`output.log`** file, since the output is hard to read in terminal.
