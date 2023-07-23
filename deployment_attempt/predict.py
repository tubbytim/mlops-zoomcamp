import pickle
from pathlib import Path

from flask import Flask, jsonify, request

base_path = Path(__file__).parent.resolve()
with open(base_path / "lin_reg.bin", "rb") as f_in:
    (dict_vect, model) = pickle.load(f_in)


def prepare_features(ride):
    features = {}
    features["PU_DO"] = "{}_{}".format(ride["PULocationID"], ride["DOLocationID"])
    features["trip_distance"] = ride["trip_distance"]
    return features


app = Flask("duration-prediction")


@app.route("/predict", methods=["POST"])
def predict():
    ride = request.get_json()

    features = prepare_features(ride)
    features = dict_vect.transform(features)
    preds = model.predict(features)[0]
    print(preds)
    result = {"duration": preds}

    return jsonify(result)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=9696)
