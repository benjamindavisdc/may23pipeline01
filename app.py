from flask import Flask, render_template
import boto3

app = Flask(__name__, static_url_path='/static')
app.static_folder = 'static'

@app.route('/')
@app.route('/index.html')
def index():
    data = get_data_from_database()
    return render_template('index.html', data=data)

@app.route('/pipeline1.html')
def pipeline1():
    data = get_data_from_database()
    return render_template('pipeline1.html', data=data)

@app.route('/pipeline2.html')
def pipeline2():
    data = get_data_from_database()
    return render_template('pipeline2.html', data=data)

@app.route('/pipeline3.html')
def pipeline3():
    data = get_data_from_database()
    return render_template('pipeline3.html', data=data)

def get_data_from_database():
    # Connect to DynamoDB and retrieve data
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table_name = 'x-ray_table'
    table = dynamodb.Table(table_name)
    response = table.scan()
    data = response['Items']
    return data

if __name__ == '__main__':
    app.run()
