from flask import Flask, render_template, request
app = Flask(__name__)

beers_file = open("all_beers.txt", "r")
beers_list = beers_file.readlines()

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/text-to-beer', methods=["POST", "GET"])
def text_to_beer():
    if request.method == "POST":
        return render_template("text_to_beer_results.html", search=request.form["beer-text"], results="Sierra Nevada Pale Ale")
    else:
        return render_template("text_to_beer_form.html")

@app.route('/beer_to_text', methods=["POST", "GET"])
def beer_to_text():
    if request.method == "POST":
        return render_template("beer_to_text_results.html",
                                search=request.form["beer-text"],
                                results="Hoppy, fruity, strong")
    else:
        return render_template("beer_to_text_form.html", beers=beers_list)

if __name__ == '__main__':
    app.run(debug=True)
