from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
import sys
from pathlib import Path
import pandas as pd
import traceback
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Get the food preference path from environment variables
FOOD_PREFERENCE_PATH = os.getenv('FOOD_PREFERENCE_PATH')
if not FOOD_PREFERENCE_PATH:
    raise ValueError("FOOD_PREFERENCE_PATH not found in environment variables")

# Add the Food_Preference_Indexer directory to Python path
sys.path.append(FOOD_PREFERENCE_PATH)

# Import the recommendation script
from suggest_modular import recommend_restaurants_for_user

# Load the data files
def load_data():
    try:
        data_path = os.path.join(FOOD_PREFERENCE_PATH, "data")
        print(f"Loading data from: {data_path}")
        
        all_user_ratings_df = pd.read_pickle(os.path.join(data_path, "user_ratings_gt_300.pkl"))
        reviews_df = pd.read_pickle(os.path.join(data_path, "reviews.pkl"))
        business_df = pd.read_pickle(os.path.join(data_path, "business.pkl"))
        
        print("Data loaded successfully")
        print(f"User ratings shape: {all_user_ratings_df.shape}")
        print(f"Reviews shape: {reviews_df.shape}")
        print(f"Business shape: {business_df.shape}")
        
        return all_user_ratings_df, reviews_df, business_df
    except Exception as e:
        print(f"Error loading data: {str(e)}")
        print(traceback.format_exc())
        raise

# Load data once when server starts
try:
    all_user_ratings_df, reviews_df, business_df = load_data()
except Exception as e:
    print(f"Failed to initialize server: {str(e)}")
    raise

@app.route('/api/recommend', methods=['GET'])
def recommend():
    try:
        # Get parameters from request
        user_id = request.args.get('user_id', '')
        state = request.args.get('state', '')
        city = request.args.get('city', '')
        cuisine = request.args.get('cuisine', '')
        top_n = int(request.args.get('top_n', '5'))
        
        print(f"Received request with parameters:")
        print(f"user_id: {user_id}")
        print(f"state: {state}")
        print(f"city: {city}")
        print(f"cuisine: {cuisine}")
        print(f"top_n: {top_n}")
        
        # Call the recommendation function
        recommendations_df, explanation, score = recommend_restaurants_for_user(
            target_user_id=user_id,
            all_user_ratings_df=all_user_ratings_df,
            reviews_df=reviews_df,
            business_df=business_df,
            state=state,
            city=city,
            cuisine=cuisine,
            top_n=top_n
        )
        
        print(f"Recommendation successful. Found {len(recommendations_df)} restaurants")
        
        # Convert recommendations to list of dictionaries
        formatted_restaurants = []
        for _, row in recommendations_df.iterrows():
            # Get additional details from business_df
            business_details = business_df[business_df['business_id'] == row['business_id']].iloc[0]
            
            formatted_restaurant = {
                "business_id": row['business_id'],
                "name": row['name'],
                "state": state,
                "city": city,
                "categories": business_details['categories'],
                "stars": float(row['stars']),
                "latitude": float(business_details['latitude']),
                "longitude": float(business_details['longitude']),
                "explanation": explanation,
                "score": float(score)
            }
            formatted_restaurants.append(formatted_restaurant)
        
        return jsonify({
            "restaurants": formatted_restaurants,
            "explanation": explanation,
            "score": score
        })
    except Exception as e:
        print(f"Error in recommendation: {str(e)}")
        print(traceback.format_exc())
        return jsonify({"error": str(e), "traceback": traceback.format_exc()}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5001) 