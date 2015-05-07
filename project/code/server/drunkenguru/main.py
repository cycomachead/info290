from flask import Flask, render_template, request
import codecs, unicodedata
app = Flask(__name__)

beers_file = open("beer_ids_names.txt", "r")#, encoding="utf-8")
beers_list = beers_file.read().replace("\"", "")
beers_list = beers_list.splitlines()
beers_list = [i.split(",") for i in beers_list]
beers_list = [[i[0], str(", ".join(i[1:])).decode("utf8")] for i in beers_list]

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
        beer_id = request.form['beer-select']
        beer_name = [beer for beer in beers_list if beer[0] == beer_id][0][1]
        result_str = "Hoppy, fruity, strong"
        return render_template("beer_to_text_results.html",
                               search=beer_name,
                               results=result_str)
    else:
        return render_template("beer_to_text_form.html", beers=beers_list)

if __name__ == '__main__':
    app.run(debug=True)
