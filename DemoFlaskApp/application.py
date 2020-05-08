from flask import Flask, request, jsonify
import fb

app = Flask("myapp")


@app.route("/")
def home():
    return "Demo app"


@app.route("/add")
def add_to_data():
    name = request.args.get("name")
    try:
        assert len(name) > 0
    except AssertionError:
        return "Please enter a name of length>0. \n /add?name=NAME"

    req = fb.insert(name)
    return jsonify(req)


if __name__ == "__main__":

    app.run("localhost", port=8080, debug=True)
