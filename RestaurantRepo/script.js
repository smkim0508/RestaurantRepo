document.addEventListener('DOMContentLoaded', () => {
    const searchBtn = document.getElementById('search-btn');
    const cuisineInput = document.getElementById('cuisine');
    const locationInput = document.getElementById('location');
    const resultsContainer = document.getElementById('results');

    searchBtn.addEventListener('click', async () => {
        const cuisine = cuisineInput.value.trim();
        const location = locationInput.value.trim();

        if (!cuisine || !location) {
            showError('Please enter both cuisine and location');
            return;
        }

        try {
            // In a real application, you would make an API call here
            // For now, we'll simulate a response
            const mockResults = [
                {
                    name: 'Sample Restaurant 1',
                    address: '123 Main St, ' + location,
                    cuisine: cuisine,
                    rating: '4.5/5'
                },
                {
                    name: 'Sample Restaurant 2',
                    address: '456 Oak Ave, ' + location,
                    cuisine: cuisine,
                    rating: '4.2/5'
                }
            ];

            displayResults(mockResults);
        } catch (error) {
            showError('An error occurred while searching. Please try again.');
        }
    });

    function displayResults(results) {
        resultsContainer.innerHTML = '';
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<p class="no-results">No restaurants found. Try different search terms.</p>';
            return;
        }

        results.forEach(restaurant => {
            const restaurantCard = document.createElement('div');
            restaurantCard.className = 'restaurant-card';
            restaurantCard.innerHTML = `
                <h3>${restaurant.name}</h3>
                <p><strong>Address:</strong> ${restaurant.address}</p>
                <p><strong>Cuisine:</strong> ${restaurant.cuisine}</p>
                <p><strong>Rating:</strong> ${restaurant.rating}</p>
            `;
            resultsContainer.appendChild(restaurantCard);
        });
    }

    function showError(message) {
        resultsContainer.innerHTML = `<p class="error">${message}</p>`;
    }
}); 