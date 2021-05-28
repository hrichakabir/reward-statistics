require 'time'

module Engine
    # Hour  :   Reward/Amount       minutes
    # 10-11 :   1                   600-660
    # 11-12 :   0.5                 660-720
    # 12-13 :   0.33                720-780
    # 13-14 :   0.5                 780-840
    # 14-15 :   1                   840-900

    #Reward factor based on time, conveted hour boundary into mintues for simplicity
    REWARD_FACTOR = {
        600 => 0.25,
        660 => 1,
        720 => 0.5,
        780 => 0.33,
        840 => 0.5,
        900 => 1,
        "default" => 0.25
    }

    STATUS_CODES = {
        "bad_request" => 401,
        "success" => 200,
        "error" => 500
    }



    class User
        @@usr_reward_array = []

        def initialize
        end

        #Store new user's map into user award array
        def register(params={})
            name = params[:name] 
            timestamp = params[:timestamp]
            amount = params[:amount]
            msg = ""
            #Nil check for mandatory fields
            if name.nil? || timestamp.nil?
                msg = "Name or timestamp can't be blank"
                puts "Exception in User::register:: #{msg}"
                return {"status" => STATUS_CODES["bad_request"], "result" => msg}
            end
            index = @@usr_reward_array.find_index{|um| um["name"] == name}
            if index.present?
                msg = "User is already registered"
                puts "User::register:: #{msg}"
                return {"status" => STATUS_CODES["success"], "result" => msg}
            end
            if @@usr_reward_array.push({"name" => name, "reward" => 0, "purchase_count" => 0})
                msg = "User #{name} registered successfully"
                puts "User::register:: #{msg}"
                return {"status" => STATUS_CODES["success"], "result" => msg}
            end 
        end

        def show_registered_user(params)
            name = params[:name]
            return [] if name.nil?
            @@usr_reward_array.select{|item| item['name'] == name}
        end

        #Maintain reward and purchase_count for each user
        def purchase(params)
            name = params[:customer]
            timestamp = params[:timestamp]
            amount = params[:amount]
            msg = ""
            #Nil check for mandatory fields
            if name.nil? || timestamp.nil? || amount.nil?
                msg = "Customer name, amount or timestamp can't be blank"
                puts "Exception in User::purchase:: #{msg}"
                return {"status" => STATUS_CODES["bad_request"], "result" => msg}
            end
            unless show_registered_user({:name => name}).present?
                msg = "User is not registered, kindly register first"
                puts "Exception in User::purchase:: #{msg}"
                return {"status" => STATUS_CODES["bad_request"], "result" => msg}
            end
            begin
                reward = avail_reward(timestamp, amount)
                index = @@usr_reward_array.find_index{|um| um["name"] == name}

                @@usr_reward_array[index]["reward"] += reward
                @@usr_reward_array[index]["purchase_count"] += 1
                msg = "Order placed successfully"
                return {"status" => STATUS_CODES["success"], "result" => msg}
            rescue Exception => e
                msg = "Error in processing event, #{e.message}"
                puts "Exception in User::purchase:: #{msg}"
                return {"status" => STATUS_CODES["error"], "result" => msg}
            end 
        end

        def reward_report
            
            result = {}
            #Iterate array to create result map
            @@usr_reward_array.sort_by{|udm| udm["reward"]}.reverse.each do |item|
                if item['purchase_count'] > 0
                    result[item['name']] = "#{item['reward']} points with #{item['reward']/item['purchase_count']} points per order." 
                else 
                    result[item['name']] = "No Order"
                end
            end
            result
        end

        private

        #Calculate reward points on each purchase
        def avail_reward(timestamp, amount)
            reward = 0
            #Parse date time string into date time object with timezone
            ts = Time.parse(timestamp)
            #Convert purchase time into minutes to compare it with reward_factor map
            hr = ts.hour
            min = ts.min
            minutes = hr*60 + min

            if minutes < 600
                reward = amount*(REWARD_FACTOR[600])
            elsif minutes <= 660
                reward = amount*(REWARD_FACTOR[660])
            elsif minutes <= 720
                reward = amount*(REWARD_FACTOR[720])
            elsif minutes <= 780
                reward = amount*(REWARD_FACTOR[780])
            elsif minutes <= 840
                reward = amount*(REWARD_FACTOR[840])
            elsif minutes <= 900
                reward = amount*(REWARD_FACTOR[900])
            else
                reward = amount*(REWARD_FACTOR["default"])
            end
            if reward%1 > 0 && reward%1 < 1
                reward = reward.to_i + 1 
            end
            reward = (reward >= 3 && reward <= 20) ? reward : 0
            reward
        end
    
    end
end