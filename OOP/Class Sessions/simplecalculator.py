# tkinter
# customtkinter ...web, django
# drag and drop


# Exercise is about GUI of the first excercise
# Keep answers in memory eg a database for answers or the whole expression



import os

import tkinter as tk
from tkinter import *
import tkinter.messagebox
import sqlite3
import sqlalchemy



# Even if the teacher requests for one automation, do more than one

root = tk.Tk()

root.title("Simple Calculator")

# set the window size
x = root.winfo_screenmmwidth()//4
y = root.winfo_screenmmheight()*0.1

root.geometry("800x600"+str(x)+"+"+str(y))

def btn1_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "1")

def btn2_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "2")

def btn3_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "3")


def btn4_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "4")

def btn5_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "5")

def btn6_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "6")

def btn7_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "7")

def btn8_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "8")

def btn9_fn():
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "9")

def btnequal_fn():
    try:
        answer = txtbox.get()   
        answer = eval(answer) 
        txtbox.delete(0, "end")  
        txtbox.insert(0, str(answer))    
    except:   
        tkinter.messagebox.showerror("Pleae checkk on your operands and operators")               
    if txtbox.get() == "0":
        txtbox.delete(0, "end") 
    position = len(txtbox.get())
    txtbox.insert(position, "9")


# def key_event();

def btnplus_fn():
    position = len(txtbox.get())
    txtbox.insert(position, "+")

def btnminus_fn():
    position = len(txtbox.get())
    txtbox.insert(position, "-")

def btndivide_fn():
    position = len(txtbox.get())
    txtbox.insert(position, "/")


txtbox = Entry(root, fg="black", bg="white", justify=RIGHT)
txtbox.bind("<Return>", btnequal_fn)
txtbox.pack(expand=True, fill=BOTH)

bg_color = "#2222222"

# create four rows

row1btn = tk.Frame(root, bg="#0000000")
row1btn.pack(expand=True, fill=tk.BOTH)

btn1 = tk.Button(row1btn, text='1', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btn1.pack(side=LEFT, expand=True ,fill=BOTH)

btn2 = tk.Button(row1btn, text='2', bd=0, font=('Arial', 35), command=btn2_fn, fg="white", bg=bg_color)
btn2.pack(side=LEFT, expand=True ,fill=BOTH)

btn3 = tk.Button(row1btn, text='3', bd=0, font=('Arial', 35), command=btn3_fn, fg="white", bg=bg_color)
btn3.pack(side=LEFT, expand=True ,fill=BOTH)

btnplus = tk.Button(row1btn, text='+', bd=0, font=('Arial', 35), command=btnplus_fn, fg="white", bg=bg_color)
btnplus.pack(side=LEFT, expand=True ,fill=BOTH)

# row 2 button frame
row2btn = tk.Frame(root, bg="#0000000")
row2btn.pack(expand=True, fill=tk.BOTH)

btn4 = tk.Button(row2btn, text='4', bd=0, font=('Arial', 35), command=btn4_fn, fg="white", bg=bg_color)
btn4.pack(side=LEFT, expand=True ,fill=BOTH)

btn5 = tk.Button(row2btn, text='5', bd=0, font=('Arial', 35), command=btn5_fn, fg="white", bg=bg_color)
btn5.pack(side=LEFT, expand=True ,fill=BOTH)

btn6 = tk.Button(row2btn, text='6', bd=0, font=('Arial', 35), command=btn6_fn, fg="white", bg=bg_color)
btn6.pack(side=LEFT, expand=True ,fill=BOTH)

btnminus = tk.Button(row2btn, text='-', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btnminus.pack(side=LEFT, expand=True ,fill=BOTH)

# row 3 button frame
row3btn = tk.Frame(root, bg="#0000000")
row3btn.pack(expand=True, fill=tk.BOTH)

btn7 = tk.Button(row3btn, text='7', bd=0, font=('Arial', 35), command=btn7_fn, fg="white", bg=bg_color)
btn7.pack(side=LEFT, expand=True ,fill=BOTH)

btn8 = tk.Button(row3btn, text='8', bd=0, font=('Arial', 35), command=btn8_fn, fg="white", bg=bg_color)
btn8.pack(side=LEFT, expand=True ,fill=BOTH)

btn9 = tk.Button(row3btn, text='9', bd=0, font=('Arial', 35), command=btn9_fn, fg="white", bg=bg_color)
btn9.pack(side=LEFT, expand=True ,fill=BOTH)

btndivide = tk.Button(row3btn, text='/', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btndivide.pack(side=LEFT, expand=True ,fill=BOTH)

# row 4 button frame
row4btn = tk.Frame(root, bg="#0000000")
row4btn.pack(expand=True, fill=tk.BOTH)

btndel = tk.Button(row4btn, text='DEL', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btndel.pack(side=LEFT, expand=True ,fill=BOTH)

btn0 = tk.Button(row4btn, text='0', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btn0.pack(side=LEFT, expand=True ,fill=BOTH)

btnequal = tk.Button(row4btn, text='=', bd=0, font=('Arial', 35), command=btnequal_fn, fg="white", bg=bg_color)
btnequal.pack(side=LEFT, expand=True ,fill=BOTH)

btnmod = tk.Button(row4btn, text='%', bd=0, font=('Arial', 35), command=btn1_fn, fg="white", bg=bg_color)
btnmod.pack(side=LEFT, expand=True ,fill=BOTH)

root.mainloop()