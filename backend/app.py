from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Allow requests from Express frontend

@app.route('/process', methods=['POST'])
def process_form():
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    age = data.get('age')
    gender = data.get('gender')
    message = data.get('message')

    print(f"Received: {username}, {email}, {age}, {gender}, {message}")

    return jsonify({
        'message': f"Thanks {username}, we've received your info!",
        'data': data
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)