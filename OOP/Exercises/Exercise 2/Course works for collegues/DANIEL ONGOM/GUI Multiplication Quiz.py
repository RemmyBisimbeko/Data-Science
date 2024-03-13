
# GUI Implementation of the Mulitplication Quiz

import tkinter as tk
from tkinter import messagebox
import random

class MultiplicationQuiz:
    def __init__(self, master):
        self.master = master
        self.master.title("Multiplication Quiz")

        self.score = 0
        self.question_count = 0

        self.create_widgets()

    def create_widgets(self):
        self.label_title = tk.Label(self.master, text="Multiplication Quiz", font=("Helvetica", 16))
        self.label_title.pack(pady=10)

        self.label_question = tk.Label(self.master, text="")
        self.label_question.pack()

        self.entry_answer = tk.Entry(self.master)
        self.entry_answer.pack()

        self.button_submit = tk.Button(self.master, text="Submit", command=self.submit_answer)
        self.button_submit.pack(pady=5)

    def generate_question(self):
        first_number = random.randint(0, 9)
        second_number = random.randint(0, 9)
        self.correct_answer = first_number * second_number
        self.question_count += 1
        self.label_question.config(text=f"What is {first_number} * {second_number}?")

    def submit_answer(self):
        user_answer = self.entry_answer.get()
        if user_answer.isdigit():
            user_answer = int(user_answer)
            if user_answer == self.correct_answer:
                self.score += 1
                messagebox.showinfo("Correct", "Bravo! Correct answer")
            else:
                messagebox.showerror("Incorrect", f"Oooh no! Your answer is incorrect. The correct answer is: {self.correct_answer}.")
            self.entry_answer.delete(0, tk.END)
            if self.question_count < 6:
                self.generate_question()
            else:
                messagebox.showinfo("Quiz Completed", f"Quiz completed! You have scored {self.score} correct out of 6 questions.")
                self.master.destroy()
        else:
            messagebox.showerror("Invalid Input", "Kindly enter a valid number.")

def main():
    root = tk.Tk()
    app = MultiplicationQuiz(root)
    app.generate_question()
    root.mainloop()

if __name__ == "__main__":
    main()