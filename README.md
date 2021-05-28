It provides a facility to calculate total rewads earn by a user on its purchase.
Reward is being calculated based on time user is placing order, reward factor varies as per time and amount user is spending.

Asumption:
System is designed only for 2 actions:
1. Register an user
2. Place an order
3. Timestamp given should be string format of datetime object "yyyy-mm-ddThh:mm:ss-utcOffset"

Input: 
It serves array of event JSON, every event json should have following format
{
    "action":"new_customer",
    "name":"Jack",
    "timestamp":"2021-05-27T00:00:00-05:00"
}

Output:
It will return total rewards along with average reward per order or No order if user hasn't places any order yet.
{"Jack"=>"x points with y points per order."}

Resources:
Ruby ruby 2.3.1p112

To Run the application:
Clone this repo.
Go to reward-statistics folder
Give execution permission to bin/fooda file chmod +x bin/fooda
Run bundle install
Run bin/fooda