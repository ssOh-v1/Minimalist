import os
import spotipy
from spotipy.oauth2 import SpotifyOAuth

# Замени на свои данные
CLIENT_ID = "ТВОЙ_CLIENT_ID"
CLIENT_SECRET = "ТВОЙ_CLIENT_SECRET"
REDIRECT_URI = "http://127.0.0.1:8888/callback"
SCOPE = "user-library-read playlist-read-private"

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    redirect_uri=REDIRECT_URI,
    scope=SCOPE,
    cache_path=os.path.expanduser("~/.config/hypr/scripts/.spotify_cache")
))
print("Авторизация успешна!")
