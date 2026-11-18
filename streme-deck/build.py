import json, os, uuid, zipfile, shutil

PORTALS = [
    ("Microsoft 365 admin center", "https://admin.microsoft.com"),
    ("Entra admin center", "https://entra.microsoft.com"),
    ("Azure Portal", "https://portal.azure.com"),
    ("Intune admin center", "https://intune.microsoft.com"),
    ("Defender / Security portal", "https://security.microsoft.com"),
    ("Purview compliance", "https://purview.microsoft.com"),
    ("Exchange admin center", "https://admin.exchange.microsoft.com"),
    ("Teams admin center", "https://admin.teams.microsoft.com"),
]

PROFILE_NAME = "Work"
DEVICE_MODEL = "20GAT9901"  # Stream Deck XL (32 keys, 8x4)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
build_root = os.path.join(SCRIPT_DIR, "work-profile-source")
if os.path.exists(build_root):
    shutil.rmtree(build_root)

bundle_uuid = str(uuid.uuid4()).upper()
page_uuid = str(uuid.uuid4())

sd_root = os.path.join(build_root, "Profiles", f"{bundle_uuid}.sdProfile")
page_dir = os.path.join(sd_root, "Profiles", page_uuid)
os.makedirs(page_dir, exist_ok=True)

def new_action(name, url):
    return {
        "ActionID": str(uuid.uuid4()),
        "LinkedTitle": True,
        "Name": "Website",
        "Plugin": {
            "Name": "Website",
            "UUID": "com.elgato.streamdeck.system.website",
            "Version": "1.0",
        },
        "Resources": None,
        "Settings": {"browser": "", "openInBrowser": True, "path": url},
        "State": 0,
        "States": [
            {
                "Title": name,
            }
        ],
        "UUID": "com.elgato.streamdeck.system.website",
    }

actions = {}
cols = 8  # Stream Deck XL is 8 columns wide
for i, (title, url) in enumerate(PORTALS):
    col = i % cols
    row = i // cols
    actions[f"{col},{row}"] = new_action(title, url)

page_manifest = {
    "Controllers": [
        {"Type": "Keypad", "Actions": actions},
    ],
    "Icon": "",
    "Name": "",
}
with open(os.path.join(page_dir, "manifest.json"), "w") as f:
    json.dump(page_manifest, f)

root_manifest = {
    "Device": {"Model": DEVICE_MODEL, "UUID": ""},
    "Name": PROFILE_NAME,
    "Pages": {
        "Current": "00000000-0000-0000-0000-000000000000",
        "Default": page_uuid,
        "Pages": [],
    },
    "Version": "3.0",
}
with open(os.path.join(sd_root, "manifest.json"), "w") as f:
    json.dump(root_manifest, f)

package_json = {
    "AppVersion": "7.2.1.22472",
    "DeviceModel": DEVICE_MODEL,
    "DeviceSettings": None,
    "FormatVersion": 1,
    "OSType": "Windows",
    "OSVersion": "10.0.26200",
    "RequiredPlugins": ["com.elgato.streamdeck.system.website"],
}
with open(os.path.join(build_root, "package.json"), "w") as f:
    json.dump(package_json, f)

out_zip = os.path.join(SCRIPT_DIR, "work-profile.streamDeckProfile")
if os.path.exists(out_zip):
    os.remove(out_zip)
with zipfile.ZipFile(out_zip, "w", zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(build_root):
        for file in files:
            full = os.path.join(root, file)
            rel = os.path.relpath(full, build_root)
            zf.write(full, rel)

print("Built:", out_zip)
print("Bundle UUID:", bundle_uuid)
print("Page UUID:", page_uuid)
