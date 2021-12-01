import os, sys
import flask

app = flask.Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def root():
    pass

if __name__ == "__main__":
    app.run()