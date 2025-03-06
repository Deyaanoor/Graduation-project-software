class User {
    constructor(name, email, age) {
      this.name = name;
      this.email = email;
      this.age = age;
      this.createdAt = new Date();
    }
  }
  
  module.exports = User;
  