import re
import os

with open('stitch_dashboard.html', encoding='utf-8') as f:
    html = f.read()

urls_in_order = re.findall(r'src="(https://lh3[^"]+)"', html)

# The HTML has these images in order:
# 0: Profile Pic
# 1: Verse of the Day Background
# 2: Continue Journey 1
# 3: Continue Journey 2
# 4: Continue Journey 3
# 5: Continue Watching 1
# 6: Continue Watching 2
# 7: Continue Watching 3

names = [
    'profile.jpg',
    'verse_bg.jpg',
    'journey_1.jpg',
    'journey_2.jpg',
    'journey_3.jpg',
    'watch_1.jpg',
    'watch_2.jpg',
    'watch_3.jpg'
]

# We need to find which stitch_img_X.jpg corresponds to which url.
# Let's map URL to file content by checking which URL downloaded to which file... wait, we didn't save the mapping.
# It's better to just re-download them in order to specific files!

import urllib.request
for i, url in enumerate(urls_in_order):
    if i < len(names):
        filename = f'assets/images/dashboard/{names[i]}'
        print(f"Downloading {url} to {filename}")
        try:
            urllib.request.urlretrieve(url, filename)
        except Exception as e:
            print(f"Error: {e}")
