const express = require('express');
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const multerStorageCloudinary = require('multer-storage-cloudinary').CloudinaryStorage;
const { ObjectId } = require('mongodb');
const connectDB = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

cloudinary.config({
  cloud_name: "dmqgqu7st",
  api_key: "757442912861293",
  api_secret: "ifXxCdY2tdgnGG5y_55a_ZlDPKM"
});

const storage = new multerStorageCloudinary({
  cloudinary: cloudinary,
  params: {
    folder: 'user_avatars',
    allowed_formats: ['jpg', 'jpeg', 'png'],
  },
});

const upload = multer({ storage: storage });

const registerUser = async (req, res) => {
  const { name, email, password, phoneNumber } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection('users');
    const existingUser = await usersCollection.findOne({ email });

    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = {
      name,
      email,
      password: hashedPassword,
      phoneNumber,
      role: 'user',
      avatar: null,
    };

    await usersCollection.insertOne(newUser);
    res.status(201).json({ message: 'Account created successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred during registration' });
  }
};

const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection('users');
    const user = await usersCollection.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: 'Email not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: 'Invalid password' });
    }

    const token = jwt.sign({ userId: user._id, role: user.role }, 'your_jwt_secret', { expiresIn: '1h' });

    res.status(200).json({
      message: 'Login successful',
      token,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred during login' });
  }
};

const updateAvatar = async (req, res) => {
  const { userId } = req.body;

  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Image is required' });
    }

    const result = req.file;

    const avatarUrl = result.secure_url;

    const db = await connectDB();
    const usersCollection = db.collection('users');

    const updatedUser = await usersCollection.updateOne(
      { _id: new ObjectId(userId) },
      { $set: { avatar: avatarUrl } }
    );

    if (updatedUser.modifiedCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      message: 'Avatar updated successfully',
      avatarUrl: avatarUrl,
    });

  } catch (error) {
    console.error("Error uploading image:", error);
    res.status(500).json({ message: "An error occurred while updating the avatar" });
  }
};

const getUserInfo = async (req, res) => {
  const userId = req.params.userId;  

  try {
    const db = await connectDB();
    const usersCollection = db.collection('users');
    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      password: user.password,
      avatar: user.avatar,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch user data' });
  }
};


const updateUserInfo = async (req, res) => {
  const { userId, name, password, phoneNumber } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection('users');
    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const updatedFields = {};

    if (name) updatedFields.name = name;
    if (phoneNumber) updatedFields.phoneNumber = phoneNumber;
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updatedFields.password = hashedPassword;
    }

    const updatedUser = await usersCollection.updateOne(
      { _id: new ObjectId(userId) },
      { $set: updatedFields }
    );

    if (updatedUser.modifiedCount === 0) {
      return res.status(400).json({ message: 'No changes made' });
    }

    res.status(200).json({ message: 'User info updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred while updating user info' });
  }
};

module.exports = { registerUser, loginUser, updateAvatar, getUserInfo, updateUserInfo, upload };
