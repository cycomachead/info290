from lxml import html
import requests, re, sys

### Constants ###

baseurl           = "http://www.beeradvocate.com"
style_link        = "/beer/style/"
profile_link      = "/beer/profile/"

xpath_a_tag       = '//a[contains(concat("",@href,""),"%s")]%s'
xpath_div_tag     = '//div[@class="%s"]'
xpath_h1_tag      = '//h1%s'
xpath_span_tag    = '//span%s'
xpath_select_text = "/text()"
xpath_select_href = "/@href"

profile_regex     = '^/beer/profile/[0-9]+/[0-9]+/$'

### Functions ###

def printn(string):
    sys.stdout.write(string + ",")

def printq(string):
    printn("\"" + string + "\"")

### Find all beer categories ###
page = requests.get(baseurl + style_link)
tree = html.fromstring(page.text)

beer_styles = tree.xpath(xpath_a_tag%(style_link, xpath_select_text))
style_links = tree.xpath(xpath_a_tag%(style_link, xpath_select_href))

beer_styles = beer_styles[6:len(beer_styles)-2]
style_links = style_links[2:len(style_links)-2]

### Find all beers in each category ###
profile_matcher = re.compile(profile_regex)

link = style_links[0]
#for link in stylelinks:
style_page = requests.get(baseurl + link)
style_tree = html.fromstring(style_page.text)
profile_links = style_tree.xpath(xpath_a_tag%(profile_link, xpath_select_href))
profile_links = filter(profile_matcher.match, profile_links)

for link in profile_links:
    profile_page = requests.get(baseurl + link)
    profile_tree = html.fromstring(profile_page.text)
    beer_name = profile_tree.xpath((xpath_div_tag+xpath_h1_tag)%("titleBar", xpath_select_text))[0]
    printq(beer_name)
    brewery_name = profile_tree.xpath((xpath_div_tag+xpath_span_tag)%("titleBar", xpath_select_text))[0].split(" - ")[1]
    printq(brewery_name)
    printq(link)
    ba_score = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-score')]/text()")[0]
    printn(ba_score)
    ba_score_text = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-score_text')]/text()")[0]
    printq(ba_score_text)
    ba_ratings = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-ratings')]/text()")[0]
    printn(ba_ratings)
    ba_bro_score = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-bro_score')]/text()")[0]
    printn(ba_bro_score)
    ba_bro_text = profile_tree.xpath("//b[contains(concat('',@class,''),'ba-bro_text')]/text()")[0]
    printq(ba_bro_text)
    ba_reviews = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-reviews')]/text()")[0]
    printn(ba_reviews)
    ba_rating_avg = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-ravg')]/text()")[0]
    printn(ba_rating_avg)
    ba_pdev = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-pdev')]/text()")[0]
    printq(ba_pdev)
    wants = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=W')]/text()")[0].split(" ")[1]
    printn(wants)
    gots = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=G')]/text()")[0].split(" ")[1]
    printn(gots)
    ft = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=FT')]/text()")[0].split(" ")[1]
    printn(ft)
    location = profile_tree.xpath("//a[contains(concat('',@href,''),'/place/directory/')]/text()")[:-1]
    location = ",".join(location)
    printq(location)
    abv = profile_tree.xpath("//b[text()='Style | ABV']//following::a[1]/following-sibling::text()[1]")[0]
    try:
        abv = str(abv[-7:])
    except:
        abv = str(abv[-6:])
    printq(abv)
    availability = profile_tree.xpath("//b[text()='Availability:']/following::text()[1]")[0].strip()
    print("\"" + availability + "\"")
