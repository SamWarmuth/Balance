
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("buyChips", function(request, response) {
  if (request.user == undefined) {
    response.error("No user found.");
    return;
  }
  var amount = request.params.amount;
  if (amount == undefined) {
    response.error("No amount specified.");
    return;
  }
  
  response.success("Hello " + request.user.get("name") + "!");
  
  
  
});
