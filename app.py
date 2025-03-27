from flask import Flask, render_template_string, jsonify
import os

# Initialize Flask app
app = Flask(__name__)

# Define the HTML template with a button
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World App</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            text-align: center;
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        button {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        button:hover {
            background-color: #2980b9;
        }
        #result {
            margin-top: 30px;
            font-size: 24px;
            font-weight: bold;
            color: #27ae60;
            min-height: 36px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to My Simple App</h1>
        <p>Click the button to see the message:</p>
        <button id="hello-button">Click Me</button>
        <div id="result"></div>
    </div>

    <script>
        document.getElementById('hello-button').addEventListener('click', async () => {
            try {
                const response = await fetch('/hello');
                const data = await response.json();
                document.getElementById('result').textContent = data.message;
            } catch (error) {
                document.getElementById('result').textContent = 'Error: Could not fetch message';
            }
        });
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/hello')
def hello():
    return jsonify({'message': 'Hello World!'})

if __name__ == '__main__':
    # Get port from environment variable or default to 8000
    port = int(os.environ.get('PORT', 8000))
    # Run the app, making it accessible from any network interface
    app.run(host='0.0.0.0', port=port)