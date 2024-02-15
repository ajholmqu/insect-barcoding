# Data Clean Up

# First, let's figure out how to automate downloading of the data sheets 
# from Google Drive

# Requires Python API 
# In terminal, pip install gspread

import gspread as gs 
import pandas as pd

# Need to first authorize
gc = gs.oauth() 

### Dealing with CDFA's multiple tabs first ###

# Plating Data
# Open relevant sheet
cdfa_plating = gc.open("CDFA - Plating")
# Create empty list
plating = []
# List of columns want to select
plating_columns = ['catalog', 'well', 'plate', 'preservation', 
                   'body_part', 'flagged', 'notes']

# Loop through all worksheets in plating data sheet
for worksheet in cdfa_plating.worksheets():
    # Get title of current worksheet
    ws = worksheet.title
    # There are example sheets; select only real data sheets
    if "CDFA" in ws and ws != "CDFA_P2_transfer":
        # Get the whole dataframe
        records = worksheet.get_all_records()
        # Make in to data frame and select desired columns
        df = pd.DataFrame(records)[plating_columns]
        # Add to list
        plating.append(df)
# Merge all dataframes within list
plating_merged = pd.concat(plating, ignore_index = True)

# Metadata - similar to above 
cdfa_meta = gc.open("CDFA - Metadata")
meta = []
meta_columns = ['Catalog','Order','Family','Genus', 'Species','Event Date']
for worksheet in cdfa_meta.worksheets():
    ws = worksheet.title
    if "CDFA" in ws and ws != "CDFA":
        records = worksheet.get_all_records()
        df = pd.DataFrame(records)
        df = df[meta_columns]
        meta.append(df)
meta_merged = pd.concat(meta, ignore_index = True)
# Lower case column names
meta_merged.columns = [x.lower() for x in list(meta_merged.columns)]

# Join the data frames
cdfa_merged = plating_merged.join(meta_merged.set_index('catalog'), 
                                  on = 'catalog', how = 'inner')
# Change the plate to match what we have been using
cdfa_merged['plate'] = 'CDFA_' + cdfa_merged['plate']

# CAS plating data
cas_plating = gc.open("Plating")
cas_plating = pd.DataFrame(cas_plating.get_worksheet(0).get_all_records())

# CAS SERPA metadata
serpa = gc.open("serpa_metadata")
cas_meta = pd.DataFrame(serpa.get_worksheet(0).get_all_records())

# Merging and filtering
cas_merged = cas_plating.join(cas_meta.set_index('catalog'), 
                              on = 'catalog', how = 'inner')
plating_columns = ['catalog', 'well', 'plate', 'preservation', 
                   'body_part', 'flagged', 'notes']
meta_columns = ['order', 'family', 'genus', 'species', 'event date']
all_cols = plating_columns + meta_columns
cas_merged = cas_merged[all_cols]

# Combine with CDFA data
df_concat = pd.concat([cas_merged, cdfa_merged], ignore_index = True)