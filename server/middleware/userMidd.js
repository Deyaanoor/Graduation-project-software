const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ message: 'لا يوجد توكن مصادق عليه' });
  }

  try {
    const decoded = jwt.verify(token, 'your_jwt_secret');
    req.user = decoded; 
    next();
  } catch (error) {
    res.status(400).json({ message: 'Token not valid' });
  }
};

module.exports = authMiddleware;
