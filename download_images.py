import re
import urllib.request
import os

with open('stitch_dashboard.html', encoding='utf-8') as f:
    html = f.read()

urls = set(re.findall(r'src="(https://lh3[^"]+)"', html))
os.makedirs('assets/images/dashboard', exist_ok=True)

for i, url in enumerate(urls):
    filename = f'assets/images/dashboard/stitch_img_{i}.jpg'
    print(f"Downloading {url} to {filename}")
    try:
        urllib.request.urlretrieve(url, filename)
    except Exception as e:
        print(f"Failed to download {url}: {e}")
