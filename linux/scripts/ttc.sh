#!/bin/bash
echo Downloading TTC PriceTable....
curl -s -o /tmp/PriceTable.zip 'https://eu.tamrieltradecentre.com/download/PriceTable'
echo Unzipping...
unzip -o -q /tmp/PriceTable.zip -d "$HOME/Documents/Elder Scrolls Online/live/AddOns/TamrielTradeCentre/"
echo Done!

