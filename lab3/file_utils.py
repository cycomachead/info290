import socket
HOST = socket.gethostname().replace('.local', '')

# Relative File paths based on each computer we have.
yelp_data = {
    'Yosemite-Pro': '../yelp.txt',
    'Yosemite-Retina': '../yelp.txt',
    'Peters Computer':'yelp_reviewers.txt'
}

review = {
    'Yosemite-Pro': '../yelp_reviewers.txt',
    'Yosemite-Retina': '../yelp_reviewers.txt',
    'Peters Computer': 'yelp_reviewers.txt'
}

def yelpFile():
    return yelp_data[HOST]

def reviewers():
    return review[HOST]
