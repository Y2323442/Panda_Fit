from flask import jsonify, request


def get_json_object():
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return None, (jsonify({"message": "Request body must be a JSON object"}), 400)

    return data, None
