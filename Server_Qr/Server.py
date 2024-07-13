from flask import Flask, request, jsonify
import requests
import time
import tkinter as tk
from tkinter import ttk
import json
import os
from dotenv import load_dotenv


def getAPI():
    load_dotenv()
    API_KEY = os.getenv("API_KEY")
    return API_KEY

app = Flask(__name__)

def submit_and_analyze_url(url_to_analyze):
    submit_url = "https://www.virustotal.com/api/v3/urls"
    payload = {"url": url_to_analyze}
    headers = {
        "accept": "application/json",
        "x-apikey": getAPI(),  
        "content-type": "application/x-www-form-urlencoded"
    }

    submit_response = requests.post(submit_url, data=payload, headers=headers)
    submit_response_json = submit_response.json()

    analysis_id = submit_response_json['data']['id']
    print(f"Analysis ID: {analysis_id}")

    analysis_url = f"https://www.virustotal.com/api/v3/analyses/{analysis_id}"
    
    while True:
        analysis_response = requests.get(analysis_url, headers=headers)
        analysis_response_json = analysis_response.json()

        # Check if the analysis is done
        if analysis_response_json['data']['attributes']['status'] != 'queued':
            break

        # Wait for a short time before checking again
        time.sleep(1)



    return analysis_response_json

import threading

def display_results(analysis_response_json):
    def run_gui():
        root = tk.Tk()
        root.title("Analysis Results")

        columns = ("Attribute", "Value")
        tree = ttk.Treeview(root, columns=columns, show="headings")
        tree.heading("Attribute", text="Attribute")
        tree.heading("Value", text="Value")

        if 'data' in analysis_response_json and 'attributes' in analysis_response_json['data']:
            attributes = analysis_response_json['data']['attributes']
            tree.insert("", tk.END, values=("Status", attributes.get('status', 'N/A')))
            tree.insert("", tk.END, values=("Harmless", attributes['stats'].get('harmless', 0)))
            tree.insert("", tk.END, values=("Malicious", attributes['stats'].get('malicious', 0)))
            tree.insert("", tk.END, values=("Suspicious", attributes['stats'].get('suspicious', 0)))
            tree.insert("", tk.END, values=("Undetected", attributes['stats'].get('undetected', 0)))
            tree.insert("", tk.END, values=("Timeout", attributes['stats'].get('timeout', 0)))

        tree.pack(expand=True, fill='both')
        root.mainloop()

    threading.Thread(target=run_gui).start()


@app.route('/submit_url', methods=['POST'])
def analyze_url():
    data = request.json
    url_to_analyze = data.get('url')
    if not url_to_analyze:
        return jsonify({"error": "URL is required"}), 400
    
    print(url_to_analyze)
    analysis_results = submit_and_analyze_url(url_to_analyze)
    display_results(analysis_results)  # Display the results in a GUI window
    
    # Extract the results from the analysis_results
    if 'data' in analysis_results and 'attributes' in analysis_results['data']:
        results = analysis_results['data']['attributes']['stats']
    else:
        results = {}
        
    with open('results.json', 'w') as f:
        json.dump(results, f)
        
    return jsonify(results)



if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
    
    
