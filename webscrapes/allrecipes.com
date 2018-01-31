from lxml import html,etree,cssselect
import urllib
import requests
from selenium import webdriver
import time
from selenium.webdriver.chrome.options import Options
chrome_options = Options()
chrome_options.add_argument("--window-size=1920,1080")
chrome_options.add_argument("headless")
browser = webdriver.Chrome(chrome_options=chrome_options)



#First is to extract all categories. This block of code will extract ALL LINKS from the page, so manual post-processing may be required
url = "http://allrecipes.com/recipes/?grouping=all"
browser.get(url)
innerHTML = browser.execute_script("return document.body.innerHTML")
tree = html.fromstring(innerHTML)
print tree.iterlinks()
for elem in tree.iterlinks():
    print elem[2]


#url is hard coded, but pass recipe lists to url and use below infinite scroll to extract all recipes from each page
url = "http://allrecipes.com/recipes/78/breakfast-and-brunch/"
browser.get(url)
innerHTML = browser.execute_script("return document.body.innerHTML")
tree = html.fromstring(innerHTML)
print tree.iterlinks()
for elem in tree.iterlinks():
    print elem[2]
lenOfPage = browser.execute_script("window.scrollTo(0, document.body.scrollHeight);var lenOfPage=document.body.scrollHeight;return lenOfPage;")
match=False
while(match==False):
        lastCount = lenOfPage
        time.sleep(5)
        element=browser.find_element_by_xpath('//*[@id="btnMoreResults"]')
        browser.execute_script("arguments[0].click();",element)
        time.sleep(5)
        lenOfPage = browser.execute_script("window.scrollTo(0, document.body.scrollHeight);var lenOfPage=document.body.scrollHeight;return lenOfPage;")
        print lenOfPage
        if lastCount==lenOfPage or lenOfPage == 5:
            match=True

innerHTML = browser.execute_script("return document.body.innerHTML")
tree = html.fromstring(innerHTML)
print tree.iterlinks()
for elem in tree.iterlinks():
    print elem[2]
