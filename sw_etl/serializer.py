import os
import json
import dicttoxml


def combine_json_files(input_folder, output_file):
    combined_data = []

    # Iterate through all files in the folder
    for filename in os.listdir(input_folder):
        if filename.endswith(".json"):
            filepath = os.path.join(input_folder, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        combined_data.extend(data)
                    else:
                        combined_data.append(data)
            except Exception as e:
                print(f"Error reading {filename}: {e}")

    # Write combined data to output file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(combined_data, f, indent=2, ensure_ascii=False)

    print(f"Combined {len(combined_data)} items into {output_file}")

# Combine all JSON files into one
input_folder = "./data/json/"
output_file = "./data/output/combined.json"
combine_json_files(input_folder, output_file)

def read_json_files(directory):
    json_data = []
    for filename in os.listdir(directory):
        if filename.endswith('.json'):
            filepath = os.path.join(directory, filename)
            with open(filepath, 'r') as file:
                data = json.load(file)
                #iterate through the data and append to json_data
                for item in data:
                    json_data.append(item)
                
    return json_data


# Convert JSON file to XML
def merge_json_to_xml(json_data, output_file):
    xml_data = dicttoxml.dicttoxml(json_data, custom_root='root', attr_type=False, cdata=False)    
    with open(output_file, 'wb') as file:
        file.write(xml_data)

    
json_files_data = read_json_files(input_folder)
output_file_path_XML = './data/output/swallow-data-full.xml'
merge_json_to_xml(json_files_data, output_file_path_XML)

    
