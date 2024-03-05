class Event:
    # Define the Event class to represent individual events
    def __init__(self, title, date, location, organizer):
        # Initialize the event attributes
        self.title = title
        self.date = date
        self.location = location
        self.organizer = organizer

    def __str__(self):
        # Convert the event details to a string for display
        return f"Title: {self.title}\nDate: {self.date}\nLocation: {self.location}\nOrganizer: {self.organizer}\n"


class EventManager:
    # Define the EventManager class to manage a collection of events
    def __init__(self):
        # Initialize an empty list to store events
        self.events = []

    def add_event(self, event):
        # Add a new event to the list
        self.events.append(event)

    def get_event_by_title(self, title):
        # Find and return an event by its title
        for event in self.events:
            if event.title == title:
                return event
        return None

    def display_events(self):
        # Display a list of all events
        if not self.events:
            print("No events found.")
        else:
            print("List of Events:")
            for idx, event in enumerate(self.events, start=1):
                print(f"{idx}. {event.title}")

    def display_event_details(self, title):
        # Display details of a specific event
        event = self.get_event_by_title(title)
        if event:
            print(event)
        else:
            print("Event not found.")


class App:
    # Define the main application class
    def __init__(self):
        # Initialize the application with an EventManager instance
        self.event_manager = EventManager()

    def display_menu(self):
        # Display the main menu options
        print("\n1. Add Event")
        print("2. View Events")
        print("3. View Event Details")
        print("4. Exit")

    def run(self):
        # Main program loop
        while True:
            self.display_menu()  # Display the main menu
            choice = input("Enter your choice: ")  # Prompt for user input
            if choice == '1':
                self.add_event()  # Option 1: Add Event
            elif choice == '2':
                self.view_events()  # Option 2: View Events
            elif choice == '3':
                self.view_event_details()  # Option 3: View Event Details
            elif choice == '4':
                print("Exiting the program...")  # Option 4: Exit
                break
            else:
                print("Invalid choice. Please try again.")  # Handle invalid input

    def add_event(self):
        # Prompt user for event details and add to the list
        print("\nEnter event details:")
        title = input("Title: ")
        date = input("Date: ")
        location = input("Location: ")
        organizer = input("Organizer: ")
        event = Event(title, date, location, organizer)
        self.event_manager.add_event(event)
        print("Event added successfully.")

    def view_events(self):
        # Display a list of all events
        print("\nList of Events:")
        self.event_manager.display_events()

    def view_event_details(self):
        # Prompt user for event title and display details
        title = input("\nEnter event title to view details: ")
        self.event_manager.display_event_details(title)


if __name__ == "__main__":
    # Create an instance of the App class and run the program
    app = App()
    app.run()
