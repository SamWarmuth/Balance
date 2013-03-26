
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
  
  if (type == "buy" || type == "cashout") amount *= -1;
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
      
      var estBalance = user.get("estBalance") + transaction.get("amount");
      user.set("estBalance", balanceGuess);

      user.save(null, {
        success: function(user) {
          response.success({"balance":estBalance,"transaction":transaction});
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
      user.set("estBalance", balance);
      user.save();
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

Parse.Cloud.define("allTransactions", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
  var query = new Parse.Query("Transaction");
  query.descending("createdAt");
  query.limit(30);
  query.include("user");
  query.find({
    success: function(transactions) {      
      response.success(transactions);
    },
    error: function(error) {
      response.error("Error: " + error.code + " " + error.message);
    }
  });
});

Parse.Cloud.define("allBalances", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
    
  var query = new Parse.Query(Parse.User);
  query.find({
    success: function(users) {      
      response.success(users);
    },
    error: function(error) {
      response.error("Error: " + error.code + " " + error.message);
    }
  });
});



