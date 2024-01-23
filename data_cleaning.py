# Data Clean Up

# First, let's figure out how to automate downloading of the data sheets from Google Drive

# Requires Python API 
# In terminal, pip install gspread

import gspread as gs 
import pandas as pd

# Need to first authorize
gc = gs.oauth() 

# Open sheet
sh = gc.open("CDFA - Plating")
# Get worksheets
dfs = []
for worksheet in sh.worksheets():
    if "CDFA" in worksheet.title:
        ws = sh.worksheet(worksheet.title)
        records = ws.get_all_records()
        df = pd.DataFrame(records)
        dfs.append(df)
print(dfs[1].head())

# extractions = pd.DataFrame(sh.get_worksheet(0).get_all_records())
# print(extractions.head())

# To get the correct worksheets, can do a forloop
# Need to figure out how to pull all worksheet names, then loop through every one
# not equal to "Example Data" or "Plate Layout"