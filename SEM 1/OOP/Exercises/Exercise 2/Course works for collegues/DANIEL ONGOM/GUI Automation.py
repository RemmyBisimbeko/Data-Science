# GUI Implementation

import tkinter as tk
from tkinter import messagebox 
import requests

class MovieRecommendationApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Movie Recommendation")

        self.api_key = "8c4fa6fce83795c006b48f4679e735fd"  # TMDb API key
        self.genres = [53, 80, 27]  # Sample genres for recommendations

        self.create_widgets()

    def create_widgets(self):
        self.label_title = tk.Label(self.master, text="Movie Recommendation", font=("Helvetica", 16))
        self.label_title.grid(row=0, column=0, columnspan=2, pady=10)

        self.button_recommend = tk.Button(self.master, text="Get Recommendations", command=self.get_recommendations)
        self.button_recommend.grid(row=1, column=0, columnspan=2, pady=5)

    def get_recommendations(self):
        recommendations = self.get_movie_recommendations()

        if not recommendations:
            messagebox.showinfo("No Recommendations", "No recommendations found.")
            return

        messagebox.showinfo("Recommendations", self.format_recommendations(recommendations))

    def get_movie_recommendations(self, min_rating=7.5, num_recommendations=6):
        url = "https://api.themoviedb.org/3/discover/movie"
        params = {
            "api_key": self.api_key,
            "sort_by": "popularity.desc",
            "with_genres": ",".join(map(str, self.genres)),
            "vote_average.gte": min_rating,
            "page": 1
        }

        try:
            response = requests.get(url, params=params)
            data = response.json()

            recommendations = []
            if "results" in data:
                for movie in data["results"]:
                    recommendations.append({
                        "title": movie["title"],
                        "release_date": movie["release_date"],
                        "overview": movie["overview"],
                        "vote_average": movie["vote_average"]
                    })

            return recommendations[:num_recommendations]
        except requests.exceptions.RequestException as e:
            messagebox.showerror("Error", f"An error occurred: {e}")
            return []

    def format_recommendations(self, recommendations):
        formatted_recommendations = "Here are your movie recommendations:\n\n"
        for i, movie in enumerate(recommendations, 1):
            formatted_recommendations += f"{i}. {movie['title']} ({movie['release_date']}), Rating: {movie['vote_average']}\n"
            formatted_recommendations += f"Overview: {movie['overview']}\n\n"
        return formatted_recommendations

def main():
    root = tk.Tk()
    app = MovieRecommendationApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
