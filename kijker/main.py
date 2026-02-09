from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common import action_chains
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os
import time
import glob

def wait_for_download(download_dir: str, timeout: int = 60, pattern: str = "*.csv") -> str:
    """Wait for a file matching the pattern to appear in the download directory."""
    seconds = 0
    dl_wait = True

    while dl_wait and seconds < timeout:
        time.sleep(1)
        dl_wait = False
        files = glob.glob(os.path.join(download_dir, pattern))

        if not files:
            dl_wait = True

        for fname in files:
            if fname.endswith(".crdownload") or fname.endswith(".tmp"):
                dl_wait = True
        seconds += 1

    if dl_wait:
        raise TimeoutError(f"Download did not complete within {timeout} seconds.")

    files = glob.glob(os.path.join(download_dir, pattern))
    if not files:
        raise FileNotFoundError(f"No file matching pattern '{pattern}' found in '{download_dir}' after download completed.")
    return max(files, key=os.path.getctime)

def dowload_file(url: str, selector_button: str, dest_path: str):
    """Download a file from a webpage using Selenium.
        1. Open the webpage.
        2. Click the download button.
        3. Wait for the download to complete.
    """

    abs_dest = os.path.abspath(dest_path)

    os.makedirs(dest_path, exist_ok=True)
    chrome_options = Options()
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")

    prefs = {
        "download.default_directory": abs_dest,
        "download.prompt_for_download": False,
        "download.directory_upgrade": True,
        "safebrowsing.enabled": True,
        "profile.default_content_setting_values.automatic_downloads": 1,
    }

    chrome_options.add_experimental_option("prefs", prefs)

    driver = webdriver.Chrome(options=chrome_options)

    driver.execute_cdp_cmd("Page.setDownloadBehavior", {
        "behavior": "allow",
        "downloadPath": abs_dest
    })

    try:
        driver.get(url)
        print("[DEBUG]: Page loaded, waiting for download button...")
        wait = WebDriverWait(driver, 20)
        button = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, selector_button)))
        
        print("[DEBUG]: Download button found, hovering...")

        print("[DEBUG]: Waiting for CSV option to be clickable...")
        action = ActionChains(driver)
        action.move_to_element(button).click().perform()

        downloaded_file = wait_for_download(abs_dest, timeout=600)

        print(f"[DEBUG]: Download completed, file saved to {downloaded_file}")
    except Exception as e:
        print(f"Error accessing {url}: {e}")
        driver.quit()
        return
    finally:
        driver.quit()

    print(f"[DEGUB]: Downloaded file to {dest_path}")

def main():
    # URL = "https://exoplanetarchive.ipac.caltech.edu/cgi-bin/TblView/nph-tblView?app=ExoTbls&config=PS"
    URL = "https://exoplanet.eu/catalog/all_fields/"
    SELECTOR_BUTTON = "export"
    DEST_PATH = "./sources"

    dowload_file(URL, SELECTOR_BUTTON, DEST_PATH)


if __name__ == "__main__":
    main()
