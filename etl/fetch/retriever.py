import os
import requests
import json

with open("partners.json") as partners:
    data = json.load(partners)

os.makedirs('../data/json', exist_ok=True)
os.makedirs('../data/output', exist_ok=True)

#iterate through the data and make a request for each item
for item in data:
    #make a request to the API
    print("Conecting to swallow to get the records for: "+item["label"])
    response = requests.get("https://swallow.library.concordia.ca/v2/Controller/export.php?institution=-1&cataloguer=-1&class="+str(item["id"])+"&schema=spoken_web&query=&format=1")
    #parse the JSON response
    json_response = response.json()
    file_path = "../data/json/" + item["label"] + ".json"
    print("writing the record data to: "+file_path)
    #save the JSON response to a file using item.label as name
    with open(file_path, "w") as file:
        json.dump(json_response, file)
    print("done")

