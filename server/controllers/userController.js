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

// Set up Cloudinary storage for multer
const storage = new multerStorageCloudinary({
  cloudinary: cloudinary,
  params: {
    folder: 'user_avatars',
    allowed_formats: ['jpg', 'jpeg', 'png'],
  },
});

// Set up multer for file upload
const upload = multer({ storage: storage });



const registerUser = async (req, res) => {
  const { name, email, password, phoneNumber } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection('users');
    const employeesCollection = db.collection('employees');
    const ownersCollection = db.collection('owners');

    const existingUser = await usersCollection.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const owner = await ownersCollection.findOne({ email, name });
    if (owner) {
      const role = 'owner';
      const hashedPassword = await bcrypt.hash(password, 10);
      const newUser = {
        _id: owner._id, // نفس ID الموجود في جدول owners
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        role,
        ownerId: owner._id, // تخزنه كمرجع كمان (اختياري)
        avatar: null,
      };

      await usersCollection.insertOne(newUser);
      return res.status(201).json({ message: 'Owner account created successfully', role });
    }

    // هل هو موظف؟
    const employee = await employeesCollection.findOne({ email, name, phoneNumber });
    if (employee) {
      const role = 'employee';
      const hashedPassword = await bcrypt.hash(password, 10);

      const newUser = {
        _id: employee._id,
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        role,
        avatar: null,
      };

      await usersCollection.insertOne(newUser);
      return res.status(201).json({ message: 'Employee account created successfully', role });
    }

    // مش موظف ولا owner
    return res.status(400).json({ message: 'User must be either an employee or an owner' });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred during registration' });
  }
};


//loginUser
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
      role: user.role,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'An error occurred during login' });
  }
};

const updateAvatar = async (req, res) => {
  const { userId } = req.params;

  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  try {
    // رفع الصورة إلى Cloudinary
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: 'avatars',
    });

    const avatarUrl = result.secure_url;

    const db = await connectDB();
    const usersCollection = db.collection('users');

    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    await usersCollection.updateOne(
      { _id: new ObjectId(userId) },
      { $set: { avatar: avatarUrl } }
    );

    res.status(200).json({ message: 'Avatar updated successfully', avatarUrl });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error uploading avatar' });
  }
};


//Get user info
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
      role: user.role,
      avatar: user.avatar,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to fetch user data' });
  }
};

//updateUserInfo
const updateUserInfo = async (req, res) => {
  const { userId } = req.params;  
  const { name, password, phoneNumber } = req.body;

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

module.exports = { registerUser, loginUser, updateAvatar, getUserInfo, updateUserInfo, upload};
