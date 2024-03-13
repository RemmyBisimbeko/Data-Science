## Remmy Bisimbeko - B26099 - J24M19/011
# My GitHub - https://github.com/RemmyBisimbeko/Data-Science

import tkinter as tk
from tkinter import messagebox

class Event:
    def __init__(self, title, date, location, organizer):
        self.title = title
        self.date = date
        self.location = location
        self.organizer = organizer

    def __str__(self):
        return f"Title: {self.title}\nDate: {self.date}\nLocation: {self.location}\nOrganizer: {self.organizer}\n"

class EventManager:
    def __init__(self):
        self.events = []

    def add_event(self, event):
        self.events.append(event)

    def get_event_by_title(self, title):
        for event in self.events:
            if event.title == title:
                return event
        return None

    def display_events(self):
        if not self.events:
            return "No events found."
        else:
            event_list = "List of Events:\n"
            for idx, event in enumerate(self.events, start=1):
                event_list += f"{idx}. {event.title}\n"
            return event_list

    def display_event_details(self, title):
        event = self.get_event_by_title(title)
        if event:
            return str(event)
        else:
            return "Event not found."

class App:
    def __init__(self, master):
        self.master = master
        self.master.title("Event Manager")

        self.event_manager = EventManager()

        self.create_widgets()

    def create_widgets(self):
        # Create main labels and buttons
        self.label = tk.Label(self.master, text="Event Manager", font=("Helvetica", 16))
        self.label.grid(row=0, column=0, columnspan=2, pady=10)

        self.add_event_button = tk.Button(self.master, text="Add Event", command=self.add_event)
        self.add_event_button.grid(row=1, column=0, pady=5)

        self.view_events_button = tk.Button(self.master, text="View Events", command=self.view_events)
        self.view_events_button.grid(row=1, column=1, pady=5)

        self.view_event_details_button = tk.Button(self.master, text="View Event Details", command=self.view_event_details)
        self.view_event_details_button.grid(row=2, column=0, columnspan=2, pady=5)

        self.exit_button = tk.Button(self.master, text="Exit", command=self.master.quit)
        self.exit_button.grid(row=3, column=0, columnspan=2, pady=5)

    def add_event(self):
        # Create a new window to input event details
        top = tk.Toplevel(self.master)
        top.title("Add Event")

        # Labels and entry fields for event details
        label_title = tk.Label(top, text="Title:")
        label_title.grid(row=0, column=0)
        entry_title = tk.Entry(top)
        entry_title.grid(row=0, column=1)

        label_date = tk.Label(top, text="Date:")
        label_date.grid(row=1, column=0)
        entry_date = tk.Entry(top)
        entry_date.grid(row=1, column=1)

        label_location = tk.Label(top, text="Location:")
        label_location.grid(row=2, column=0)
        entry_location = tk.Entry(top)
        entry_location.grid(row=2, column=1)

        label_organizer = tk.Label(top, text="Organizer:")
        label_organizer.grid(row=3, column=0)
        entry_organizer = tk.Entry(top)
        entry_organizer.grid(row=3, column=1)

        # Save button to add event
        def save_event():
            title = entry_title.get()
            date = entry_date.get()
            location = entry_location.get()
            organizer = entry_organizer.get()

            event = Event(title, date, location, organizer)
            self.event_manager.add_event(event)
            messagebox.showinfo("Success", "Event added successfully.")
            top.destroy()

        button_save = tk.Button(top, text="Save", command=save_event)
        button_save.grid(row=4, column=0, columnspan=2)

    def view_events(self):
        # Create a new window to display events
        top = tk.Toplevel(self.master)
        top.title("View Events")

        event_list = self.event_manager.display_events()

        label_events = tk.Label(top, text=event_list)
        label_events.pack()

    def view_event_details(self):
        # Create a new window to display event details
        top = tk.Toplevel(self.master)
        top.title("View Event Details")

        # Entry field to input event title
        label_title = tk.Label(top, text="Enter event title:")
        label_title.grid(row=0, column=0)
        entry_title = tk.Entry(top)
        entry_title.grid(row=0, column=1)

        # Button to show event details
        def show_details():
            title = entry_title.get()
            event_details = self.event_manager.display_event_details(title)

            label_details = tk.Label(top, text=event_details)
            label_details.grid(row=1, column=0, columnspan=2)

        button_show = tk.Button(top, text="Show Details", command=show_details)
        button_show.grid(row=2, column=0, columnspan=2)

if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()
