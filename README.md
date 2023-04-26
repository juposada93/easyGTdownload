# easyGTdownload
A simple way to download daily google trends data using R

One of the main problems using Google trends data is the fact that it only allows you to download daily data for relatively short periods. Once you attempt to download over six months it automatically gives you weekly data and once you cross the 5 years barrier, it gives you monthly data.
This code allows you to get daily data for longer periods, pulling all necessary queries from GT and performing splicing on them so that the data is ready to be used.

UPDATE: Unfortunately, google changed their policies and using gtrends is now unreliable
