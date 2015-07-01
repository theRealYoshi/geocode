Instructions:

1. hit "Cmd + Space" and type in "Terminal" to open up Terminal
2. Download the "geocoder.rb" script in a separate folder somewhere on your desktop
3. Put the original csv file with the original addresses in the same folder.
3a. Make sure its named "geocoder.csv"
3b. Make sure the columns "address", "city", "state", "zip" are in the columns and appropriately filled.
4. In terminal, change directory to that folder. You can do this usually with "cd /desktop/whateveryourfolderisnamedhere/"
5. Run "ruby geocoder.rb"
6. A "geocoded.csv" should appear in the same folder with all the columns as requested.

Caveats:

- You might have to install some gems on to your machine, specifically "json", "csv" & "open-uri". You can install gems with "gem install whichevergemyouwanttoinstall"
ex. "gem install json" #the download will happen with the latest version.
  - You can check to see if you have any these gems in terminal with "gem list"
  - If you don't have these gems you might have to setup your ruby environment (pain in the ass) but here's a link to getting started:
- I haven't tested this script out for a lot of responses. I would try out around 100 addresses first and then scale up to see if it can handle it. 
