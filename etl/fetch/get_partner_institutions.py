import os
import requests
import json

response = requests.get("https://swallow.library.concordia.ca/v2/Service/Custom/get-partners.php")
json_response = response.json()

clean = []

for institution in json_response:
    item= {}
    item["label"] = institution["label"]
    item["id"] = institution["id"]
    clean.append(item)


with open("partners.json","w") as file:
    
    json.dump(clean,file)    
