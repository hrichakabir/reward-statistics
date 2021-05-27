require 'engine/engine'

class Fooda

    
    def initialize
        @engine = Engine::User.new()
    end

    #Read events and call User calss methods to process event
    def start
        result = {}
        $input_events[:events].each do |event|
            action = event[:action]
            if action.nil?
                puts "Could not process event, action is not given"
                next
            end
            #Method to register new customer
            if action == "new_customer"
                @engine.register(event)
            elsif action == "new_order"
                @engine.purchase(event)
            else
                puts "Could not process event, Action is not valid"
            end
        end

        puts "\n----------------- User Reward Report ----------------"
        puts @engine.reward_report
        
    end

    private

    



    
end