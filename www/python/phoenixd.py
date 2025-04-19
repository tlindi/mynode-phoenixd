from flask import Blueprint, render_template, redirect
from user_management import check_logged_in
from enable_disable_functions import *
from device_info import *
from application_info import *
from systemctl_info import *
import subprocess
import os


mynode_phoenixd = Blueprint('mynode_phoenixd',__name__)


### Page functions (have prefix /app/<app name/)
@mynode_phoenixd.route("/info")
def phoenixd_page():
    check_logged_in()

    app = get_application("phoenixd")
    app_status = get_application_status("phoenixd")
    app_status_color = get_application_status_color("phoenixd")

    # Load page
    templateData = {
        "title": "myNode - " + app["name"],
        "ui_settings": read_ui_settings(),
        "app_status": app_status,
        "app_status_color": app_status_color,
        "app": app
    }
    return render_template('/app/phoenixd/phoenixd.html', **templateData)

import requests

def catch_phoenixd_errors(func):
    """
    A decorator to catch and handle errors for PhoenixD operations.
    """
    def wrapper(*args, **kwargs):
        try:
            # Execute the wrapped function
            return func(*args, **kwargs)
        except requests.exceptions.ConnectionError:
            return "Error: phoenixd service is unavailable. Please try again later.", 503
        except requests.exceptions.HTTPError as http_err:
            return f"HTTP error occurred: {http_err}", 500
        except requests.exceptions.Timeout:
            return "Error: The request timed out to phoenixd. Please try again later.", 504
        except Exception as e:
            return f"An unexpected error occurred: {str(e)}", 500
    return wrapper

def get_http_password():
    config_file_path = "/mnt/hdd/mynode/phoenixd/phoenix.conf"
    try:
        if not os.path.exists(config_file_path):
            raise Exception(f"Config file not found: {config_file_path}")
        print("Config file found:", config_file_path)

        with open(config_file_path, "r") as file:
            for line in file:
                if line.startswith("http-password="):
                    return line.strip().split("=", 1)[1]

        raise Exception("http-password not found in the configuration file.")
    except Exception as e:
        print(f"Error reading config file: {e}")
        raise Exception(f"Error reading the configuration file: {e}")

import base64
import requests

@mynode_phoenixd.route("/getinfo")
@catch_phoenixd_errors
def getinfo_page():
    check_logged_in()

    server_url = "http://127.0.0.1:9740/getinfo"
    http_password = get_http_password()
    encoded_credentials = base64.b64encode(f":{http_password}".encode()).decode()
    headers = {"Authorization": f"Basic {encoded_credentials}"}

    response = requests.get(server_url, headers=headers)
    response.raise_for_status()

    if response.status_code == 200:
        data = response.json()

        def shorten_id(value):
            if isinstance(value, str) and len(value) > 15:
                return f"{value[:5]}*****{value[-5:]}"
            return value

        unified_table = "<h3>GetInfo</h3><table border='1' style='width:100%; border-collapse:collapse;'>"
        unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>General Info</td></tr>"
        for key, value in data.items():
            if key != "channels" and not key.endswith("Sat"):
                unified_table += f"<tr><td>{key}</td><td>{shorten_id(value)}</td></tr>"

        unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>Satoshi Values</td></tr>"
        for key, value in data.items():
            if key.endswith("Sat") and key != "channels":
                unified_table += f"<tr><td>{key}</td><td>{value}</td></tr>"
        for channel in data.get("channels", []):
            for key, value in channel.items():
                if key.endswith("Sat"):
                    unified_table += f"<tr><td>{key}</td><td>{value}</td></tr>"

        unified_table += "<tr><td colspan='2' text-align:center; font-weight:bold;'>Channel Info</td></tr>"
        for channel in data.get("channels", []):
            for key, value in channel.items():
                if not key.endswith("Sat"):
                    unified_table += f"<tr><td>{key}</td><td>{shorten_id(value)}</td></tr>"

        unified_table += "</table>"
        return unified_table

    return f"Error: Failed to fetch getinfo data, Status Code: {response.status_code}", 500
