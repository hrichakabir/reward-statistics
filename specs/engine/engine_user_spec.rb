require 'engine/engine'
require "active_support/all"

RSpec.describe Engine do
    describe "Register User" do 
        it 'Register user successfully' do
            params = {:name => "hricha", :action => "new_customer", :timestamp => Time.now.to_s}
            @engine = Engine::User.new()
            res = @engine.register(params)
            expect(res["status"]).to eq(200)
        end

        it 'Return error if name is not given' do
            params = {:action => "new_customer", :timestamp => Time.now.to_s}
            @engine = Engine::User.new()
            res = @engine.register(params)
            expect(res["status"]).to eq(401)
        end

        it 'Return error if timestamp is not given' do
            params = {:name => "hricha", :action => "new_customer"}
            @engine = Engine::User.new()
            res = @engine.register(params)
            expect(res["status"]).to eq(401)
        end
    end

    describe "Purchase Order" do
        before(:each) do
            params = {:name => "hricha", :action => "new_customer", :timestamp => Time.now.to_s}
            @engine = Engine::User.new()
            res = @engine.register(params)
        end

        it 'Error in placing order if user is not registered' do
            params = {:customer => "kabir", :action => "new_order", :timestamp => Time.now.to_s, :amount => 23}
            res = @engine.purchase(params)
            expect(res["status"]).to eq(401)
        end

        it 'Order placed successfully' do
            params = {:customer => "hricha", :action => "new_order", :timestamp => Time.now.to_s, :amount => 23}
            res = @engine.purchase(params)
            expect(res["status"]).to eq(200)
        end

        it 'Error in placing order if amount is not given' do
            params = {:customer => "hricha", :action => "new_order", :timestamp => Time.now.to_s}
            res = @engine.purchase(params)
            expect(res["status"]).to eq(401)
        end

        it 'Error in placing order if timestamp is not given' do
            params = {:customer => "hricha", :action => "new_order", :amount => 30}
            res = @engine.purchase(params)
            expect(res["status"]).to eq(401)
        end

        it 'Error in placing order if name is not given' do
            params = {:action => "new_order", :timestamp => Time.now.to_s, :amount => 23}
            res = @engine.purchase(params)
            expect(res["status"]).to eq(401)
        end
    end

    describe "Reward Report" do 
        before(:each) do
            params = {:name => "hricha", :action => "new_customer", :timestamp => Time.now.to_s}
            @engine = Engine::User.new()
            res = @engine.register(params)
        end

        it 'Get reward of 30% if timestamp is between of 12-13 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 12:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("14 points with 7 points per order.")
        end

        it 'Get reward of 50% if timestamp is between of 13-14 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 13:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("26 points with 8 points per order.")
        end

        it 'Get reward of 50% if timestamp is between of 11-12 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 11:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("38 points with 9 points per order.")
        end

        it 'Get reward of 100% if timestamp is between of 10-11 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 10:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 18}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("56 points with 11 points per order.")
        end

        it 'Get reward of 100% if timestamp is between of 14-15 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 14:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 18}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("74 points with 12 points per order.")
        end

        it 'Get reward of 25% if timestamp is greater than 15 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 16:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("80 points with 11 points per order.")
        end

        it 'Get reward of 25% if timestamp is less than 10 of local timezone' do
            time_zone = "Mumbai"
            name = "hricha"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 9:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("86 points with 10 points per order.")
        end

        it 'Get reward of 0 if reward amount is greater than 20' do
            time_zone = "Mumbai"
            name = "jack"
            params = {:name => name, :action => "new_customer", :timestamp => Time.now.to_s}
            @engine.register(params)
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 10:50')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 23}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("0 points with 0 points per order.")
        end

        it 'Get reward of 0 if reward amount is less than 3' do
            time_zone = "Mumbai"
            name = "jack"
            time = Time.use_zone(time_zone){Time.zone.parse('2021-05-27 12:40')}
            params = {:customer => name, :action => "new_order", :timestamp => time.to_s, :amount => 6}
            @engine.purchase(params)
            res = @engine.reward_report
            expect(res[name]).to eq("0 points with 0 points per order.")
        end

        
        
    end
end