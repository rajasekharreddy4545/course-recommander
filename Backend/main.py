from flask import Flask, request, jsonify
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.neighbors import NearestNeighbors
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Sample course data (replace with your dataset)
course_data = pd.read_csv('Dataset1.csv')
# Create a DataFrame from course data
courses_df = pd.DataFrame(course_data)

# Vectorize the course descriptions
tfidf = TfidfVectorizer(stop_words='english')
course_vectors = tfidf.fit_transform(courses_df['Course Description'])  
# print(course_vectors)

# Build the k-Nearest Neighbors model
knn_model = NearestNeighbors(n_neighbors=100, algorithm='brute', metric='cosine')
knn_model.fit(course_vectors)

@app.route('/recommend', methods=['POST'])
def recommend_courses():
    user_input = request.json.get('input')
    if request.method == 'POST':
        if user_input:
            # Transform user input into TF-IDF vector
            user_tfidf = tfidf.transform([user_input])

            # Find k-nearest neighbors for user input
            _, indices = knn_model.kneighbors(user_tfidf)

            # Retrieve recommended courses based on nearest neighbors
            recommended_courses = [{'title': courses_df.iloc[idx]['Course Name'],
                                    'description': courses_df.iloc[idx]['Course Description'],
                                    'difficulty': courses_df.iloc[idx]['Difficulty Level'],
                                    'rating': courses_df.iloc[idx]['Course Rating'],
                                    'link': courses_df.iloc[idx]['Course URL']}
                                    for idx in indices[0]]

            return jsonify({'courses': recommended_courses})
        else:
            return jsonify({'error': 'Invalid input'}), 400
    else:
        return jsonify({'error': 'Method Not Allowed'}), 405

if __name__ == '__main__':  
    app.run(host='0.0.0.0', port=5000, debug=True)
