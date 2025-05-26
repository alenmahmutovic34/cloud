from flask import Flask, request, jsonify
from flask_cors import CORS  # Dodaj ovaj import
from sql_connection import get_sql_connection
import mysql.connector
import json

import products_dao
import orders_dao
import uom_dao

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}},
     allow_header=["Content-Type", "Authorization"],
     methods=["GET", "POST", "OPTIONS"])  # Ovo omogućava CORS za sve rute

connection = get_sql_connection()

@app.after_request
def add_cors_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    return response

@app.route('/getUOM', methods=['GET', 'OPTIONS'])
def get_uom():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    response = uom_dao.get_uoms(connection)
    response = jsonify(response)
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/getProducts', methods=['GET', 'OPTIONS'])
def get_products():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    response = products_dao.get_all_products(connection)
    response = jsonify(response)
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/insertProduct', methods=['POST', 'OPTIONS'])
def insert_product():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    request_payload = json.loads(request.form['data'])
    product_id = products_dao.insert_new_product(connection, request_payload)
    response = jsonify({
        'product_id': product_id
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/getAllOrders', methods=['GET', 'OPTIONS'])
def get_all_orders():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'GET, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    response = orders_dao.get_all_orders(connection)
    response = jsonify(response)
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/insertOrder', methods=['POST', 'OPTIONS'])
def insert_order():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    request_payload = json.loads(request.form['data'])
    order_id = orders_dao.insert_order(connection, request_payload)
    response = jsonify({
        'order_id': order_id
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

@app.route('/deleteProduct', methods=['POST', 'OPTIONS'])
def delete_product():
    if request.method == 'OPTIONS':
        # Preflight request odgovor
        resp = jsonify({'status': 'ok'})
        resp.headers.add('Access-Control-Allow-Origin', '*')
        resp.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS')
        resp.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        return resp
    
    return_id = products_dao.delete_product(connection, request.form['product_id'])
    response = jsonify({
        'product_id': return_id
    })
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

if __name__ == "__main__":
    print("Starting Python Flask Server For Grocery Store Management System")
    app.run(host='0.0.0.0', port=5000, debug=True)
