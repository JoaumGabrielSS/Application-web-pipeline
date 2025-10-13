const express = require('express');
const router = express.Router();

// Mock user data
let users = [];

// Get all users
router.get('/', (req, res) => {
    res.json(users);
});

// Create a new user
router.post('/', (req, res) => {
    const { username } = req.body;
    if (!username) {
        return res.status(400).json({ error: 'Username is required' });
    }
    const newUser = { id: users.length + 1, username };
    users.push(newUser);
    res.status(201).json(newUser);
});

// Get a user by ID
router.get('/:id', (req, res) => {
    const user = users.find(u => u.id === parseInt(req.params.id));
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
});

// Delete a user by ID
router.delete('/:id', (req, res) => {
    const userIndex = users.findIndex(u => u.id === parseInt(req.params.id));
    if (userIndex === -1) {
        return res.status(404).json({ error: 'User not found' });
    }
    users.splice(userIndex, 1);
    res.status(204).send();
});

module.exports = router;