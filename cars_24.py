# importing libraries
import pandas as pd
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
import requests

# Function to initialize the WebDriver and perform scrolling
def initialize_driver(url):
    driver = webdriver.Chrome()
    driver.get(url)
    SCROLL_PAUSE_TIME = 7
    last_height = driver.execute_script("return document.body.scrollHeight")

    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(SCROLL_PAUSE_TIME)
        new_height = driver.execute_script("return document.body.scrollHeight")
        if new_height == last_height:
            break
        last_height = new_height

    return driver

# Function to extract links from the webpage
def extract_links(driver):
    elements = driver.find_elements(By.CSS_SELECTOR, 'a.IIJDn')
    links = [element.get_attribute("href") for element in elements if element.get_attribute("href")]
    return links

# Function to extract data from each car listing
def extract_car_data(link):
    response = requests.get(link)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    try:
        # Extract car details
        car_model = soup.find('h1', class_='_2Ximl').text.split()[0]
        brand = soup.find('h1', class_='_2Ximl').text.split()[1]
        car_name = soup.find('h1', class_='_2Ximl').text.split()[2]
        car_variant = " ".join(soup.find('h1', class_='_2Ximl').text.split()[3:])
        
        # Extract list details
        li_text = [li.get_text() for li in soup.find('ul', class_='_2JSmz').find_all('li')]
        car_transmission = li_text[3]
        km_driven = li_text[0]
        owner_type = li_text[1]
        fuel_type = li_text[2]
        
        # Extract additional details
        registration_id = ""
        more_details = soup.find_all('strong', class_='_3gHeV')
        if len(more_details) > 2:
            registration_id = more_details[2].get_text()
        
        monthly_emi = soup.find('strong', class_='_3i9_p _3d4o3').text.split('/')[0]
        car_price = soup.find_all('strong', class_='_3i9_p')[1].text
        downpayment_amount = soup.find('label', class_='F6S7B').text.replace(" down payment", "").replace(" ", "")
        location = soup.find('li', class_='_1Rvdw').find('strong').text
        
        return {
            'Car_Model': car_model,
            'Brand': brand,
            'Car_Name': car_name,
            'Car_Variant': car_variant,
            'Car_Transmission': car_transmission,
            'KM_Driven': km_driven,
            'Owner_Type': owner_type,
            'Fuel_Type': fuel_type,
            'Registration_ID': registration_id,
            'Monthly_EMI': monthly_emi,
            'Car_Price': car_price,
            'Downpayment_Amount': downpayment_amount,
            'Location': location
        }
    except Exception as e:
        print(f"Error processing {link}: {e}")
        return {}

# Function to process a URL
def process_url(url, limit=500):
    driver = initialize_driver(url)
    links = extract_links(driver)
    driver.quit()
    
    # Extract data from each link and store it in a list of dictionaries
    data = []
    for link in links[:limit]:  # Limiting to the first 'limit' links
        car_data = extract_car_data(link)
        if car_data:
            data.append(car_data)
    
    return data

# Main function to run the extraction process for both URLs and save to CSV
def main():
    urls = [
        "https://www.cars24.com/buy-used-cars-delhi-ncr/",
        "https://www.cars24.com/buy-used-cars-hyderabad/"
    ]
    
    all_data = []
    for url in urls:
        url_data = process_url(url)
        all_data.extend(url_data)
    
    # Create a DataFrame and save it to a CSV file
    df = pd.DataFrame(all_data)
    df.to_csv('car_data.csv', index=False)
    print("Data has been written to 'car_data.csv'")

if __name__ == "__main__":
    main()
