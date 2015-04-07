from lxml import html
import requests, re, sys, codecs

### Constants ###

baseurl           = "http://www.beeradvocate.com"
style_link        = "/beer/style/"
profile_link      = "/beer/profile/"

output = codecs.open("test.txt", "w", "utf-8")

### Functions ###

def printo(string):
    output.write(string)

def printc(string):
    printo(string + ",")

def printq(string):
    printc("\"" + string + "\"")

### Code ###

# Login to beeradvocate
session = requests.Session()
session.headers.update({'referer':'http://www.beeradvocate.com/community'})
login_payload = {'login':'thesmoothdr@gmail.com', 'password':'drsmooth', '_xfToken':'', 'cookie_check':'0', 'register':'0', 'redirect':'/community'}
login_return = session.post('http://www.beeradvocate.com/community/login/login', data=login_payload)

page = session.get(baseurl + style_link)
# if 'Login' in page.text or 'Log out' not in page.text:
#     exit(0)
tree = html.fromstring(page.text)

# Find all beer categories #
beer_styles2 = tree.xpath('//a[contains(concat("",@href,""),"%s")]/text()'%(style_link))
style_links2 = tree.xpath('//a[contains(concat("",@href,""),"%s")]/@href'%(style_link))

beer_styles = beer_styles2[12:len(beer_styles2)-2]
style_links = style_links2[4:len(style_links2)-2]

# Find all beers in each category #
profile_matcher = re.compile('^/beer/profile/[0-9]+/[0-9]+/$')

link = style_links[0]
#for link in stylelinks:
style_page = session.get(baseurl + link)
style_tree = html.fromstring(style_page.text)
profile_links = style_tree.xpath('//a[contains(concat("",@href,""),"%s")]/@href'%(profile_link))
profile_links = filter(profile_matcher.match, profile_links)

for link in profile_links:
    profile_page = session.get(baseurl + link)
    profile_tree = html.fromstring(profile_page.text)
    beer_id = link.split("/")
    print(beer_id)
    beer_id = "%s_%s"%(beer_id[3], beer_id[4])
    printc(beer_id)
    beer_name = profile_tree.xpath(('//div[@class="%s"]'+'//h1%s')%("titleBar", "/text()"))[0]
    printq(beer_name)
    brewery_name = profile_tree.xpath(('//div[@class="%s"]'+'//span%s')%("titleBar", "/text()"))[0].split(" - ")[1]
    printq(brewery_name)
    printq(link)
    ba_score = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-score')]/text()")[0]
    printc(ba_score)
    ba_score_text = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-score_text')]/text()")[0]
    printq(ba_score_text)
    ba_ratings = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-ratings')]/text()")[0]
    printc(ba_ratings)
    ba_bro_score = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-bro_score')]/text()")[0]
    printc(ba_bro_score)
    ba_bro_text = profile_tree.xpath("//b[contains(concat('',@class,''),'ba-bro_text')]/text()")[0]
    printq(ba_bro_text)
    ba_reviews = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-reviews')]/text()")[0]
    printc(ba_reviews)
    ba_rating_avg = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-ravg')]/text()")[0]
    printc(ba_rating_avg)
    ba_pdev = profile_tree.xpath("//span[contains(concat('',@class,''),'ba-pdev')]/text()")[0][:-1]
    printq(ba_pdev)
    wants = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=W')]/text()")[0].split(" ")[1]
    printc(wants)
    gots = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=G')]/text()")[0].split(" ")[1]
    printc(gots)
    ft = profile_tree.xpath("//a[contains(concat('',@href,''),'?view=FT')]/text()")[0].split(" ")[1]
    printc(ft)
    location = profile_tree.xpath("//a[contains(concat('',@href,''),'/place/directory/')]/text()")[:-1]
    location = ",".join(location)
    printq(location)
    abv = profile_tree.xpath("//b[text()='Style | ABV']//following::a[1]/following-sibling::text()[1]")[0]
    try:
        abv = str(abv[-7:])
    except:
        abv = str(abv[-6:])
    abv = abv.strip()[:-1]
    printq(abv)
    availability = profile_tree.xpath("//b[text()='Availability:']/following::text()[1]")[0].strip()
    printo("\"" + availability + "\"")
    printo("\n")

output.close()
