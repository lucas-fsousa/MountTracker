"""GET educado: cache em disco, rate-limit e retry com backoff.

So bate na rede quando a pagina nao esta em cache. User-Agent identificavel.
"""

import os
import re
import time
import urllib.request

DEFAULT_UA = ("MountTracker-curate/0.2 (community addon; "
              "https://github.com/lucas-fsousa/MountTracker)")


class Http:
    def __init__(self, cache_dir, delay=1.0, retries=3, ua=DEFAULT_UA, timeout=30):
        self.cache_dir = cache_dir
        self.delay = delay
        self.retries = retries
        self.ua = ua
        self.timeout = timeout

    def _cache_path(self, url):
        key = re.sub(r"[^a-zA-Z0-9]+", "_", url)[:180]
        return os.path.join(self.cache_dir, key)

    def get(self, url):
        os.makedirs(self.cache_dir, exist_ok=True)
        path = self._cache_path(url)
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                return f.read()
        last = None
        for attempt in range(self.retries):
            try:
                time.sleep(self.delay)  # so dorme quando realmente bate na rede
                req = urllib.request.Request(url, headers={"User-Agent": self.ua})
                body = urllib.request.urlopen(req, timeout=self.timeout).read().decode("utf-8", "replace")
                with open(path, "w", encoding="utf-8") as f:
                    f.write(body)
                return body
            except Exception as e:           # noqa: BLE001 -- tolerar qualquer falha de rede
                last = e
                time.sleep(1.5 * (attempt + 1))
        raise last
