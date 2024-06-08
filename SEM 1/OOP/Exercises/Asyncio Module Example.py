# Snippet Example:

import asyncio # Importing the asyncio module

# Define a coroutine function
async def greet():
    print("Hello")
    await asyncio.sleep(1)
    print("World")

def main():
    # Run the coroutine function in an event loop
    asyncio.run(greet())

if __name__ == "__main__":
    main()