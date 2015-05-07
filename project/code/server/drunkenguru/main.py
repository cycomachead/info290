from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def index():
    return render_template("index.html")

@app.route('/text-to-beer')
def text_to_beer():
    return render_template("text_to_beer.html")

@app.route('/beer_to_text')
def beer_to_text():
    return render_template("beer_to_text.html")

if __name__ == '__main__':
    app.run(debug=True)
