from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Dict
import requests

app = FastAPI()

# Sample data storage
items: Dict[str, Dict[str, float]] = {}

# Define a model for POST and PUT request data
class Item(BaseModel):
    name: str = Field(..., example="Apple")
    description: str = Field(..., example="A juicy red apple")
    price: float = Field(..., gt=0, example=1.99)

# GET endpoint 1: Retrieve an item by its name
@app.get("/items/{item_name}", response_model=Item)
async def get_item(item_name: str):
    if item_name in items:
        return {"name": item_name, "description": items[item_name]["description"], "price": items[item_name]["price"]}
    else:
        raise HTTPException(status_code=404, detail="Item not found")

# GET endpoint 2: Retrieve all items
@app.get("/items/", response_model=Dict[str, Item])
async def get_all_items():
    return {name: {"name": name, "description": data["description"], "price": data["price"]} for name, data in items.items()}

# POST endpoint 1: Create a new item
@app.post("/items/", response_model=Item, status_code=201)
async def create_item(item: Item):
    if item.name in items:
        raise HTTPException(status_code=400, detail="Item already exists")
    items[item.name] = {"description": item.description, "price": item.price}
    return item

# PUT endpoint: Update an existing item
@app.put("/items/{item_name}", response_model=Item)
async def update_item(item_name: str, item: Item):
    if item_name not in items:
        raise HTTPException(status_code=404, detail="Item not found")
    if item_name != item.name:
        # Handle name change
        if item.name in items:
            raise HTTPException(status_code=400, detail="New item name already exists")
        items.pop(item_name)
    items[item.name] = {"description": item.description, "price": item.price}
    return item

# DELETE endpoint: Remove an item
@app.delete("/items/{item_name}", response_model=dict)
async def delete_item(item_name: str):
    if item_name in items:
        items.pop(item_name)
        return {"message": f"Item '{item_name}' deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail="Item not found")

# Endpoint to call an external URL
@app.get("/external/", response_model=dict)
async def call_external_url():
    external_url = "https://jsonplaceholder.typicode.com/todos/1"  # Example URL
    response = requests.get(external_url)
    if response.status_code == 200:
        return response.json()
    else:
        raise HTTPException(status_code=response.status_code, detail="External request failed")
