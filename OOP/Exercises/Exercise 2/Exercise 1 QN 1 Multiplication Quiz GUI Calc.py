## Remmy Bisimbeko - B26099 - J24M19/011
# My GitHub - https://github.com/RemmyBisimbeko/Data-Science


import tkinter as tk  # Import tkinter library for GUI
from tkinter import messagebox  # Import messagebox for displaying messages
import sqlite3  # Import sqlite3 for database operations

# Function to evaluate the expression and display result
def calculate():
    expression = entry.get()  # Get the expression from the entry widget
    try:
        result = eval(expression)  # Evaluate the expression
        entry.delete(0, tk.END)  # Clear the entry widget
        entry.insert(tk.END, result)  # Insert the result into the entry widget
        save_expression(expression, result)  # Save the expression and result to database
    except Exception as e:
        messagebox.showerror("Error", f"Invalid expression: {e}")  # Show error message if expression is invalid

# Function to save expression and result to SQLite3 database
def save_expression(expression, result):
    conn = sqlite3.connect('calculator.db')  # Connect to SQLite database
    c = conn.cursor()
    c.execute("CREATE TABLE IF NOT EXISTS calculations (expression TEXT, result REAL)")  # Create table if not exists
    c.execute("INSERT INTO calculations VALUES (?, ?)", (expression, result))  # Insert expression and result into table
    conn.commit()  # Commit changes
    conn.close()  # Close connection to database

# Function to display history of expressions and results
def show_history():
    history_window = tk.Toplevel(root)  # Create a new window for history
    history_window.title("History")  # Set window title
    conn = sqlite3.connect('calculator.db')  # Connect to SQLite database
    c = conn.cursor()
    c.execute("SELECT * FROM calculations")  # Select all rows from calculations table
    rows = c.fetchall()  # Fetch all rows
    history_text = tk.Text(history_window)  # Create text widget for displaying history
    for row in rows:
        history_text.insert(tk.END, f"Expression: {row[0]}, Result: {row[1]}\n")  # Insert each row into text widget
    history_text.pack()  # Pack the text widget into the window

# Function to add symbol to expression
def add_symbol(symbol):
    entry.insert(tk.END, symbol)  # Insert symbol at the end of the expression

# Function to clear screen entirely
def clear_all():
    entry.delete(0, tk.END)  # Clear the entry widget

# Function to clear one character at a time
def clear_one():
    entry.delete(len(entry.get()) - 1)  # Delete the last character from the entry widget

root = tk.Tk()  # Create main window
root.title("Calculator")  # Set window title

entry = tk.Entry(root, width=30, font=("TkDefaultFont", 12))  # Create entry widget
entry.grid(row=0, column=0, columnspan=4, sticky="ew")  # Set grid for entry widget

num_pad_frame = tk.Frame(root)  # Create frame for number pad
num_pad_frame.grid(row=1, column=0, rowspan=4, columnspan=3)  # Set grid for number pad frame
for i in range(10):  # Create buttons for digits
    button = tk.Button(num_pad_frame, text=str(i), command=lambda i=i: add_symbol(str(i)), width=5)
    button.grid(row=i // 3, column=i % 3)

symbols = ['+', '-', '*', '/']  # Define arithmetic symbols
for i, symbol in enumerate(symbols):  # Create buttons for symbols
    button = tk.Button(num_pad_frame, text=symbol, command=lambda symbol=symbol: add_symbol(symbol), width=5)
    button.grid(row=i // 2, column=i % 2 + 3)

calculate_button = tk.Button(root, text="Calculate", command=calculate, width=10, bg="green")  # Create calculate button
calculate_button.grid(row=1, column=3, columnspan=1)  # Set grid for calculate button

clear_one_button = tk.Button(root, text="Clear One", command=clear_one, width=10, bg="orange")  # Create clear one button
clear_one_button.grid(row=2, column=3)  # Set grid for clear one button

clear_all_button = tk.Button(root, text="Clear All", command=clear_all, width=10, bg="red")  # Create clear all button
clear_all_button.grid(row=3, column=3)  # Set grid for clear all button

history_button = tk.Button(root, text="History", command=show_history, width=10, bg="blue")  # Create history button
history_button.grid(row=4, column=3)  # Set grid for history button

root.mainloop()  # Start the main event loop
