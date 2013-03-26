
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("makeTransaction", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
  var type = request.params.type;
  if (type == undefined) {
    response.error("No type defined.");
    return;
  }
  
  var amount = request.params.amount;
  
  if (amount == undefined) {
    response.error("No amount specified.");
    return;
  }
  
  if (type == "buy") amount *= -1;
  var user = request.user;
  
  var Transaction = Parse.Object.extend("Transaction");
  var transaction = new Transaction();
  transaction.set("user", user);
  transaction.set("amount", amount);
  transaction.set("type", type);
  
  
  if (transaction.get("amount") == undefined || transaction.get("user") == undefined) {
    response.error("There was an error with the transaction");
    return;
  }
  
  transaction.save(null, {
    success: function(transaction) {
      var relation = user.relation("transactions");
      relation.add(transaction);
      user.save(null, {
        success: function(user) {
          var responseString = transaction.get("user").get("name") + "'s balance changes $" + transaction.get("amount").toFixed(2) + " by buying chips.";
          console.log(responseString);
          response.success(responseString);
        },
        error: function(user, error) {
          console.log(error.description);
          response.error(error.description);
        }
      });
    },
    error: function(transaction, error) {
      console.log(error.description);
      response.error(error.description);
    }
  });
});



Parse.Cloud.define("cashOut", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }

  var user = request.user;
  var transactionRelation = user.relation("transactions");
  
  transactionRelation.query().find({
    success: function(transactions) {
      var balance = transactions.reduce(function (a, b) { return a + b.get("amount");}, 0);
      
      if (balance == undefined) {
        response.error("Error: Balance couldn't be calculated.");
        return;
      }
      
      if (balance <= 0.0) {
        response.error("No money to cash out.");
        return;
      }
      
      var transaction = new Transaction();
      transaction.set("user", user);
      transaction.set("amount", balance * -1);
      transaction.set("type", "cashout");
      
  
      if (transaction.get("amount") == undefined || transaction.get("user") == undefined) {
        response.error("There was an error with the transaction");
        return;
      }
  
      transaction.save(null, {
        success: function(transaction) {
          var relation = user.relation("transactions");
          relation.add(transaction);
          user.save(null, {
            success: function(user) {
              var responseString = transaction.get("user").get("name") + "'s balance changes $" + transaction.get("amount").toFixed(2) + " by paying debt.";
              console.log(responseString);
              response.success(responseString);
            },
            error: function(user, error) {
              console.log(error.description);
              response.error(error.description);
            }
          });
        },
        error: function(transaction, error) {
          console.log(error.description);
          response.error(error.description);
        }
      });
      
    },
    error: function(error) {
      response.error("Error: " + error.code + " " + error.message);
    }
  }); 
});

Parse.Cloud.define("balance", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
  
  var user = request.user;
  var transactionRelation = user.relation("transactions");
  
  transactionRelation.query().find({
    success: function(transactions) {
      var balance = transactions.reduce(function (a, b) { return a + b.get("amount");}, 0);
      response.success(balance);
    },
    error: function(error) {
      response.error("Error: " + error.code + " " + error.message);
    }
  }); 
});

Parse.Cloud.define("transactions", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
  var user = request.user;
  var transactionRelation = user.relation("transactions");
  var query = transactionRelation.query();
  query.descending("createdAt");
  query.limit(10);
  query.find({
    success: function(transactions) {      
      response.success(transactions);
    },
    error: function(error) {
      response.error("Error: " + error.code + " " + error.message);
    }
  }); 
});
   


