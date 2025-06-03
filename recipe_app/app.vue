<template>
  <div class="main-container">
    <!-- Search Bar -->
    <header class="search-header">
      <input
        v-model="searchQuery"
        @input="onSearch"
        type="text"
        class="search-bar"
        placeholder="Search recipes by name, ingredient, or category…"
        aria-label="Search recipes"
      />
    </header>
    <!-- Featured Recipes -->
    <main class="recipe-list">
      <h2 class="section-title">Featured Recipes</h2>
      <div class="recipes-grid">
        <div
          v-for="recipe in filteredRecipes"
          :key="recipe.id"
          class="recipe-card"
          @click="viewRecipe(recipe)"
          tabindex="0"
          @keyup.enter="viewRecipe(recipe)"
          role="button"
          aria-label="View recipe"
        >
          <img :src="recipe.image" :alt="recipe.title" class="recipe-card-img"/>
          <div class="recipe-card-content">
            <h3 class="recipe-title">{{ recipe.title }}</h3>
            <p class="recipe-metadata">
              {{ recipe.category }} &middot; {{ recipe.time }} mins
            </p>
          </div>
          <button
            class="fav-button"
            :class="{ active: recipe.isFavorite }"
            @click.stop="toggleFavorite(recipe)"
            :aria-label="recipe.isFavorite ? 'Unfavorite recipe' : 'Favorite recipe'"
          >
            <svg height="24" viewBox="0 0 24 24" width="24">
              <path
                :fill="recipe.isFavorite ? colors.primary : '#ddd'"
                d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.41 4.42 3 7.5 3a5.48 5.48 0 014.5 2.09A5.48 5.48 0 0116.5 3C19.58 3 22 5.41 22 8.5c0 3.78-3.4 6.86-8.55 11.54z"
              />
            </svg>
          </button>
        </div>
      </div>
    </main>
    <!-- Bottom Navigation Bar -->
    <nav class="bottom-nav">
      <button
        class="nav-btn"
        :class="{ active: navTab === 'home' }"
        @click="navTab = 'home'"
        aria-label="Home"
      >
        <svg width="24" height="24" viewBox="0 0 24 24">
          <path :fill="navTab === 'home' ? colors.primary : '#888'"
                d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
        </svg>
        <span>Home</span>
      </button>
      <button
        class="nav-btn"
        :class="{ active: navTab === 'favorites' }"
        @click="showFavorites"
        aria-label="Favorites"
      >
        <svg width="24" height="24" viewBox="0 0 24 24">
          <path :fill="navTab === 'favorites' ? colors.primary : '#888'"
                d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.41 4.42 3 7.5 3a5.48 5.48 0 014.5 2.09A5.48 5.48 0 0116.5 3C19.58 3 22 5.41 22 8.5c0 3.78-3.4 6.86-8.55 11.54z"/>
        </svg>
        <span>Favorites</span>
      </button>
      <button
        class="nav-btn"
        :class="{ active: navTab === 'add' }"
        @click="addRecipe"
        aria-label="Add Recipe"
      >
        <svg width="24" height="24" viewBox="0 0 24 24">
          <circle cx="12" cy="12" r="10" :fill="navTab === 'add' ? colors.primary : '#888'" opacity="0.15" />
          <path
            :stroke="navTab === 'add' ? colors.primary : '#888'" stroke-width="2" stroke-linecap="round"
            d="M12 8v8M8 12h8"
            fill="none"
          />
        </svg>
        <span>Add</span>
      </button>
    </nav>
    <div class="recipe-modal" v-if="selectedRecipe">
      <!-- Recipe Detail Modal -->
      <div class="modal-content">
        <button class="close-modal" @click="selectedRecipe = null" aria-label="Close details">×</button>
        <img :src="selectedRecipe.image" :alt="selectedRecipe.title" class="modal-img"/>
        <h2>{{ selectedRecipe.title }}</h2>
        <div class="modal-metadata">
          <span>{{ selectedRecipe.category }}</span> &middot; <span>{{ selectedRecipe.time }} mins</span>
        </div>
        <div class="modal-section">
          <h3>Ingredients</h3>
          <ul>
            <li v-for="(item, idx) in selectedRecipe.ingredients" :key="idx">{{ item }}</li>
          </ul>
        </div>
        <div class="modal-section">
          <h3>Instructions</h3>
          <ol>
            <li v-for="(step, idx) in selectedRecipe.steps" :key="idx">{{ step }}</li>
          </ol>
        </div>
        <div class="modal-section" v-if="selectedRecipe.nutrition">
          <h3>Nutritional Info</h3>
          <ul>
            <li v-for="(val, key) in selectedRecipe.nutrition" :key="key">{{ key }}: {{ val }}</li>
          </ul>
        </div>
      </div>
    </div>
    <div class="favorites-modal" v-if="navTab === 'favorites' && favorites.length">
      <div class="modal-content">
        <button class="close-modal" @click="navTab = 'home'" aria-label="Close favorites">×</button>
        <h2>Favorite Recipes</h2>
        <div class="recipes-grid">
          <div
            v-for="recipe in favorites"
            :key="recipe.id"
            class="recipe-card"
            @click="viewRecipe(recipe)"
            tabindex="0"
            @keyup.enter="viewRecipe(recipe)"
            role="button"
            aria-label="View recipe"
          >
            <img :src="recipe.image" :alt="recipe.title" class="recipe-card-img"/>
            <div class="recipe-card-content">
              <h3 class="recipe-title">{{ recipe.title }}</h3>
              <p class="recipe-metadata">
                {{ recipe.category }} &middot; {{ recipe.time }} mins
              </p>
            </div>
            <button
              class="fav-button active"
              @click.stop="toggleFavorite(recipe)"
              aria-label="Unfavorite recipe"
            >
              <svg height="24" viewBox="0 0 24 24" width="24">
                <path fill="#FF7043"
                      d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.41 4.42 3 7.5 3a5.48 5.48 0 014.5 2.09A5.48 5.48 0 0116.5 3C19.58 3 22 5.41 22 8.5c0 3.78-3.4 6.86-8.55 11.54z"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="add-modal" v-if="navTab === 'add'">
      <div class="modal-content">
        <button class="close-modal" @click="navTab = 'home'" aria-label="Close add recipe">×</button>
        <h2>Add New Recipe</h2>
        <form @submit.prevent="submitRecipe" class="add-form">
          <input v-model="newRecipe.title" placeholder="Recipe Title" required />
          <input v-model="newRecipe.category" placeholder="Category" required />
          <input v-model="newRecipe.time" placeholder="Cook Time (mins)" type="number" required />
          <input v-model="newRecipe.image" placeholder="Image URL" />
          <div>
            <label>Ingredients (comma separated):</label>
            <input v-model="newRecipe.ingredientsRaw" placeholder="e.g., 2 eggs, 1 cup sugar" />
          </div>
          <div>
            <label>Steps (one per line):</label>
            <textarea v-model="newRecipe.stepsRaw" placeholder="Step 1&#10;Step 2"></textarea>
          </div>
          <div>
            <label>Nutritional Info (JSON):</label>
            <textarea v-model="newRecipe.nutritionRaw" placeholder='{"calories": "220", "protein": "4g"}'></textarea>
          </div>
          <button class="submit-btn" type="submit">Add</button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
// PUBLIC_INTERFACE
/**
 * The main container Vue component for RecipeNest.
 * Features a search bar, recipe listing, modals for recipe details, favorites, and add recipe.
 *
 * All state is kept local for demonstration purposes.
 */
import { ref, computed } from 'vue';

const colors = {
  primary: '#FF7043',
  secondary: '#FFF3E0',
  accent: '#66BB6A'
};

const navTab = ref('home');
const searchQuery = ref('');
const featuredRecipes = ref([
  {
    id: 1,
    title: "Classic Pancakes",
    category: "Breakfast",
    time: 15,
    isFavorite: false,
    image: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
    ingredients: ["2 cups flour", "2 eggs", "1.5 cups milk", "2 tbsp sugar", "1 tsp baking powder"],
    steps: [
      "In a large bowl, combine flour, sugar, and baking powder.",
      "Whisk in eggs and milk until smooth.",
      "Heat a pan and pour batter to form pancakes.",
      "Cook until golden, flip and finish.",
      "Serve warm."
    ],
    nutrition: { calories: 220, protein: "6g", carbs: "31g", fat: "7g" }
  },
  {
    id: 2,
    title: "Chicken Caesar Salad",
    category: "Salad",
    time: 20,
    isFavorite: false,
    image: "https://images.unsplash.com/photo-1464306076886-debca5e8a6b0?auto=format&fit=crop&w=400&q=80",
    ingredients: ["2 cups lettuce", "100g grilled chicken", "Caesar dressing", "Croutons", "Parmesan cheese"],
    steps: [
      "Chop lettuce and place in bowl.",
      "Add grilled chicken, croutons, and Parmesan.",
      "Drizzle with Caesar dressing and toss.",
      "Serve chilled."
    ],
    nutrition: { calories: 340, protein: "22g", carbs: "16g", fat: "19g" }
  }
  // Add more demo recipes as desired
]);
const selectedRecipe = ref(null);
const favorites = ref([]);
const newRecipe = ref({
  title: "",
  category: "",
  time: "",
  image: "",
  ingredientsRaw: "",
  stepsRaw: "",
  nutritionRaw: ""
});

// PUBLIC_INTERFACE
function onSearch() {
  // No real backend; filter featured by query
}

const filteredRecipes = computed(() =>
  featuredRecipes.value.filter(recipe => {
    const q = searchQuery.value.trim().toLowerCase();
    if (!q) return true;
    return (
      recipe.title.toLowerCase().includes(q) ||
      recipe.category.toLowerCase().includes(q) ||
      recipe.ingredients.join(" ").toLowerCase().includes(q)
    );
  })
);

// PUBLIC_INTERFACE
function viewRecipe(recipe) {
  selectedRecipe.value = recipe;
  navTab.value = 'home';
}

// PUBLIC_INTERFACE
function toggleFavorite(recipe) {
  recipe.isFavorite = !recipe.isFavorite;
  if (recipe.isFavorite) {
    if (!favorites.value.some(r => r.id === recipe.id)) {
      favorites.value.push(recipe);
    }
  } else {
    favorites.value = favorites.value.filter(r => r.id !== recipe.id);
  }
}

// PUBLIC_INTERFACE
function showFavorites() {
  navTab.value = 'favorites';
}

// PUBLIC_INTERFACE
function addRecipe() {
  navTab.value = 'add';
}

// PUBLIC_INTERFACE
function submitRecipe() {
  const id = Date.now();
  const newRec = {
    id,
    title: newRecipe.value.title,
    category: newRecipe.value.category,
    time: newRecipe.value.time,
    isFavorite: false,
    image: newRecipe.value.image || 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
    ingredients: (newRecipe.value.ingredientsRaw || "").split(',').map(s => s.trim()).filter(Boolean),
    steps: (newRecipe.value.stepsRaw || "").split('\n').map(s => s.trim()).filter(Boolean),
    nutrition: (() => {
      try {
        return JSON.parse(newRecipe.value.nutritionRaw || '{}');
      } catch (e) {
        return {};
      }
    })()
  };
  featuredRecipes.value.unshift(newRec);
  Object.assign(newRecipe.value, {
    title: "", category: "", time: "", image: "", ingredientsRaw: "", stepsRaw: "", nutritionRaw: ""
  });
  navTab.value = 'home';
}
</script>

<style scoped>
.main-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #FFF3E0;
  font-family: 'Segoe UI', 'Helvetica', 'Arial', sans-serif;
  padding-bottom: 68px;
}
.search-header {
  background: #FF7043;
  padding: 1.1rem .75rem;
  display: flex;
  align-items: center;
  justify-content: center;
}
.search-bar {
  width: 100%;
  font-size: 1.1rem;
  padding: 0.6em 1em;
  border: none;
  border-radius: 2em;
  box-shadow: 1px 2px 9px 0 #ff55031a;
  background: #fff;
  color: #2d2d2d;
  outline: none;
  max-width: 480px;
}
.section-title {
  color: #ff7043;
  margin: 1.8rem 0 .6rem 1rem;
  font-size: 1.2rem;
  font-weight: 700;
}
.recipe-list {
  padding: 0 .5rem;
  flex: 1 1;
}
.recipes-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1.25rem;
  justify-content: flex-start;
}
.recipe-card {
  position: relative;
  background: #fff;
  border-radius: 1.3rem;
  box-shadow: 0 2px 13px -4px #4e443811;
  padding: 0;
  margin: .5rem 0 0 0;
  width: 240px;
  min-width: 180px;
  max-width: 95vw;
  min-height: 140px;
  cursor: pointer;
  transition: box-shadow 0.18s;
  display: flex;
  flex-direction: column;
}
.recipe-card:focus, .recipe-card:hover {
  box-shadow: 0 4px 22px -4px #ff704355;
  outline: 2px solid #ff7043;
}
.recipe-card-img {
  width: 100%;
  height: 130px;
  object-fit: cover;
  border-top-left-radius: 1.3rem;
  border-top-right-radius: 1.3rem;
}
.recipe-card-content {
  padding: .8rem 1rem .4rem 1rem;
  flex: 1 1;
}
.recipe-title {
  font-size: 1.14rem;
  color: #332109;
  margin: 0 0 .25rem 0;
  font-weight: 600;
}
.recipe-metadata {
  color: #888;
  font-size: .93rem;
}
.fav-button {
  background: transparent;
  border: none;
  outline: none;
  padding: .3em;
  position: absolute;
  top: .75em;
  right: .85em;
  cursor: pointer;
  z-index: 3;
  transition: transform 0.19s;
}
.fav-button.active svg path { fill: #FF7043; }
.fav-button svg path { transition: fill 0.19s; }
.bottom-nav {
  position: fixed;
  left: 0; right: 0; bottom: 0;
  height: 64px;
  background: #fff;
  border-top: 1.5px solid #ff704345;
  box-shadow: 0 -3px 16px -8px #ff704345;
  display: flex;
  justify-content: space-around;
  align-items: center;
  z-index: 99;
}
.nav-btn {
  background: none;
  border: none;
  color: #525252;
  font-size: .99rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  cursor: pointer;
  padding: .6em 0 0.1em 0;
  min-width: 60px;
  transition: color 0.18s;
}
.nav-btn.active, .nav-btn:focus {
  color: #ff7043;
}
.nav-btn svg {
  margin-bottom: .2em;
  display: block;
}
.recipe-modal, .favorites-modal, .add-modal {
  position: fixed;
  left: 0; right: 0; top: 0; bottom: 0;
  background: rgba(0,0,0,.18);
  z-index: 999;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  overflow-y: auto;
}
.modal-content {
  background: #fff;
  border-radius: 1.2rem;
  box-shadow: 0 6px 48px 10px #934e3442;
  max-width: 430px;
  min-width: 220px;
  padding: 2.2rem 1.4rem 1.5rem 1.4rem;
  margin-top: 3.2rem;
  position: relative;
}
.close-modal {
  position: absolute;
  top: 1.2rem;
  right: 1.2rem;
  background: none;
  border: none;
  font-size: 2.2rem;
  color: #FF7043;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity .19s;
}
.close-modal:hover { opacity: 1; }
.modal-img {
  width: 100%;
  border-radius: 1.2rem;
  max-height: 190px;
  object-fit: cover;
  margin-bottom: .8rem;
}
.modal-metadata {
  color: #888;
  font-size: 1rem;
  margin-bottom: .6rem;
}
.modal-section {
  margin-bottom: 1.1rem;
}
.modal-section h3 {
  color: #66BB6A;
  margin: .7em 0 .3em 0;
}
.add-form input, .add-form textarea {
  width: 100%;
  margin-bottom: .6em;
  padding: 0.7em;
  border-radius: .85em;
  border: 1.5px solid #ff704340;
  font-size: 1.05em;
  outline: none;
  font-family: inherit;
}
.add-form input:focus, .add-form textarea:focus {
  border-color: #ff7043;
  background: #fff3e060;
}
.add-form label {
  color: #332109; font-weight: 460; font-size: .98rem;
}
.submit-btn {
  background: #66BB6A;
  color: #fff;
  border: none;
  border-radius: 1em;
  padding: 0.8em 2.1em;
  font-size: 1.1em;
  margin-top: .8em;
  cursor: pointer;
  box-shadow: 0 2px 9px 0 #66bb6a2a;
  transition: background .15s;
}
.submit-btn:hover { background: #43a047; }
@media (max-width: 600px) {
  .modal-content { min-width: 98vw; margin-top: 1.2rem; padding: .6rem .35rem 1.4rem .35rem;}
  .recipes-grid { flex-direction: column; gap: 1em;}
  .main-container { padding-bottom: 85px;}
}
</style>
