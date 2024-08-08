import json
import sqlite3
from datetime import datetime

#Step 1: Create table Employees
def create_table(cursor):
    cursor.execute('''
        create table if not exists Employees(
        id interger primary key,
        name text,
        department text,
        salary interger,
        join_date date
        )
        ''')
    
#Step 2: Extract data from json file
def extract_data(filename):
    with open(filename, 'r') as f:
        data = json.load(f)
    return data

#Step 3: Transform the data by converting the "join_date" string to a date format and removing any unnecessary
def transform_data(data):
    transformed_data = []
    for entry in data:
        transformed_entry = {
            'id': entry['id'],
            'name': entry['name'],
            'department': entry['department'], 
            'salary': entry['salary'], 
            'join_date': datetime.strptime(entry['join_date'], '%Y-%m-%d').date()
        }
        transformed_data.append(transformed_entry)

    return transformed_data
        
#Step 4: Load the transformed data into the "employees" table in the Microsoft SQL
def load_data(cursor,data):
    for entry in data:
        cursor.execute(
            '''
            insert into Employees (id, name, department, salary, join_date)
            values (?, ?, ?, ?, ?)
            ''',
            (entry['id'], entry['name'], entry['department'], entry['salary'], entry['join_date'])
        )

#Step 5: ETL process
def ETL(json_file, db_file):

    connect = sqlite3.connect(db_file)
    cursor = connect.cursor()

    #create table
    create_table(cursor)

    #extract data
    data = extract_data(json_file)

    #transform data
    transformed_data = transform_data(data)

    #load data
    load_data(cursor, transformed_data)

    connect.commit()
    connect.close()


#Usage
json_file = "employees.json"
db_file = "employees.db"

ETL(json_file, db_file)