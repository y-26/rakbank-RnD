import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [items, setItems] = useState({});
  const [newItem, setNewItem] = useState({ name: '', description: '', price: '' });
  const [error, setError] = useState('');

  const backendUrl = "https://<YOUR_BACKEND_URL>"; // Replace with your backend URL

  useEffect(() => {
    fetch(`${backendUrl}/items/`)
      .then(response => response.json())
      .then(data => setItems(data))
      .catch(err => setError('Failed to fetch items'));
  }, [backendUrl]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewItem(prev => ({ ...prev, [name]: value }));
  };

  const handleAddItem = () => {
    const { name, description, price } = newItem;
    if (!name || !description || !price) {
      setError('All fields are required');
      return;
    }

    fetch(`${backendUrl}/items/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, description, price: parseFloat(price) })
    })
      .then(response => {
        if (!response.ok) {
          return response.json().then(err => { throw err; });
        }
        return response.json();
      })
      .then(item => {
        setItems(prev => ({ ...prev, [item.name]: item }));
        setNewItem({ name: '', description: '', price: '' });
        setError('');
      })
      .catch(err => setError(err.detail || 'Failed to add item'));
  };

  return (
    <div className="App">
      <h1>Items List</h1>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <ul>
        {Object.values(items).map(item => (
          <li key={item.name}>
            <strong>{item.name}</strong>: {item.description} - ${item.price.toFixed(2)}
          </li>
        ))}
      </ul>
      <h2>Add New Item</h2>
      <input
        type="text"
        name="name"
        placeholder="Name"
        value={newItem.name}
        onChange={handleInputChange}
      />
      <input
        type="text"
        name="description"
        placeholder="Description"
        value={newItem.description}
        onChange={handleInputChange}
      />
      <input
        type="number"
        name="price"
        placeholder="Price"
        value={newItem.price}
        onChange={handleInputChange}
      />
      <button onClick={handleAddItem}>Add Item</button>
    </div>
  );
}

export default App;
