from lxml import html
import requests, re, sys, codecs, os

### Constants ###

baseurl           = "http://www.beeradvocate.com"
style_link        = "/beer/style/"
profile_link      = "/beer/profile/"

log_file = codecs.open("error_log.txt", "w", "utf-8")
beer_output = log_file

### Functions ###

def printo(string):
    beer_output.write(string)

def printc(string):
    printo(string + ",")

def printq(string):
    printc("\"" + string + "\"")

def printo_f(string, f):
    f.write(string)

def printc_f(string, f):
    printo_f(string + ",", f)

def printq_f(string, f):
    printc_f("\"" + string + "\"", f)

def log(string):
    printo_f(string + "\n", log_file)

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
rdev_matcher = re.compile('^.*rDev\s.*$')

#style_link = style_links[0]
#style = beer_styles[0]

#fill in the indices below to scrape a different range of beer styles
for k in range(len(style_links))[:]:
    style = beer_styles[k]
    style_link = style_links[k]
    print "style index: %d"% k
    print "style: %s"% style

    # Create style directory #
    style_joined = "_".join(style.replace("/", "").split(" "))
    style_dir = "./" + style_joined
    if not os.path.exists(style_dir):
        os.makedirs(style_dir)
    beer_output = codecs.open(style_dir + "/" + style_joined + "_beers.txt", "w", "utf-8")
    printo("beer_id,beer_name,brewery_name,link,style,ba_score,ba_score_text,ratings_count,bro_score,bro_score_text,reviews_count,rating_avg,pdev,wants,gots,ft,location,abv,availability\n")

    try:
        #for link in stylelinks:
        style_page = session.get(baseurl + style_link)
        style_tree = html.fromstring(style_page.text)
        profile_links = style_tree.xpath('//a[contains(concat("",@href,""),"%s")]/@href'%(profile_link))
        profile_links = filter(profile_matcher.match, profile_links)

        beer_index = 0
        for link in profile_links:
            # get beer profile page
            print "beer index: %d"% beer_index
            beer_index += 1
            profile_page = session.get(baseurl + link)
            profile_tree = html.fromstring(profile_page.text)

            try:
                # scrape features
                beer_id = link.split("/")
                print("/".join(beer_id[3:5]))
                beer_id = "%s_%s"%(beer_id[3], beer_id[4])
                printc(beer_id)
                beer_name = profile_tree.xpath(('//div[@class="%s"]'+'//h1%s')%("titleBar", "/text()"))[0]
                printq(beer_name)
                brewery_name = profile_tree.xpath(('//div[@class="%s"]'+'//span%s')%("titleBar", "/text()"))[0].split(" - ")[1]
                printq(brewery_name)
                printq(link)
                printq(style)
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
                printc(ba_pdev)
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
                printc(abv)
                availability = profile_tree.xpath("//b[text()='Availability:']/following::text()[1]")[0].strip()
                printo("\"" + availability + "\"")
                printo("\n")

                # Create reviews file
                reviews_output = codecs.open(style_dir + "/" + beer_id, "w", "utf-8")
                printo_f("user_score,rdev,look_score,smell_score,taste_score,feel_score,overall_score,review_text,username,timestamp\n", reviews_output)

                # iterate over all reviews pages
                num_reviews = int(ba_ratings.replace(",", ""))
                start = 1
                while start < num_reviews:
                    # get next reviews page
                    profile_page = session.get(baseurl+link+"?view=beer&sort=&start=%d"%(start))
                    no_username = "^<div\sid=\"rating_fullview_content_2\">\"You\srated\sthis\sbeer.\".{1,300}<div>.{1,300}</div></div>$"
                    profile_text = re.sub(no_username, "", profile_page.text)
                    profile_tree = html.fromstring(profile_text)

                    user_scores = profile_tree.xpath("//span[@class='BAscore_norm']/text()")
                    user_score_pdevs = profile_tree.xpath("//span[@class='BAscore_norm']/following::span[2]/text()")
                    user_senses_scores = profile_tree.xpath("//span[@class='BAscore_norm']/following::span[3]/text()")
                    review_texts = profile_tree.xpath("//div[@id='rating_fullview_content_2']/text()")#"//span[@class='BAscore_norm']/following::span[3]/following::text()[1]")
                    x = 0
                    while x < len(review_texts):
                        if rdev_matcher.match(review_texts[x]):
                            review_texts[x] = ""
                            x += 1
                        else:
                            review_texts.pop(x-1)
                    #review_texts = map(lambda x: "" if rdev_matcher.match(x) else x, review_texts)
                    usernames = profile_tree.xpath("//span[@class='muted']/a[@class='username']")
                    usernames = map(lambda x: x.text if x.text else "", usernames)
                    timestamps = profile_tree.xpath("//a[contains(concat('',@href,''),'?ba=')]/text()")[5:]
                    for i in range(len(user_scores)):
                        printc_f(user_scores[i], reviews_output)
                        pdev = user_score_pdevs[i]
                        if "%" not in pdev:
                            user_pdev = "0"
                            printc_f(user_pdev, reviews_output)
                            scores = pdev.split(" | ")
                            if len(scores) != 5:
                                for j in range(5):
                                    printc_f("", reviews_output)
                            else:
                                for score in scores:
                                    printc_f(score.strip().split(" ")[1], reviews_output)
                        else:
                            printc_f(user_score_pdevs[i].replace("+","")[:-1], reviews_output)
                            scores = user_senses_scores[i].split(" | ")
                            if len(scores) != 5:
                                for j in range(5):
                                    printc_f("", reviews_output)
                            else:
                                for score in scores:
                                    printc_f(score.strip().split(" ")[1], reviews_output)
                        #printq_f(user_senses_scores[i], reviews_output)
                        review_text = review_texts[i]
                        username = usernames[i]
                        if review_text == username:
                            review_text = ""
                        printq_f(review_text, reviews_output)
                        printq_f(username, reviews_output)
                        printo_f("\"" + timestamps[i] + "\"", reviews_output)
                        printo_f("\n", reviews_output)
                    start += 25

                reviews_output.close()
            except Exception as e:
                log("Exception: logging beer %s - %s"%(beer_id,e.message))
            except Error as e:
                log("Error: logging beer %s - %s"%(beer_id, e.message))
            except:
                log("IDK WTF happened, but beer %s screwed up"%s(beer_id))
    except Exception as e:
        log("Exception: logging style %s - %s"%(style_dir,e.message))
    except Error as e:
        log("Error: logging style %s - %s"%(style_dir,e.message))
    except:
        log("IDK WTF happened, but style %s screwed up"%(style_dir))

beer_output.close()
