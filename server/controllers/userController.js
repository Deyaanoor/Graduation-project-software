const express = require("express");
const cloudinary = require("cloudinary").v2;
const multer = require("multer");
const multerStorageCloudinary =
  require("multer-storage-cloudinary").CloudinaryStorage;
const { ObjectId } = require("mongodb");
const connectDB = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

cloudinary.config({
  cloud_name: "dmqgqu7st",
  api_key: "757442912861293",
  api_secret: "ifXxCdY2tdgnGG5y_55a_ZlDPKM",
});

const storage = new multerStorageCloudinary({
  cloudinary: cloudinary,
  params: {
    folder: "user_avatars",
    allowed_formats: ["jpg", "jpeg", "png"],
  },
});

const upload = multer({ storage: storage });

const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "deyaanoor9@gmail.com",
    pass: "mzfc rxnn zeez tmxr",
  },
});

const registerUser = async (req, res) => {
  const { name, email, password, phoneNumber, fcmToken } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");
    const employeesCollection = db.collection("employees");
    const ownersCollection = db.collection("owners");
    const clientCollection = db.collection("clients");
    const existingUser = await usersCollection.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists" });
    }
    console.log("Received registration request:", existingUser);

    let newUser = null;
    let role = null;

    const owner = await ownersCollection.findOne({ email, name });
    if (owner) {
      role = "owner";
      const hashedPassword = await bcrypt.hash(password, 10);
      newUser = {
        _id: owner._id,
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        fcmToken,
        role,
        avatar: null,
        isVerified: false,
        verificationSentAt: new Date(),
      };
    }

    const employee = await employeesCollection.findOne({
      email,
      name,
      phoneNumber,
    });
    if (employee) {
      role = "employee";
      const hashedPassword = await bcrypt.hash(password, 10);
      newUser = {
        _id: employee._id,
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        fcmToken,
        role,
        avatar: null,
        isVerified: false,
        verificationSentAt: new Date(),
      };
    }

    const client = await clientCollection.findOne({ email, name, phoneNumber });
    if (client) {
      role = "client";
      const hashedPassword = await bcrypt.hash(password, 10);
      newUser = {
        _id: client._id,
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        fcmToken,
        role,
        avatar: null,
        isVerified: false,
        verificationSentAt: new Date(),
      };
    }

    if (!newUser) {
      // return res.status(400).json({ message: 'User must be either an employee or an owner' });
      const hashedPassword = await bcrypt.hash(password, 10);
      newUser = {
        name,
        email,
        password: hashedPassword,
        phoneNumber,
        role,
        avatar: null,
        isVerified: false,
        verificationSentAt: new Date(),
      };
    }

    const verifyToken = jwt.sign(newUser, "secret-key", {
      expiresIn: "1h",
    });
    const verifyLink = `https://graduation-project-software.onrender.com/users/verify?token=${verifyToken}`;

    await transporter.sendMail({
      from: "deyaanoor9@gmail.com",
      to: email,
      subject: "Verify your account",
      html: `
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px;">
            <div style="max-width: 600px; margin: auto; background-color: #fff; padding: 30px; border: 1px solid #ffa500; border-radius: 8px;">
              <h2 style="color:rgb(252, 137, 29);">Account Verification 📝</h2>
              <p style="font-size: 16px;">Hello ${name},</p>
              <p style="font-size: 15px;">Thank you for registering! Click the button below to verify your email:</p>
              <div style="text-align: center; margin: 30px 0;">
                <a href="${verifyLink}" target="_blank" style="
                  background-color:rgb(252, 137, 29);
                  color: white;
                  padding: 14px 24px;
                  text-decoration: none;
                  border-radius: 6px;
                  font-size: 16px;
                  font-weight: bold;
                  display: inline-block;
                ">
                  ✅ Verify Email
                </a>
              </div>
            </div>
          </body>
        </html>
      `,
    });

    // await usersCollection.insertOne(newUser);
    return res.status(201).json({
      message: "Account created successfully. Verification email sent.",
      role,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "An error occurred during registration" });
  }
};

const verifyEmail = async (req, res) => {
  const { token } = req.query;

  try {
    const decoded = jwt.verify(token, "secret-key");
    const db = await connectDB();
    const usersCollection = db.collection("users");

    // تحقق إذا المستخدم مسجل أصلاً (يمنع تسجيل مكرر)
    const existingUser = await usersCollection.findOne({
      email: decoded.email,
    });
    if (existingUser) {
      return res.status(400).json({ message: "Account already verified" });
    }

    // أدخل المستخدم مع حقل isVerified true
    const newUser = {
      _id: new ObjectId(decoded._id),
      name: decoded.name,
      email: decoded.email,
      password: decoded.password,
      phoneNumber: decoded.phoneNumber,
      role: decoded.role,
      avatar: null,
      isVerified: true,
      createdAt: new Date(),
    };

    await usersCollection.insertOne(newUser);

    res
      .status(200)
      .json({ message: "Account verified and created successfully" });
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: "Invalid or expired token" });
  }
};
const checkVerification = async (req, res) => {
  const { email } = req.query;

  if (!email) {
    return res.status(400).json({ message: "Email is required" });
  }

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");

    const user = await usersCollection.findOne({ email });

    if (!user) {
      return res
        .status(404)
        .json({ message: "User not found", isVerified: false });
    }

    return res.status(200).json({
      isVerified: user.isVerified,
      message: user.isVerified
        ? "Account is verified"
        : "Account is not yet verified",
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Server error", isVerified: false });
  }
};
const resendVerificationEmail = async (req, res) => {
  const { email } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");

    const user = await usersCollection.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.isVerified) {
      return res.status(400).json({ message: "Account already verified" });
    }

    const now = new Date();
    const lastSent = user.verificationSentAt
      ? new Date(user.verificationSentAt)
      : null;

    if (lastSent && now - lastSent < 60 * 1000) {
      return res.status(429).json({
        message: "You can request a new verification email after 1 minute",
      });
    }

    const verifyToken = jwt.sign({ userId: user._id }, "secret-key", {
      expiresIn: "1h",
    });
    const verifyLink = `https://graduation-project-software.onrender.com/users/verify?token=${verifyToken}`;

    await transporter.sendMail({
      from: "deyaanoor9@gmail.com",
      to: email,
      subject: "Verify your account - Resend",
      html: `
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px;">
            <div style="max-width: 600px; margin: auto; background-color: #fff; padding: 30px; border: 1px solid #ffa500; border-radius: 8px;">
              <h2 style="color:rgb(252, 137, 29);">Account Verification 📝</h2>
              <p style="font-size: 16px;">Hello ${user.name},</p>
              <p style="font-size: 15px;">Click the button below to verify your email:</p>
              <div style="text-align: center; margin: 30px 0;">
                <a href="${verifyLink}" target="_blank" style="
                  background-color:rgb(252, 137, 29);
                  color: white;
                  padding: 14px 24px;
                  text-decoration: none;
                  border-radius: 6px;
                  font-size: 16px;
                  font-weight: bold;
                  display: inline-block;
                ">
                  ✅ Verify Email
                </a>
              </div>
            </div>
          </body>
        </html>
      `,
    });

    await usersCollection.updateOne(
      { email },
      { $set: { verificationSentAt: now } }
    );

    res.status(200).json({ message: "Verification email resent" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error resending verification email" });
  }
};

const forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");
    const user = await usersCollection.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "Email not found" });
    }

    const resetToken = jwt.sign({ userId: user._id }, "your_reset_secret", {
      expiresIn: "15m",
    });
    const resetLink = `https://graduation-project-software.onrender.com/users/reset-password?token=${resetToken}`;

    await transporter.sendMail({
      from: "deyaanoor9@email.com",
      to: email,
      subject: "Reset Your Password",
      html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background-color: #fff;">
        <div style="text-align: center; padding-bottom: 10px;">
          <h1 style="color: #f57c00; margin-bottom: 0;">Management Application</h1>
          <h3 style="color: #555; margin-top: 5px;">for Mechanic Workshop</h3>
        </div>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
        <h2 style="color: #f57c00;">🔐 Password Reset</h2>
        <p style="font-size: 16px; color: #333;">
          You recently requested to reset your password. Click the button below to continue:
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${resetLink}" style="background-color: #f57c00; color: white; padding: 12px 25px; text-decoration: none; font-size: 16px; border-radius: 5px;">
            Reset Password
          </a>
        </div>
        
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="font-size: 12px; color: #aaa; text-align: center;">
          &copy; 2025 Management Application for Mechanic Workshop. All rights reserved.
        </p>
      </div>
    `,
    });

    res.status(200).json({ message: "Reset link sent to your email." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error sending reset link." });
  }
};

const renderResetPasswordForm = async (req, res) => {
  const { token } = req.query;

  if (!token) {
    return res.status(400).send("Missing token");
  }

 res.send(`
<html>
  <head>
    <title>Reset Password</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f9;
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      .container {
        background-color: #ffffff;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        width: 100%;
        max-width: 400px;
        text-align: center;
      }
      h2 {
        color: #f57c00;
      }
      label {
        font-size: 14px;
        color: #333;
        text-align: left;
        display: block;
        margin-bottom: 8px;
      }
      .password-wrapper {
        position: relative;
      }
      input[type="password"],
      input[type="text"] {
        width: 100%;
        padding: 12px 40px 12px 12px;
        margin-bottom: 20px;
        border-radius: 5px;
        border: 1px solid #ddd;
        font-size: 16px;
      }
      .toggle-visibility {
        position: absolute;
        top: 50%;
        right: 12px;
        transform: translateY(-50%);
        cursor: pointer;
        font-size: 18px;
        color: #777;
      }
      button {
        background-color: #f57c00;
        color: white;
        border: none;
        padding: 12px 20px;
        font-size: 16px;
        border-radius: 5px;
        cursor: pointer;
        width: 100%;
      }
      button:hover {
        background-color: #e76c00;
      }
      .footer {
        margin-top: 20px;
        font-size: 12px;
        color: #aaa;
      }
      .error {
        color: red;
        font-size: 12px;
        margin-top: -10px;
        margin-bottom: 20px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h2>🔐 Reset Your Password</h2>
      <form method="POST" action="/users/reset-password" id="resetForm">
        <input type="hidden" name="token" value="${token}" />
        
        <label for="newPassword">New Password:</label>
        <div class="password-wrapper">
          <input type="password" name="newPassword" id="newPassword" required />
          <span class="toggle-visibility" onclick="toggleVisibility('newPassword', this)">👁️</span>
        </div>
        
        <label for="confirmPassword">Confirm Password:</label>
        <div class="password-wrapper">
          <input type="password" name="confirmPassword" id="confirmPassword" required />
          <span class="toggle-visibility" onclick="toggleVisibility('confirmPassword', this)">👁️</span>
        </div>

        <div id="errorMessage" class="error" style="display:none;">
          <p>Passwords do not match!</p>
        </div>

        <button type="submit">Reset Password</button>
      </form>

      <div class="footer">
        <p>© 2025 Management Application for Mechanic Workshop</p>
      </div>
    </div>

    <script>
      function toggleVisibility(id, el) {
        const input = document.getElementById(id);
        if (input.type === 'password') {
          input.type = 'text';
          el.textContent = '🙈';
        } else {
          input.type = 'password';
          el.textContent = '👁️';
        }
      }

      const form = document.getElementById('resetForm');
      form.addEventListener('submit', function(event) {
        const password = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const errorMessage = document.getElementById('errorMessage');

        if (password !== confirmPassword) {
          event.preventDefault();
          errorMessage.style.display = 'block';
        } else {
          errorMessage.style.display = 'none';
        }
      });
    </script>
  </body>
</html>
`);

};
const resetPassword = async (req, res) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword) {
    return res.status(400).send("Missing token or password.");
  }

  try {
    const decoded = jwt.verify(token, "your_reset_secret");
    const db = await connectDB();
    const usersCollection = db.collection("users");

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await usersCollection.updateOne(
      { _id: new ObjectId(decoded.userId) },
      { $set: { password: hashedPassword } }
    );

    res.send(`
      <html>
        <body>
          <h2>✅ Password has been reset successfully!</h2>
          <a href="/">Go to homepage</a>
        </body>
      </html>
    `);
  } catch (error) {
    console.error(error);
    res.status(400).send("Invalid or expired token.");
  }
};

const loginUser = async (req, res) => {
  const { email, password, fcmToken } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");
    const user = await usersCollection.findOne({ email });
    const garagesCollection = db.collection("garages");
const employeesCollection = db.collection("employees");
    if (!user) {
      return res.status(400).json({ message: "Email not found" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid password" });
    }

    if (!user.isVerified) {
      return res.status(403).json({
        message:
          "Email is not verified. Please verify your email before logging in.",
      });
    }

    let garage;
    if (user.role === "owner") {
      garage = await garagesCollection.findOne({ owner_id: user._id });
    } else if (user.role === "employee") {
      const employee = await employeesCollection.findOne({_id: user._id });
      garage = await garagesCollection.findOne({ _id: employee.garage_id });
    }

    // ✅ تحديث fcmToken إذا كان موجود
    if (fcmToken) {
      await usersCollection.updateOne(
        { _id: user._id },
        { $set: { fcmToken: fcmToken } }
      );
    }
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      "your_jwt_secret",
      { expiresIn: "1h" }
    );

    console.log("garage", garage);
    res.status(200).json({
      message: "Login successful",
      token,
      role: user.role,
      status: garage ? garage.status : "active",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "An error occurred during login" });
  }
};

const updateAvatar = async (req, res) => {
  const { userId } = req.params;

  if (!req.file) {
    return res.status(400).json({ message: "No file uploaded" });
  }

  try {
    const result = await cloudinary.uploader.upload(req.file.path, {
      folder: "avatars",
    });

    const avatarUrl = result.secure_url;

    const db = await connectDB();
    const usersCollection = db.collection("users");

    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    await usersCollection.updateOne(
      { _id: new ObjectId(userId) },
      { $set: { avatar: avatarUrl } }
    );

    res.status(200).json({ message: "Avatar updated successfully", avatarUrl });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Error uploading avatar" });
  }
};

//Get user info
const getUserInfo = async (req, res) => {
  const userId = req.params.userId;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");
    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
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
    res.status(500).json({ message: "Failed to fetch user data" });
  }
};

//updateUserInfo
const updateUserInfo = async (req, res) => {
  const { userId } = req.params;
  const { name, password, phoneNumber, email } = req.body;

  try {
    const db = await connectDB();
    const usersCollection = db.collection("users");
    const employeesCollection = db.collection("employees");
    const ownersCollection = db.collection("owners");
    const garagesCollection = db.collection("garages");
    const clientCollection = db.collection("clients");

    const user = await usersCollection.findOne({ _id: new ObjectId(userId) });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const updatedFields = {};
    const sharedFields = {};

    if (name) {
      updatedFields.name = name;
      sharedFields.name = name;
    }
    if (phoneNumber) {
      updatedFields.phoneNumber = phoneNumber;
      sharedFields.phoneNumber = phoneNumber;
    }
    if (email) {
      updatedFields.email = email;
      sharedFields.email = email;
    }
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updatedFields.password = hashedPassword;
    }

    const updatedUser = await usersCollection.updateOne(
      { _id: new ObjectId(userId) },
      { $set: updatedFields }
    );

    let ownerMatched = false;
    if (Object.keys(sharedFields).length > 0) {
      const updatedEmployee = await employeesCollection.updateOne(
        { email: user.email },
        { $set: sharedFields }
      );

      if (updatedEmployee.matchedCount === 0) {
        const updatedOwner = await ownersCollection.updateOne(
          { email: user.email },
          { $set: sharedFields }
        );
        if (updatedOwner.matchedCount > 0) {
          ownerMatched = true;
        }
      }
    }

    if (ownerMatched) {
      const garageUpdateFields = {};
      if (name) garageUpdateFields.name = name;
      if (email) garageUpdateFields.email = email;

      await garagesCollection.updateMany(
        { ownerEmail: user.email },
        { $set: garageUpdateFields }
      );
    }

    await clientCollection.updateMany(
      { email: user.email },
      { $set: sharedFields }
    );

    if (updatedUser.modifiedCount === 0) {
      return res.status(400).json({ message: "No changes made" });
    }

    res.status(200).json({ message: "User info updated successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ message: "An error occurred while updating user info" });
  }
};

module.exports = {
  registerUser,
  loginUser,
  updateAvatar,
  getUserInfo,
  updateUserInfo,
  upload,
  verifyEmail,
  forgotPassword,
  renderResetPasswordForm,
  resetPassword,
  resendVerificationEmail,
  checkVerification,
};
