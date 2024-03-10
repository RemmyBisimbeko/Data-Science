import tkinter as tk  # Import the Tkinter library for creating GUI
from tkinter import messagebox  # Import the messagebox module for displaying error messages
import sqlite3  # Import the SQLite3 library for database operations

# Function to evaluate the expression and display result
def calculate():
    expression = entry.get()  # Get the expression entered by the user
    try:
        result = eval(expression)  # Evaluate the expression using Python's eval() function
        result_label.config(text=f"Result: {result}")  # Update the result label with the calculated result
        save_expression(expression, result)  # Save the expression and result to the database
    except Exception as e:
        messagebox.showerror("Error", f"Invalid expression: {e}")  # Display an error message if expression is invalid

# Function to save expression and result to SQLite3 database
def save_expression(expression, result):
    conn = sqlite3.connect('calculator.db')  # Connect to the SQLite3 database
    c = conn.cursor()  # Create a cursor object to execute SQL commands
    c.execute("CREATE TABLE IF NOT EXISTS calculations (expression TEXT, result REAL)")  # Create a table if not exists
    c.execute("INSERT INTO calculations VALUES (?, ?)", (expression, result))  # Insert expression and result into the table
    conn.commit()  # Commit changes to the database
    conn.close()  # Close the database connection

# Function to display history of expressions and results
def show_history():
    history_window = tk.Toplevel(root)  # Create a new window for displaying history
    history_window.title("History")  # Set the title of the history window
    conn = sqlite3.connect('calculator.db')  # Connect to the SQLite3 database
    c = conn.cursor()  # Create a cursor object to execute SQL commands
    c.execute("SELECT * FROM calculations")  # Retrieve all rows from the calculations table
    rows = c.fetchall()  # Fetch all rows
    history_text = tk.Text(history_window)  # Create a text widget to display history
    for row in rows:
        history_text.insert(tk.END, f"Expression: {row[0]}, Result: {row[1]}\n")  # Insert expression and result into the text widget
    history_text.pack()  # Pack the text widget into the history window

# Function to add symbol to expression
def add_symbol(symbol):
    entry.insert(tk.END, symbol)  # Append the symbol to the end of the expression in the entry widget

# Function to clear screen entirely
def clear_all():
    entry.delete(0, tk.END)  # Delete all characters in the entry widget

# Function to clear one character at a time
def clear_one():
    entry.delete(len(entry.get()) - 1)  # Delete the last character in the entry widget

# Create main window
root = tk.Tk()  # Create a Tkinter root window
root.title("Calculator")  # Set the title of the main window

# Create entry widget for expression input
entry = tk.Entry(root, width=30)  # Create an entry widget for user input
entry.grid(row=0, column=0, columnspan=4)  # Grid layout for entry widget

# Create num pad buttons
num_pad_frame = tk.Frame(root)  # Create a frame for num pad buttons
num_pad_frame.grid(row=1, column=0, rowspan=4, columnspan=3)  # Grid layout for num pad buttons
for i in range(10):
    button = tk.Button(num_pad_frame, text=str(i), command=lambda i=i: add_symbol(str(i)), width=5)  # Create num pad button
    button.grid(row=i // 3, column=i % 3)  # Grid layout for num pad buttons

# Create math symbol buttons with colors and shadows
symbols = ['+', '-', '*', '/']
for i, symbol in enumerate(symbols):
    button = tk.Button(num_pad_frame, text=symbol, command=lambda symbol=symbol: add_symbol(symbol), width=5, bg="lightblue", relief="raised", bd=3)  # Create symbol button
    button.grid(row=i // 2, column=i % 2 + 3)  # Grid layout for symbol buttons

# Create clear buttons
clear_all_button = tk.Button(root, text="Clear All", command=clear_all, width=10, bg="red", fg="white", relief="raised", bd=3)  # Create clear all button
clear_all_button.grid(row=1, column=3)  # Grid layout for clear all button
clear_one_button = tk.Button(root, text="Clear One", command=clear_one, width=10, bg="orange", relief="raised", bd=3)  # Create clear one button
clear_one_button.grid(row=2, column=3)  # Grid layout for clear one button

# Create button to calculate expression
calculate_button = tk.Button(root, text="Calculate", command=calculate, width=10, bg="green", fg="white", relief="raised", bd=3)  # Create a button to trigger calculation
calculate_button.grid(row=3, column=3, columnspan=1)  # Grid layout for calculate button

# Create button to show history
history_button = tk.Button(root, text="History", command=show_history, width=10, bg="blue", fg="white", relief="raised", bd=3)  # Create a button to show history
history_button.grid(row=4, column=3)  # Grid layout for history button

# Run the main event loop
root.mainloop()  # Start the Tkinter event loop to display the GUI and handle user interactions
