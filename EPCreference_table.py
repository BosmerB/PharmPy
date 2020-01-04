# -*- coding: utf-8 -*-
"""
Created on Fri Apr 12 10:19:07 2019

@author: blee 
"""

"""
the following script creates a table of established pharmacological 
classes (EPCS) and associated class members (the substances themselves) using 
National Library of Medicine's RxClass API.

1.Returns all EPC names
2.Returns all class members of each EACH
3.Replaces "precise ingredients" with general "ingredient" for instances in 
which a precise ingredient is returned. 
"""


import numpy as np
import requests
import pandas as pd
from collections import defaultdict 


"""RETRIEVING A LIST OF EPCS""" 

#URL for API
drug_class_url =\
 ("https://rxnav.nlm.nih.gov/REST/rxclass/allClasses.json?classTypes=EPC")

#API call and response... to dataframe
cr = requests.get(drug_class_url)

epc_json = cr.json()

dc_df = (pd.DataFrame.from_dict(
        epc_json["rxclassMinConceptList"]["rxclassMinConcept"]))

#Dropping classIds beginning with string "EPC" (not valid classes)
epc_rows = dc_df.classId.str.startswith("EPC")
dc_df_clean = dc_df.loc[~ epc_rows].reset_index(drop=True)



"""BUILDING DRUG CLASS TO SUBSTANCE NAME REFERENCE TABLE"""


#API call and response
mid_table_list = []
for classId in dc_df_clean["classId"]:
    class_member_url =\
    f"https://rxnav.nlm.nih.gov/REST/rxclass/classMembers.json?classId={classId}&relaSource=FDASPL&rela=has_EPC"
    
    cmr = requests.get(class_member_url)
    
    member_json = cmr.json()

#culls invalid instances where class has no applicable class members.
    if "drugMemberGroup" in member_json:      
        
        maxpos= len(member_json["drugMemberGroup"]["drugMember"])
    
        dicts = []
        for i in range(0,maxpos):
            (dicts.append(member_json["drugMemberGroup"]["drugMember"][i]
            ["minConcept"]))
            
            (print(member_json["drugMemberGroup"]["drugMember"][i]["minConcept"]
            ["name"]))
        
        mid_table = pd.DataFrame.from_dict(dicts)
        
        mid_table["classId"] = member_json["userInput"]["classId"]
        
        mid_table_list.append(mid_table)
    else:
        print("\nNot Valid!\n")
  
members_df = pd.concat(mid_table_list)

#connecting class member and corresponding EPC class 
ref_table = pd.merge(left=dc_df_clean, right=members_df, on = "classId")
 



"""CREATING PINS SUBTABLE"""    
               
pins_df = ref_table.loc[ref_table.tty == "PIN"]

pins_df["rxcui"]


#creating list of INS that correspondes to PINS
dicts = []

#API call and response
for i in pins_df["rxcui"]:
    in_json_url = "https://rxnav.nlm.nih.gov/REST/rxcui/" +\
    str(i) +\
    "/related.json?tty=IN"
    
    r = requests.get(in_json_url)
    
    json_data = r.json()
    
    #APPEND PIN RXCUI TO DICTIONARY WITH RELATED IN RXCUI   
    subs_dict = (json_data["relatedGroup"]["conceptGroup"][0]
    ["conceptProperties"][0])
    
    subs_dict["PIN_rxcui"] = json_data["relatedGroup"]["rxcui"]
    
    dicts.append(subs_dict)
    
    print(subs_dict)
    
#creating single dictionary from list, then creating df resulting dict
single_dict = defaultdict(list)      
for i in dicts:
    for key, value in i.items():
        single_dict[key].append(value)   
        
pin2in_df = pd.DataFrame.from_dict(single_dict)
    
    
#merging pin2in reference table to complete ref table 
allin_ref_table = (pd.merge(ref_table, pin2in_df, how="left", 
                            left_on = "rxcui", right_on="PIN_rxcui"))

#filtering down to PIN records
pinloc = allin_ref_table["tty_x"] == "PIN"


#Replacing values of rexcui_x, name_x, and tty_x for PIN records
#with values from related IN values
allin_ref_table.loc[pinloc, ["rxcui_x","name_x", "tty_x"]] = np.nan

allin_ref_table.rxcui_x = (allin_ref_table.rxcui_x.combine_first
                           (allin_ref_table.rxcui_y))

allin_ref_table.name_x = (allin_ref_table.name_x.combine_first
                          (allin_ref_table.name_y))

allin_ref_table.tty_x = (allin_ref_table.tty_x.combine_first
                         (allin_ref_table.tty_y))


#removing unneccesary columns following pin2in replacement
#dropping duplicate records 
ref_clean = allin_ref_table.iloc[:,0:6].drop_duplicates()

#dropping records where EPC is labled as "EPC" (not valid)
epcloc = ref_clean["className"] != "Established Pharmacologic Class (EPC)"
final_ref = ref_clean.loc[epcloc].sort_values("className")

#cleaning up column names 
final_ref.columns = (["class_id","class_name","class_type","substance_name",
                      "rxcui","tty"])



