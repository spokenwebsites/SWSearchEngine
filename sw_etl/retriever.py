import requests
import json

data = [
    {"label": "Concordia University", "id": 4},
    {"label": "Simon Fraser University", "id": 9},
    {"label": "Victoria University in the University of Toronto", "id": 10},
    {"label": "Harvard University", "id": 11},
    {"label": "Banff Centre for Arts and Creativity", "id": 12},
    {"label": "University of Calgary", "id": 13},
    {"label": "University of Toronto", "id": 14},
    {"label": "University of British Columbia, Okanagan", "id": 15},
    {"label": "ARCMTL", "id": 16},
    {"label": "Community", "id": 17},
    {"label": "University of Alberta", "id": 104},
    {"label": "UC Davis", "id": 163},
    {"label": "University of Ottawa", "id": 169}
]

#iterate through the data and make a request for each item
for item in data:
    #make a request to the API
    response = requests.get("https://swallow.library.concordia.ca/v2/Controller/export.php?institution=-1&cataloguer=-1&class="+str(item["id"])+"&schema=spoken_web&query=&format=1")
    #parse the JSON response
    json_response = response.json()
    #save the JSON response to a file using item.label as name
    with open("/results/json/" + item["label"] + ".json", "w") as file:
        json.dump(json_response, file)

